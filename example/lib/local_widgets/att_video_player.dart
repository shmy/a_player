import 'package:a_player/a_player.dart';
import 'package:a_player_example/local_widgets/att_video_player_constant.dart';
import 'package:a_player_example/local_widgets/att_video_player_controller.dart';
import 'package:a_player_example/local_widgets/att_video_player_ui_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:visibility_detector/visibility_detector.dart';

class AttVideoPlayer extends StatelessWidget {
  final AttVideoPlayerController controller;

  const AttVideoPlayer({Key? key, required this.controller}) : super(key: key);

  AttVideoPlayerUIController get uiController => controller.uiController;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 200,
          child: VisibilityDetector(
            key: const Key('att-player'),
            onVisibilityChanged: (VisibilityInfo info) {
              controller.setVisible(info.visibleFraction != 0.0);
            },
            child: DefaultTextStyle(
              style: const TextStyle(color: Colors.white),
              child: Obx(() {
                if (uiController.isTryItToEnd.value) {
                  return _buildTryItToEnd();
                }
                if (uiController.isCompletion.value) {
                  return _buildPlayCompleted();
                }
                switch (uiController.status.value) {
                  case AttVideoPlayerStatus.idle:
                    return _buildBlackBackground();
                  case AttVideoPlayerStatus.initializing:
                    return _buildInitializing();
                  case AttVideoPlayerStatus.initialized:
                    return _buildBlackBackground();
                  case AttVideoPlayerStatus.analyzing:
                    return _buildAnalyzing();
                  case AttVideoPlayerStatus.analysisFailed:
                    return _buildAnalysisFailed();
                  case AttVideoPlayerStatus.nonPlayable:
                    return _buildNonPlayable();
                  case AttVideoPlayerStatus.preparing:
                    return _buildInitializing();
                  case AttVideoPlayerStatus.readyToPlay:
                    return _buildBlackBackground();
                  case AttVideoPlayerStatus.playFailed:
                    return _buildPlayFailed();
                  default:
                    return APlayer(
                      controller: controller.aPlayerController,
                    );
                }
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBlackBackground({
    Widget? child,
  }) {
    return Container(
      decoration: const BoxDecoration(color: Colors.black),
      child: child,
    );
  }

  Widget _buildInitializing() {
    return _buildBlackBackground(
        child: const Center(child: CircularProgressIndicator()));
  }

  Widget _buildAnalyzing() {
    return _buildBlackBackground(
        child: const Center(child: CircularProgressIndicator()));
  }

  Widget _buildAnalysisFailed() {
    return _buildBlackBackground(child: const Center(child: Text('解析失败')));
  }
  Widget _buildNonPlayable() {
    return _buildBlackBackground(child: const Center(child: Text('无权播放')));
  }
  Widget _buildTryItToEnd() {
    return _buildBlackBackground(child: const Center(child: Text('试看结束')));
  }
  Widget _buildPlayFailed() {
    return _buildBlackBackground(child: const Center(child: Text('播放失败')));
  }
  Widget _buildPlayCompleted() {
    return _buildBlackBackground(child: const Center(child: Text('播放完毕')));
  }
}
