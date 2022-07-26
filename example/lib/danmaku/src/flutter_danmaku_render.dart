import 'dart:async';

import 'package:flutter/material.dart';
import 'config.dart';
import 'flutter_danmaku_bullet.dart';
import 'flutter_danmaku_controller.dart';

class FlutterDanmakuRenderManager {
  Timer? _timer;

  Timer? get timer => _timer;

  void run(Function nextFrame, VoidCallback refreshState) {
    _timer = Timer.periodic(
        Duration(milliseconds: FlutterDanmakuConfig.unitTimer), (Timer timer) {
      // 暂停不执行
      if (!FlutterDanmakuConfig.pause) {
        nextFrame();
        refreshState();
      }
    });
  }

  void dispose() {
    _timer?.cancel();
  }

  // 渲染下一帧
  List<FlutterDanmakuBulletModel> renderNextFramerate(
      List<FlutterDanmakuBulletModel> bullets,
      Function(UniqueKey) allOutLeaveCallBack) {
    List<FlutterDanmakuBulletModel> newBullets =
        List.generate(bullets.length, (index) => bullets[index]);
    for (var bulletModel in newBullets) {
      bulletModel.runNextFrame();
      if (bulletModel.allOutLeave) {
        allOutLeaveCallBack(bulletModel.id);
      }
    }
    return newBullets;
  }
}
