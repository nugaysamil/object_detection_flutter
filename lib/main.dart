import 'package:camera/camera.dart';
import 'package:deneeme_tflite_new/ui/camera_view.dart';
import 'package:deneeme_tflite_new/ui/home_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ignore: public_member_api_docs
List<CameraDescription>? cameras;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const MyApp());
}

// ignore: public_member_api_docs
class MyApp extends StatelessWidget {
  // ignore: public_member_api_docs
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
