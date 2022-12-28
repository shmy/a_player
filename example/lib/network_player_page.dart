import 'package:a_player/a_player_constant.dart';
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
      // ..setBlockAutoPlayCallback(() {
      //   // 激励广告
      //   // 弹窗广告
      //   Get.defaultDialog(
      //     onConfirm: () {
      //       Get.back();
      //       controller.play();
      //     },
      //   );
      // })
      ..setVideoAnalyzerCallback((AttVideoItem item) async {
        await Future.delayed(const Duration(seconds: 1));
        return AttVideoAnalysisResult(
          isSuccess: true,
          url: item.source,
          headers: [
            APlayerConfigHeader("referer", "https://wx.stariverpan.com/")
          ],
          kernel: APlayerKernel.av,
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
                'https://ipfsgw00.stariverpan.com:9095/ipfs/bafybeigidvl27kezpe5g5urdxt3jt7dybqyyqa5ppbxd3tm6bjmtvt2ff4',
                '惊奇队长', {}),
          ])
          ..playByIndex(0);
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
              Obx(() {
                return Text('bufferingPercentage: ${controller.uiController.bufferingPercentage.value}');
              }),
              Obx(() {
                return Text('isBuffering: ${controller.uiController.isBuffering.value}');
              }),
              Obx(() {
                return Text('buffered: ${controller.uiController.buffered.value}');
              }),
              Obx(() {
                return Text('size: ${controller.uiController.height.value} * ${controller.uiController.width.value}');
              }),
              Obx(() {
                return Text('bufferingSpeed: ${controller.uiController.bufferingSpeed.value}');
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
