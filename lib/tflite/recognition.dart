import 'dart:math';

import 'package:deneeme_tflite_new/ui/camera_view_singleton.dart';
import 'package:flutter/cupertino.dart';

/// Represents the recognition output from the model
class Recognition {
  // ignore: public_member_api_docs
  Recognition(this._id, this._label, this._score, this._location);

  /// Index of the result
  final int _id;

  /// Label of the result
  final String _label;

  /// Confidence [0.0, 1.0]
  final double _score;

  /// Location of bounding box rect
  ///
  /// The rectangle corresponds to the raw input image
  /// passed for inference
  final Rect _location;

  // ignore: public_member_api_docs
  int get id => _id;

  // ignore: public_member_api_docs
  String get label => _label;

  // ignore: public_member_api_docs
  double get score => _score;

  // ignore: public_member_api_docs
  Rect get location => _location;

  /// Returns bounding box rectangle corresponding to the
  /// displayed image on screen
  ///
  /// This is the actual location where rectangle is rendered on
  /// the screen
  Rect get renderLocation {
    //is responsible for calculating the location of the bounding box in the rendered image on the screen. This method performs 
    //transformations to adapt the bounding box coordinates from the raw input image passed for inference to the actual location where the 
    //rectangle is rendered on the screen.

    // ratioX = screenWidth / imageInputWidth
    // ratioY = ratioX if image fits screenWidth with aspectRatio = constant

    final ratioX = CameraViewSingleton.ratio;
    final ratioY = ratioX;

    final transLeft = max(0.1, location.left * ratioX!);
    final transTop = max(0.1, location.top * ratioY!);
    final transWidth = min(
      location.width * ratioX,
      CameraViewSingleton.actualPreviewSize!.width,
    );
    final transHeight = min(
      location.height * ratioY,
      CameraViewSingleton.actualPreviewSize!.height,
    );

    final transformedRect =
        Rect.fromLTWH(transLeft, transTop, transWidth, transHeight);
    return transformedRect;
  }
  //renderLocation method is crucial for adapting the bounding box coordinates from the raw input image dimensions
  //to the actual location where the rectangle is displayed on the screen, considering the screen size and aspect ratio. 
  //This ensures that the bounding box is correctly positioned and sized relative to the rendered image on the user interface.

  @override
  String toString() {
    // ignore: lines_longer_than_80_chars
    return 'Recognition(id: $id, label: $label, score: $score, location: $location)';
  }
}
