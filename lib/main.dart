import 'package:camera/camera.dart';
import 'package:deneeme_tflite_new/ui/home_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

List<CameraDescription>? cameras;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    cameras = await availableCameras();
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  } on CameraException catch (e) {
    print('Camera not initialize $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Object Detection TFLite',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomeView(),
    );
  }
}
