import 'package:a_player/a_player_value.dart';
import 'package:a_player_example/local_widgets/att_video_player.dart';
import 'package:a_player_example/local_widgets/att_video_player_constant.dart';
import 'package:a_player_example/local_widgets/att_video_player_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NetworkPlayerPage extends StatefulWidget {
  const NetworkPlayerPage({Key? key}) : super(key: key);

  @override
  State<NetworkPlayerPage> createState() => _NetworkPlayerPageState();
}

class _NetworkPlayerPageState extends State<NetworkPlayerPage> {
  late final AttVideoPlayerController controller;

  @override
  void initState() {
    controller = AttVideoPlayerController()
      ..setBlockAutoPlayCallback(() {
        // 激励广告
        // 弹窗广告
        Get.defaultDialog(
          onConfirm: () {
            Get.back();
            controller.play();
          },
        );
      })
      ..setVideoAnalyzerCallback((AttVideoItem item) async {
        await Future.delayed(const Duration(seconds: 1));
        return AttVideoAnalysisResult(
          isSuccess: true,
          url: item.source,
          headers: [],
          kernel: APlayerKernel.ijk,
          position: 0,
          reason: '',
          playable: true,
          duration: 0,
        );
      })
      ..initialize().then((value) {
        controller
          ..setPlaylist([
            AttVideoItem(
                'https://vfx.mtime.cn/Video/2019/02/04/mp4/190204084208765161.mp4',
                '惊奇队长', {}),
            AttVideoItem(
                'https://vfx.mtime.cn/Video/2019/03/21/mp4/190321153853126488.mp4',
                '--', {}),
            AttVideoItem(
                'https://vfx.mtime.cn/Video/2019/03/19/mp4/190319222227698228.mp4',
                '紧急救援', {}),
          ])
          ..playByIndex(2);
      });
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        children: [
          AttVideoPlayer(
            controller: controller,
          ),
          Expanded(child: ListView(
            children: [
              Obx(() {
                return Text(controller.uiController.status.value.name);
              }),
              Obx(() {
                return Text('duration: ${controller.uiController.duration.value}');
              }),
              Obx(() {
                return Text('position: ${controller.uiController.position.value}');
              }),
              Obx(() {
                return Text('playSpeed: ${controller.uiController.playSpeed.value}');
              }),
              MaterialButton(onPressed: () {controller.playByIndex(0);}, child: Text('0'),),
              MaterialButton(onPressed: () {controller.playByIndex(1);}, child: Text('1'),),
              MaterialButton(onPressed: () {controller.playByIndex(2);}, child: Text('2'),),
            ],
          )),
        ],
      ),
    );
  }
}
