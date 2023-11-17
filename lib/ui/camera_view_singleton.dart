import 'dart:ui';

/// Singleton to record size related data
class CameraViewSingleton {
  static Size? inputImageSize;
  static double? ratio;
  static Size? screenSize;

  static Size? get actualPreviewSize =>
      Size(screenSize!.width, screenSize!.width * ratio!);
}
