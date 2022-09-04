import 'package:a_player_example/local_widgets/att_video_player.dart';
import 'package:a_player_example/local_widgets/att_video_player_controller.dart';
import 'package:flutter/material.dart';

class NetworkPlayerPage extends StatefulWidget {
  const NetworkPlayerPage({Key? key}) : super(key: key);

  @override
  State<NetworkPlayerPage> createState() => _NetworkPlayerPageState();
}

class _NetworkPlayerPageState extends State<NetworkPlayerPage> {
  late final AttVideoPlayerController controller;

  @override
  void initState() {
    controller = AttVideoPlayerController();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Network'),
      ),
      body: AttVideoPlayer(
        controller: controller,
      ),
    );
  }
}
