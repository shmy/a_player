// 弹幕主场景
import 'package:flutter/material.dart';
import 'config.dart';
import 'flutter_danmaku_bullet.dart';
import 'flutter_danmaku_controller.dart';

class FlutterDanmakuArea extends StatefulWidget {
  const FlutterDanmakuArea(
      {Key? key, required this.controller, this.bulletTapCallBack})
      : super(key: key);

  final FlutterDanmakuController controller;

  final Function(FlutterDanmakuBulletModel)? bulletTapCallBack;

  @override
  State<FlutterDanmakuArea> createState() => FlutterDanmakuAreaState();
}

class FlutterDanmakuAreaState extends State<FlutterDanmakuArea> {
  FlutterDanmakuController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    controller.setStateList.add(setState);
  }
  @override
  void dispose() {
    controller.setStateList.remove(setState);
    super.dispose();
  }

  // 构建全部的子弹
  List<Widget> buildAllBullet(BuildContext context) {
    return List.generate(controller.bullets.length,
        (index) => buildBulletToScreen(context, controller.bullets[index]));
  }

  // 构建子弹
  Widget buildBulletToScreen(
      BuildContext context, FlutterDanmakuBulletModel bulletModel) {
    FlutterDanmakuBullet bullet = FlutterDanmakuBullet(
      text: bulletModel.text,
      danmakuId: bulletModel.id,
      color: bulletModel.color,
      builder: bulletModel.builder,
    );
    return Positioned(
        right: bulletModel.offsetX,
        top: bulletModel.offsetY + FlutterDanmakuConfig.areaOfChildOffsetY,
        child: FlutterDanmakuConfig.bulletTapCallBack == null
            ? bullet
            : GestureDetector(
                onTap: () =>
                    FlutterDanmakuConfig.bulletTapCallBack?.call(bulletModel),
                child: bullet));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: FlutterDanmakuConfig.areaSize.height,
      width: FlutterDanmakuConfig.areaSize.width,
      child: Stack(
        children: [...buildAllBullet(context)],
      ),
    );
  }
}
