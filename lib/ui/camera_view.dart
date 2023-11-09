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
        CameraController(cameras[0], ResolutionPreset.low, enableAudio: false);

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
      var screenSize = MediaQuery.of(context).size;
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

    return AspectRatio(
      aspectRatio: cameraController!.value.aspectRatio,
      child: CameraPreview(cameraController!),
    );
  }

  /// Callback to receive each frame [CameraImage] perform inference on it
  Future<void> onLatestImageAvailable(CameraImage cameraImage) async {
    if (classifier?.interpreter != null && classifier?.labels != null) {
      // If previous inference has not completed then return
      if (predicting!) {
        return;
      }

      setState(() {
        predicting = true;
      });

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

      final uiThreadInferenceElapsedTime =
          DateTime.now().millisecondsSinceEpoch - uiThreadTimeStart;

      // pass results to HomeView
      widget.resultsCallback(
        inferenceResults['recognitions'] as List<Recognition>,
      );

      // pass stats to HomeView
      widget.statsCallback(
        (inferenceResults['stats'] as Stats)
          ..totalElapsedTime = uiThreadInferenceElapsedTime,
      );

      // set predicting to false to allow new frames
      setState(() {
        predicting = false;
      });
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
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.paused:
        await cameraController?.stopImageStream();
        break;
      case AppLifecycleState.resumed:
        if (!cameraController!.value.isStreamingImages) {
          await cameraController?.startImageStream(onLatestImageAvailable);
        }
      // break;
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
