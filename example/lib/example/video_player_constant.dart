
import 'package:flutter/material.dart';

import '../danmaku/src/flutter_danmaku_bullet.dart';

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