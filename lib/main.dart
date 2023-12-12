import 'package:camera/camera.dart';
import 'package:deneeme_tflite_new/ui/camera_view.dart';
import 'package:deneeme_tflite_new/ui/home_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ignore: public_member_api_docs
List<CameraDescription>? cameras; //nullable list for CameraDescription objects 
//which includes camera description later in the code.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); //flutter binding initialized
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  //screen orientations for the app, here potrait only 

  runApp(const MyApp()); //starting application
}

// ignore: public_member_api_docs
class MyApp extends StatelessWidget {
  // ignore: public_member_api_docs
  const MyApp({super.key}); //constructor takes an optional key parameter for MyApp class

  @override
  Widget build(BuildContext context) { //override build method of the StatelessWidget class.
  //returns the widget tree that represents application UI.
    return MaterialApp(
      debugShowCheckedModeBanner: false, //hiding debug banner
      title: 'Object Detection TFLite',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomeView(), 
    );
  }
}

//StatelessWidget: A StatelessWidget in Flutter represents part of the user interface that can be described in terms of its configuration, but cannot change dynamically over time. The key characteristics of a StatelessWidget are:
//Immutable: Once a StatelessWidget is created, its properties (the data it depends on) cannot be changed. If the widget needs to display different content, a new instance of the widget must be created.
//No Mutable State: StatelessWidget doesn't have an associated mutable state that can change over time in response to user interactions or other events.
//Build Method: The main method in a StatelessWidget is the build method. It describes how the widget should look based on its configuration (properties). The build method is called when the widget is created or when its parent forces it to rebuild.
