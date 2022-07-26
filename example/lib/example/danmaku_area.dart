import 'package:a_player_example/example/video_player_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../danmaku/src/flutter_danmaku_area.dart';
import '../danmaku/src/flutter_danmaku_controller.dart';

class DanmakuArea extends StatefulWidget {
  final VideoPlayerController controller;
  final Duration position;
  final bool isFullscreen;

  const DanmakuArea(
      {Key? key,
      required this.controller,
      required this.position,
      required this.isFullscreen})
      : super(key: key);

  @override
  State<DanmakuArea> createState() => _DanmakuAreaState();
}

class _DanmakuAreaState extends State<DanmakuArea>
    with SingleTickerProviderStateMixin {
  VideoPlayerController get controller => widget.controller;

  FlutterDanmakuController get flutterDanmakuController =>
      widget.controller.flutterDanmakuController;

  double get position => widget.position.inMilliseconds.toDouble();

  bool get isFullscreen => widget.isFullscreen;

  Ticker? ticker;

  Size get size {
    if (!mounted) {
      return Size.zero;
    }

    return isFullscreen
        ? MediaQuery.of(context).size
        : Size(MediaQuery.of(context).size.width, 220);
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ticker = createTicker((elapsed) {
        if (controller.flutterDanmakuController.isPause){
          return;
        }
        if (controller.danIndex == -1) {
          return;
        }
        if (controller.danIndex > controller.danmakuList.length - 1) {
          return;
        }
        final item = controller.danmakuList[controller.danIndex];
        if (position > item.duration) {
          flutterDanmakuController.addDanmaku(
            item.content,
            color: item.color,
            bulletType: item.bulletType,
          );
          controller.danIndex++;
        }
      });
      ticker?.start();
    });
    super.initState();
  }

  @override
  void dispose() {
    ticker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: FlutterDanmakuArea(key: const Key('1'), controller: flutterDanmakuController),
    );
  }
}
