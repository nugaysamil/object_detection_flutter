import 'package:deneeme_tflite_new/tflite/recognition.dart';
import 'package:deneeme_tflite_new/tflite/stats.dart';
import 'package:deneeme_tflite_new/ui/box_widget.dart';
import 'package:deneeme_tflite_new/ui/camera_view_singleton.dart';
import 'package:flutter/material.dart';

import 'camera_view.dart';

/// [HomeView] stacks [CameraView] and [BoxWidget]s with bottom sheet for stats
class HomeView extends StatefulWidget { //statefulwidget-> mutable state that can change later
  @override
  // ignore: library_private_types_in_public_api
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  /// Results to draw bounding boxes
  List<Recognition>? results;

  /// Realtime stats
  Stats? stats;

  /// Scaffold Key
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey(); //for the material design visual lyout

  @override
  Widget build(BuildContext context) { //defines UI for homeview. uses scaffold widget
  //as main container with a black container

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.black,
      body: Stack(
        children: <Widget>[
          CameraView(resultsCallback, statsCallback), //displaying camera view
          //takes callback functions

          // Bounding boxes
          boundingBoxes(results ?? []), //tack of bounding boxes 
          //(likely drawn on top of the camera view) based on the recognition results.

          // Heading
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              padding: EdgeInsets.only(top: 60),
              child: Text(
                '',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrangeAccent.withOpacity(0.6),
                ),
              ),
            ),
          ),

          // Bottom Sheet
          Align(
            alignment: Alignment.bottomCenter,
            child: DraggableScrollableSheet(
              initialChildSize: 0.4,
              minChildSize: 0.1,
              maxChildSize: 0.5,
              builder: (_, ScrollController scrollController) => Container(
                width: double.maxFinite,
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BORDER_RADIUS_BOTTOM_SHEET),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.keyboard_arrow_up,
                            size: 48, color: Colors.orange),
                        if (stats != null)
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              children: [
                                StatsRow(
                                  'Inference time:',
                                  '${stats?.inferenceTime} ms',
                                ),
                                StatsRow(
                                  'Total prediction time:',
                                  '${stats?.totalElapsedTime} ms',
                                ),
                                StatsRow(
                                  'Pre-processing time:',
                                  '${stats?.preProcessingTime} ms',
                                ),
                                StatsRow(
                                  'Frame',
                                  // ignore: lines_longer_than_80_chars
                                  '${CameraViewSingleton.inputImageSize?.width} X ${CameraViewSingleton.inputImageSize?.height}',
                                ),
                              ],
                            ),
                          )
                        else
                          const Text('Error getting stats'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Returns Stack of bounding boxes
  Widget boundingBoxes(List<Recognition> results) {
    //The boundingBoxes method takes a list of recognition results and returns a Stack of BoxWidget instances. 
    //It iterates over the recognition results and creates a BoxWidget for each recognition, presumably to draw bounding boxes on the screen.
    // ignore: unnecessary_null_comparison
    if (results == null) {
      return Container();
    }
    return Stack(
      children: results
          .map(
            (e) => BoxWidget(
              result: e,
            ),
          )
          .toList(),
    );
  }

  /// Callback to get inference results from [CameraView]
  void resultsCallback(List<Recognition> results) { //resultsCallback and statsCallback are callback functions used to update 
  //the state of _HomeViewState with new recognition results and stats received from the CameraView.
    setState(() {
      this.results = results;
    });
  }

  /// Callback to get inference stats from [CameraView]
  void statsCallback(Stats stats) {
    setState(() {
      this.stats = stats;
    });
  }

  static const BOTTOM_SHEET_RADIUS = Radius.circular(24.0);
  static const BORDER_RADIUS_BOTTOM_SHEET = BorderRadius.only(
      topLeft: BOTTOM_SHEET_RADIUS, topRight: BOTTOM_SHEET_RADIUS);
}

/// Row for one Stats field
class StatsRow extends StatelessWidget { //StatsRow is a simple stateless widget that represents a 
//row for displaying statistics. It takes a left and right string and displays them in a row with space between them.
  final String left;
  final String right;

  StatsRow(this.left, this.right);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(left), Text(right)],
      ),
    );
  }
}
