import 'package:a_player/a_player_constant.dart';
import 'package:a_player/a_player_value.dart';

enum AttVideoPlayerStatus {
  idle, // 空闲
  initializing, // 初始化中
  initialized, // 已初始化
  analyzing, // 解析中
  analysisFailed, // 解析失败
  nonPlayable, // 不可播放
  tryItToEnd, // 试看结束
  preparing, // 准备中
  prepared, // 准备完毕
  loadingBegin, // 开始缓冲
  loadingProgress, // 缓冲进度
  loadingEnd, // 缓冲结束
  playing, // 播放中
  playFailed, // 播放失败
  playCompleted, // 播放结束
}

class AttVideoItem<T> {
  final String source;
  final String title;
  final T extra;

  AttVideoItem(this.source, this.title, this.extra);
}

class AttVideoAnalysisResult {
  final bool isSuccess;
  final String url;
  final List<APlayerConfigHeader> headers;
  final APlayerKernel kernel;

  // 从哪里开始播放 ms
  final int position;

  // 是否可以播放
  final bool playable;

  // 不能播放的原因
  final String reason;

  // 可播放的最大长度 ms 0 为不限制
  final int duration;

  // final List<DanmakuItem> danmakuList;
  AttVideoAnalysisResult({
    required this.isSuccess,
    required this.url,
    required this.headers,
    required this.kernel,
    required this.position,
    required this.playable,
    required this.reason,
    required this.duration,
  });
}

typedef AttVideoAnalyzer = Future<AttVideoAnalysisResult> Function(
    AttVideoItem item);
