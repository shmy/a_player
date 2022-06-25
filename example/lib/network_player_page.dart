import 'package:a_player_example/example/video_player.dart';
import 'package:a_player_example/example/video_player_controller.dart';
import 'package:flutter/material.dart';

class NetworkPlayerPage extends StatefulWidget {
  const NetworkPlayerPage({Key? key}) : super(key: key);

  @override
  State<NetworkPlayerPage> createState() => _NetworkPlayerPageState();
}

class _NetworkPlayerPageState extends State<NetworkPlayerPage> {
  late final VideoPlayerController controller;

  @override
  void initState() {
    controller = VideoPlayerController()
      ..initialize().then((value) {
        controller
          ..setPlaylist([
            VideoPlayerItem(
                'https://video.pddugc.com/backbone-video/2022-06-21/9d29d0f5668c0f5c1256748b3386313d.mp4',
                '奇艺博士2 高清',
                ''),
            VideoPlayerItem(
                'https://g.gszyvv.com:65/20220506/aU8xJQ47/index.m3u8',
                '奇艺博士2 TC',
                ''),
            VideoPlayerItem(
                'https://vfx.mtime.cn/Video/2019/02/04/mp4/190204084208765161.mp4',
                '预告片',
                ''),
            VideoPlayerItem(
                'https://g.gszyvv.com:65/20220619/ytW2Mt0c/index.m3u8',
                '未命名',
                ''),
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
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            VideoPlayer(controller: controller),
          ],
        ),
      ),
    );
  }
}
