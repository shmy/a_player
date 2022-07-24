import 'dart:async';

import 'package:flutter/material.dart';

class DanmakuItem {
  final int duration;
  final String content;

  DanmakuItem({
    required this.duration,
    required this.content,
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

class _DanmakuPageState extends State<DanmakuPage> {
  final List<DanmakuItem> danmakuList = [
    [2, "right", "#fff", "", ""],
    [6.1, "top", "#FFFFFF", "", ""],
    [
      12.338,
      "right",
      "rgb(255, 255, 255)",
      "5596875",
      "\u5373\u53ef",
      "183.248.114.73",
      "07-13 00:31",
      "27.5px"
    ],
    [
      32.65,
      "right",
      "rgb(255, 255, 255)",
      "5899813",
      "666",
      "110.182.226.59",
      "07-18 00:42",
      "27.5px"
    ],
    [
      33.65,
      "right",
      "rgb(255, 255, 255)",
      "5956029",
      "666",
      "110.182.226.59",
      "07-18 00:42",
      "27.5px"
    ],
    [
      76.53,
      "right",
      "rgb(255, 255, 255)",
      "5968592",
      "\uff1f\uff1f\uff1f\uff1f",
      "123.12.145.82",
      "07-20 10:03",
      "27.5px"
    ]
  ].map((item) {
    return DanmakuItem(
      duration: ((item[0] as num) * 1000).toInt(),
      content: item[4] as String,
    );
  }).toList();
  late final Timer timer;
  double position = 0.0;
  int danIndex = 0;

  @override
  void initState() {
    print(danmakuList);
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      position += 1000.0;
      control();
    });
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void control() {

  }

  void seek() {
    for (int i = 0; i < danmakuList.length; i++) {
      if (danmakuList[i].duration >= position) {
        danIndex = i;
        break;
      }
      danIndex = danmakuList.length;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Danmaku')),
      body: AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          color: Colors.black,
          child: Stack(
            children: [
              Positioned.fill(
                child: DefaultTextStyle(
                  style: TextStyle(color: Colors.white),
                  child: Column(
                    children: [
                      Text('但撒谎撒'),
                      Text('但撒谎撒'),
                      Text('但撒谎撒'),
                      Text('但撒谎撒'),
                      Text('但撒谎撒'),
                      Text('但撒谎撒'),
                      Text('但撒谎撒'),
                      Text('但撒谎撒'),
                      Text('但撒谎撒'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
