import 'package:a_player/a_player.dart';
import 'package:a_player_example/local_widgets/att_video_player_controller.dart';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

class AttVideoPlayer extends StatelessWidget {
  final AttVideoPlayerController controller;

  const AttVideoPlayer({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: VisibilityDetector(
        key: const Key('att-player'),
        onVisibilityChanged: (VisibilityInfo info) {
          controller.setVisible(info.visibleFraction != 0.0);
        },
        child: APlayer(
          controller: controller.aPlayerController,
        ),
      ),
    );
  }
}
