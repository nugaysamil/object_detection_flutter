import 'package:deneeme_tflite_new/tflite/recognition.dart';
import 'package:flutter/material.dart';

/// Individual bounding box
class BoxWidget extends StatelessWidget {
  const BoxWidget({Key? key, required this.result}) : super(key: key);

  // ignore: public_member_api_docs
  final Recognition result;

  @override
  Widget build(BuildContext context) {
    // Color for bounding box
    final color = Colors.primaries[
        (result.label.length + result.label.codeUnitAt(0) + result.id) %
            Colors.primaries.length];

    return Positioned(
      left: result.renderLocation.left,
      top: result.renderLocation.top,
      width: result.renderLocation.width,
      height: result.renderLocation.height,
      child: Container(
        width: result.renderLocation.width,
        height: result.renderLocation.height,
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 3),
          borderRadius: const BorderRadius.all(Radius.circular(2)),
        ),
        child: Align(
          alignment: Alignment.topLeft,
          child: FittedBox(
            // ignore: use_colored_box
            child: Container(
              color: color,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(result.label),
                  Text(' ${result.score.toStringAsFixed(2)}'),
                  // Text(" " + result.score.toStringAsFixed(2)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
