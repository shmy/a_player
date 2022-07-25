import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'danmaku/src/flutter_danmaku_area.dart';
import 'danmaku/src/flutter_danmaku_bullet.dart';
import 'danmaku/src/flutter_danmaku_controller.dart';
import 'data.dart';

class DanmakuItem {
  final double duration;
  final String content;
  final Color color;
  final FlutterDanmakuBulletType bulletType;

  DanmakuItem({
    required this.duration,
    required this.content,
    required this.color,
    required this.bulletType,
  });

  @override
  String toString() {
    return 'DanmakuItem(duration: $duration, content: $content)';
  }
}

class DanmakuPage extends StatefulWidget {
  const DanmakuPage({Key? key}) : super(key: key);

  @override
  State<DanmakuPage> createState() => _DanmakuPageState();
}

class _DanmakuPageState extends State<DanmakuPage>
    with SingleTickerProviderStateMixin {
  FlutterDanmakuController flutterDanmakuController =
      FlutterDanmakuController();
  final List<DanmakuItem> data =
      (danmakuData['data'] as dynamic).map<DanmakuItem>((e) {
    return DanmakuItem(
        content: e[4],
        duration: (e[0] * 1000).toDouble(),
        color: Colors.white,
        bulletType: e[1] == 0
            ? FlutterDanmakuBulletType.scroll
            : FlutterDanmakuBulletType.fixed);
  }).toList();
  Timer? timer;
  Ticker? ticker;
  double position = 0.0;
  int danIndex = 0;

  @override
  void initState() {
    data.sort((a, b) {
      return (a.duration - b.duration).toInt();
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      flutterDanmakuController
          .init(Size(MediaQuery.of(context).size.width, 220));
      timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        position += 1000;
      });
      ticker = createTicker((elapsed) {
        final item = data[danIndex];
        if (item != null && item.duration <= position) {
          flutterDanmakuController.addDanmaku(
            item.content,
            color: item.color,
            bulletType: item.bulletType,
          );
          danIndex++;
        }
      });
      ticker?.start();
    });
    super.initState();
  }

  @override
  void dispose() {
    flutterDanmakuController.dispose();
    timer?.cancel();
    ticker?.dispose();
    super.dispose();
  }

  void addDanmaku() {
    flutterDanmakuController.addDanmaku(
      data[0].content,
      color: data[0].color,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Danmaku')),
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              color: Colors.black,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: FlutterDanmakuArea(
                        controller: flutterDanmakuController),
                  ),
                ],
              ),
            ),
          ),
          MaterialButton(
            onPressed: () => flutterDanmakuController.pause(),
            child: Text('pause'),
          ),
          MaterialButton(
            onPressed: () => flutterDanmakuController.play(),
            child: Text('play'),
          ),
          MaterialButton(
            onPressed: () {
              flutterDanmakuController.play();
              flutterDanmakuController.clearScreen();
            },
            child: Text('clear'),
          ),
        ],
      ),
    );
  }
}
