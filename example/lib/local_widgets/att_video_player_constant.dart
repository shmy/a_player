import 'package:a_player/a_player_constant.dart';
import 'package:a_player/a_player_value.dart';

enum AttVideoPlayerStatus {
  idle,
  initializing,
  initialized,
  analyzing,
  analysisFailed,
  preparing,
  prepared,
  loadingBegin,
  loadingProgress,
  loadingEnd,
  playing,
  playFailed,
  playCompleted,
}

class AttVideoItem<T> {
  final String source;
  final String title;
  final T extra;

  AttVideoItem(this.source, this.title, this.extra);
}

class AttVideoAnalysisResults {
  final bool isSuccess;
  final String url;
  final List<APlayerConfigHeader> headers;
  final APlayerKernel kernel;
  final int position;

  // final List<DanmakuItem> danmakuList;
  AttVideoAnalysisResults({
    required this.isSuccess,
    required this.url,
    required this.headers,
    required this.kernel,
    required this.position,
  });
}
typedef AttVideoAnalyzer = Future<AttVideoAnalysisResults> Function(AttVideoItem item);
