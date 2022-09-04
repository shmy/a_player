import 'package:a_player/a_player.dart';
import 'package:a_player/a_player_controller.dart';
import 'package:flutter/material.dart';

class AttVideoPlayerTitleAd extends StatefulWidget {
  final String url;
  final VoidCallback onDone;
  final VoidCallback onError;
  final int minTime;

  const AttVideoPlayerTitleAd({
    Key? key,
    required this.url,
    required this.onDone,
    required this.onError,
    this.minTime = 3,
  }) : super(key: key);

  @override
  State<AttVideoPlayerTitleAd> createState() => _AttVideoPlayerTitleAdState();
}

class _AttVideoPlayerTitleAdState extends State<AttVideoPlayerTitleAd> {
  final APlayerController controller = APlayerController();
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  int? get remings {
    if (duration == Duration.zero) {
      return null;
    }
    return duration.inSeconds - position.inSeconds;
  }

  bool get skipable {
    if (remings == null) {
      return false;
    }
    return duration.inSeconds - remings! >= widget.minTime;
  }

  @override
  void initState() {
    controller.onReadyToPlay.addListener(() {
      controller.play();
      setState(() {
        duration =
            Duration(milliseconds: controller.onReadyToPlay.value.duration);
      });
    });
    controller.onCurrentPositionChanged.addListener(() {
      setState(() {
        position =
            Duration(milliseconds: controller.onCurrentPositionChanged.value);
      });
    });
    controller.onError.addListener(() {
      widget.onDone.call();
    });
    controller.onCompletion.addListener(() {
      widget.onDone.call();
    });
    controller.initialize().then((value) => _setupPlayer());
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _setupPlayer() async {
    await controller.setDataSouce(widget.url);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: APlayer(controller: controller)),
        if (remings != null)
          Positioned(
            top: 20,
            right: 20,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (skipable) {
                  widget.onDone();
                }
              },
              child: Text(
                '$remings ${skipable ? ' | 跳过' : ''}',
              ),
            ),
          ),
      ],
    );
  }
}
