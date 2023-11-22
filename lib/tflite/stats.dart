/// Bundles different elapsed times
// ignore_for_file: public_member_api_docs

class Stats {
  Stats({
    required this.totalPredictTime,
    this.totalElapsedTime, 
    required this.inferenceTime,
    required this.preProcessingTime,
  });

  /// Total time taken in the isolate where the inference runs
  int totalPredictTime;

  /// [totalPredictTime] + communication overhead time
  /// between main isolate and another isolate
  int? totalElapsedTime; 

  /// Time for which inference runs
  int inferenceTime;

  /// Time taken to pre-process the image
  int preProcessingTime;

  @override
  String toString() {
    // ignore: lines_longer_than_80_chars
    return 'Stats{totalPredictTime: $totalPredictTime, totalElapsedTime: $totalElapsedTime, inferenceTime: $inferenceTime, preProcessingTime: $preProcessingTime}';
  }
}
