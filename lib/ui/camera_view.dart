// ignore_for_file: inference_failure_on_function_return_type

import 'dart:isolate';

import 'package:camera/camera.dart';
import 'package:deneeme_tflite_new/tflite/classifier.dart';
import 'package:deneeme_tflite_new/tflite/recognition.dart';
import 'package:deneeme_tflite_new/tflite/stats.dart';
import 'package:deneeme_tflite_new/ui/camera_view_singleton.dart';
import 'package:deneeme_tflite_new/ui/home_view.dart';
import 'package:deneeme_tflite_new/utils/isolate_utils.dart';
import 'package:flutter/material.dart';

/// [CameraView] sends each frame for inference
class CameraView extends StatefulWidget {
  /// Callback to pass results after inference to [HomeView]
  final Function(List<Recognition> recognitions) resultsCallback;

  /// Callback to inference stats to [HomeView]
  final Function(Stats stats) statsCallback;

  /// Constructor
  // ignore: sort_constructors_first, use_key_in_widget_constructors
  const CameraView(this.resultsCallback, this.statsCallback);
  @override
  // ignore: library_private_types_in_public_api
  _CameraViewState createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> with WidgetsBindingObserver {
  /// List of available cameras
  List<CameraDescription>? cameras;

  /// Controller
  CameraController? cameraController;

  /// true when inference is ongoing
  bool? predicting;

  /// Instance of [Classifier]
  Classifier? classifier;

  /// Instance of [IsolateUtils]
  IsolateUtils? isolateUtils;

  @override
  void initState() {
    super.initState();
    initStateAsync();
  }

  Future<void> initStateAsync() async {
    WidgetsBinding.instance.addObserver(this);

    // Spawn a new isolate
    isolateUtils = IsolateUtils();
    await isolateUtils!.start();

    // Camera initialization
    await initializeCamera();

    // Create an instance of classifier to load model and labels
    classifier = Classifier();

    // Initially predicting = false
    predicting = false;
  }

  /// Initializes the camera by setting [cameraController]
  Future<void> initializeCamera() async {
    final cameras = await availableCameras();

    // cameras[0] for rear-camera
    cameraController =
        CameraController(cameras[0], ResolutionPreset.high, enableAudio: false);

    await cameraController?.initialize().then((_) async {
      // Stream of image passed to [onLatestImageAvailable] callback
      await cameraController?.startImageStream(onLatestImageAvailable);

      /// previewSize is size of each image frame captured by controller
      ///
      /// 352x288 on iOS, 240p (320x240) on Android with ResolutionPreset.low
      final previewSize = cameraController!.value.previewSize;

      /// previewSize is size of raw input image to the model
      CameraViewSingleton.inputImageSize = previewSize;

      // the display width of image on screen is
      // same as screenWidth while maintaining the aspectRatio
      // ignore: use_build_context_synchronously
      final screenSize = MediaQuery.of(context).size;
      CameraViewSingleton.screenSize = screenSize;
      CameraViewSingleton.ratio = screenSize.width / previewSize!.height;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Return empty container while the camera is not initialized
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return Container();
    }

    return Container(
      width: 500,
      height: 600,
      child: AspectRatio(
        aspectRatio: cameraController!.value.aspectRatio,
        child: CameraPreview(cameraController!),
      ),
    );
  }

  /// Callback to receive each frame [CameraImage] perform inference on it
  Future<void> onLatestImageAvailable(CameraImage cameraImage) async {
    if (classifier?.interpreter != null && classifier?.labels != null) {
       //It performs inference on the image using a separate isolate and then calls the callback functions to pass the 
       //results and stats back to the parent widget (HomeView).
      // If previous inference has not completed then return
      if (predicting!) {
        return;

      }

      setState(() {
        predicting = true;
        //This code is used to set the predicting variable to true, indicating that an inference operation is in progress. The setState call triggers a rebuild, updating the UI to reflect the change in the predicting state.

        //Remember that setState should only be called from methods that are part of the State object, typically within the methods of the StatefulWidget 
        //(e.g., initState, event handlers, etc.). It's a mechanism for coordinating changes in the widget's state with the framework's rendering pipeline.
        //Whenever the internal state of a StatefulWidget changes, and you want to reflect that change in the user interface, you should call setState. 
        //This change could be due to user interactions, asynchronous operations completing, or any other event that causes a change in the widget's state
      });

      //The if (predicting!) check is used to determine whether there is an ongoing inference operation. If predicting is currently true, it means that 
      //a previous inference is still in progress, and the method returns early without starting a new inference.

      //If predicting is false, it means that there is no ongoing inference, and the setState method is used to set predicting to true. This update triggers 
      //a rebuild of the widget, which is crucial for reflecting the change in the UI.

      final uiThreadTimeStart = DateTime.now().millisecondsSinceEpoch;

      // Data to be passed to inference isolate
      final isolateData = IsolateData(
        cameraImage,
        classifier!.interpreter?.address,
        classifier?.labels,
      );

      // We could have simply used the compute method as well however
      // it would be as in-efficient as we need to continuously passing data
      // to another isolate.

      /// perform inference in separate isolate
      final inferenceResults = await inference(isolateData);
      //Calls the inference method to perform inference in a separate isolate. The await keyword is used to wait for the results.

      final uiThreadInferenceElapsedTime =
          DateTime.now().millisecondsSinceEpoch - uiThreadTimeStart;
          //Calculates the total time taken for the inference on the UI thread by subtracting the start time recorded earlier from the current time.

      // pass results to HomeView
      widget.resultsCallback(
        inferenceResults['recognitions'] as List<Recognition>,
        //Calls the resultsCallback callback function provided by the parent widget (HomeView) to pass the recognition results.
      );

      // pass stats to HomeView
      widget.statsCallback(
        (inferenceResults['stats'] as Stats)
          ..totalElapsedTime = uiThreadInferenceElapsedTime,
          //Calls the statsCallback callback function to pass the inference statistics. It also updates the totalElapsedTime property of the Stats object with the time taken for inference on the UI thread.
      );

      // set predicting to false to allow new frames
      setState(() {
        predicting = false;
      });
      print('predicting: $predicting');
    }
    

  }

  /// Runs inference in another isolate
  Future<Map<String, dynamic>> inference(IsolateData isolateData) async {
    final responsePort = ReceivePort();
    isolateUtils!.sendPort!
        .send(isolateData..responsePort = responsePort.sendPort);
    final results = await responsePort.first;
    return results as Map<String, dynamic>;
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async { //method is called when the app lifecycle state changes 
  //(e.g., when the app is paused or resumed). It starts or stops the image stream accordingly.
    switch (state) {
      case AppLifecycleState.paused:
        await cameraController?.stopImageStream();
      case AppLifecycleState.resumed:
        if (!cameraController!.value.isStreamingImages) {
          await cameraController?.startImageStream(onLatestImageAvailable);
        }
      default:
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    cameraController?.dispose();
    super.dispose();
  }
}
