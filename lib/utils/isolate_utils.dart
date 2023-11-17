// ignore_for_file: public_member_api_docs, unused_field

import 'dart:io';
import 'dart:isolate';
import 'package:camera/camera.dart';
import 'package:deneeme_tflite_new/tflite/classifier.dart';
import 'package:deneeme_tflite_new/utils/image_utils.dart';
import 'package:image/image.dart' as imageLib;
import 'package:tflite_flutter/tflite_flutter.dart';

/// Manages separate Isolate instance for inference
class IsolateUtils {
  // ignore: constant_identifier_names
  static const String DEBUG_NAME = 'InferenceIsolate';

  // ignore: use_late_for_private_fields_and_variables
  Isolate? _isolate;
  ReceivePort? _receivePort = ReceivePort();
  SendPort? _sendPort;

  SendPort? get sendPort => _sendPort;

  Future<void> start() async {
    _isolate = await Isolate.spawn<SendPort>(
      entryPoint,
      _receivePort!.sendPort,
      debugName: DEBUG_NAME,
    );

    _sendPort = await _receivePort!.first as SendPort?;
  }

  // ignore: public_member_api_docs
  static Future<void> entryPoint(SendPort sendPort) async {
    final port = ReceivePort();
    sendPort.send(port.sendPort);

    await for (final IsolateData isolateData in port.cast<IsolateData>()) {
      final classifier = Classifier(
        interpreter: Interpreter.fromAddress(isolateData.interpreterAddress!),
        labels: isolateData.labels,
      );
      var image = ImageUtils.convertCameraImage(isolateData.cameraImage!);

      /* imageLib.Image? image =
          ImageUtils.convertCameraImage(isolateData.cameraImage!); */

      if (Platform.isAndroid) {
        image = imageLib.copyRotate(image!, angle: 90);
      }
      final results = classifier.predict(image!);
      isolateData.responsePort!.send(results);
    }
  }
}

/// Bundles data to pass between Isolate
class IsolateData {
  IsolateData(
    this.cameraImage,
    this.interpreterAddress,
    this.labels,
  );
  CameraImage? cameraImage;
  int? interpreterAddress;
  List<String>? labels;
  SendPort? responsePort;
}
