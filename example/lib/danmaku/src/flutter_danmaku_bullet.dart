// 弹幕子弹
import 'package:flutter/material.dart';
import 'config.dart';
import 'flutter_danmaku_track.dart';
import 'flutter_danmaku_utils.dart';

enum FlutterDanmakuBulletType { scroll, fixed }

enum FlutterDanmakuBulletPosition { any, bottom }

class FlutterDanmakuBulletModel {
  late UniqueKey id;
  late UniqueKey trackId;
  UniqueKey? prevBulletId;
  late Size bulletSize;
  late String text;
  late double offsetY;
  late double _runDistance = 0;
  late double everyFrameRunDistance;
  Color color = Colors.black;
  FlutterDanmakuBulletPosition position = FlutterDanmakuBulletPosition.any;

  Widget Function(Text)? builder;

  FlutterDanmakuBulletType bulletType;

  /// 子弹的x轴位置
  double get offsetX => bulletType == FlutterDanmakuBulletType.scroll
      ? _runDistance - bulletSize.width
      : FlutterDanmakuConfig.areaSize.width / 2 - (bulletSize.width / 2);

  /// 子弹最大可跑距离 子弹宽度+墙宽度
  double get maxRunDistance =>
      bulletSize.width + FlutterDanmakuConfig.areaSize.width;

  /// 子弹整体脱离右边墙壁
  bool get allOutRight => _runDistance > bulletSize.width;

  /// 子弹整体离开屏幕
  bool get allOutLeave => _runDistance > maxRunDistance;

  /// 子弹当前执行的距离
  double get runDistance => _runDistance;

  /// 剩余离开的距离
  double get remanderDistance => needRunDistace - runDistance;

  /// 需要走的距离
  double get needRunDistace =>
      FlutterDanmakuConfig.areaSize.width + bulletSize.width;

  /// 离开屏幕剩余需要的时间
  double get leaveScreenRemainderTime =>
      remanderDistance / everyFrameRunDistance;

  /// 子弹执行下一帧
  void runNextFrame() {
    _runDistance += everyFrameRunDistance * FlutterDanmakuConfig.bulletRate;
  }

  // 重新绑定轨道
  void rebindTrack(FlutterDanmakuTrack track) {
    offsetY = track.offsetTop;
    trackId = track.id;
  }

  // 计算文字尺寸
  void completeSize() {
    bulletSize = FlutterDanmakuUtils.getDanmakuBulletSizeByText(text);
  }

  FlutterDanmakuBulletModel({
    required this.id,
    required this.trackId,
    required this.text,
    required this.bulletSize,
    required this.offsetY,
    this.bulletType = FlutterDanmakuBulletType.scroll,
    required this.color,
    this.prevBulletId,
    this.builder,
    required this.position,
    int? offsetMS,
  }) {
    everyFrameRunDistance =
        FlutterDanmakuUtils.getBulletEveryFramerateRunDistance(
            bulletSize.width);
    _runDistance = offsetMS != null
        ? (offsetMS / FlutterDanmakuConfig.unitTimer) * everyFrameRunDistance
        : 0;
  }
}

class FlutterDanmakuBullet extends StatelessWidget {
  const FlutterDanmakuBullet(
      {Key? key,
      required this.danmakuId,
      required this.text,
      this.color = Colors.black,
      this.builder})
      : super(key: key);
  final String text;
  final UniqueKey danmakuId;
  final Color color;

  final Widget Function(Text)? builder;

  /// 构建文字
  Widget buildText() {
    Text textWidget = Text(
      text,
      style: TextStyle(
        fontSize: FlutterDanmakuConfig.bulletLableSize,
        color: color.withOpacity(FlutterDanmakuConfig.opacity),
      ),
    );
    if (builder != null) {
      return builder!(textWidget);
    }
    return textWidget;
  }

  /// 构建描边文字
  Widget buildStrokeText() {
    Text textWidget = Text(
      text,
      style: TextStyle(
        fontSize: FlutterDanmakuConfig.bulletLableSize,
        foreground: Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5
          ..color = Colors.white.withOpacity(FlutterDanmakuConfig.opacity),
      ),
    );
    if (builder != null) {
      return builder!(textWidget);
    }
    return textWidget;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        // Stroked text as border.
        buildStrokeText(),
        // Solid text as fill.
        buildText()
      ],
    );
  }
}
