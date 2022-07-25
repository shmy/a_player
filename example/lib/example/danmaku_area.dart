import 'package:a_player_example/example/video_player_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../danmaku/src/flutter_danmaku_area.dart';
import '../danmaku/src/flutter_danmaku_bullet.dart';
import '../danmaku/src/flutter_danmaku_controller.dart';
import '../data.dart';
import 'video_player_constant.dart';

class DanmakuArea extends StatefulWidget {
  final VideoPlayerController controller;
  final double position;
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

  double get position => widget.position;

  bool get isFullscreen => widget.isFullscreen;
  late final List<DanmakuItem> data;

  Ticker? ticker;

  Size get size {
    if (!mounted) {
      return Size.zero;
    }

    return isFullscreen
        ? MediaQuery.of(context).size
        : Size(MediaQuery.of(context).size.width, 220);
  }

  Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  @override
  void initState() {
    data = (danmakuData['data'] as dynamic).map<DanmakuItem>((e) {
      return DanmakuItem(
          content: e[4],
          duration: (e[0] * 1000).toDouble(),
          color: fromHex(e[3] as String),
          bulletType: e[1] == 0
              ? FlutterDanmakuBulletType.scroll
              : FlutterDanmakuBulletType.fixed);
    }).toList();
    data.sort((a, b) {
      return (a.duration - b.duration).toInt();
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ticker = createTicker((elapsed) {
        final item = data[controller.danIndex];
        if (item != null && item.duration <= position) {
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
      child: FlutterDanmakuArea(controller: flutterDanmakuController),
    );
  }
}
