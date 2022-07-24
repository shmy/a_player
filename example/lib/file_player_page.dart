import 'package:a_player/a_player_value.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'example/video_player.dart';
import 'example/video_player_controller.dart';

class FilePlayerPage extends StatefulWidget {
  const FilePlayerPage({Key? key}) : super(key: key);

  @override
  State<FilePlayerPage> createState() => _FilePlayerPageState();
}

class _FilePlayerPageState extends State<FilePlayerPage> {
  late final VideoPlayerController controller;
  @override
  void initState() {
    controller = VideoPlayerController()..setResolver((item) async {
      final file = await DefaultCacheManager().getSingleFile(item.source);
      return VideoSourceResolve(true, 'file://' + file.path, [], APlayerKernel.aliyun);
    })
      ..initialize(
        userMaxSpeed: 2.0
      ).then((value) {
        controller
          ..setPlaylist([
            VideoPlayerItem(
                'https://vfx.mtime.cn/Video/2019/02/04/mp4/190204084208765161.mp4',
                '惊奇队长 预告片[mp4]',
                ''),
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
    return Scaffold(
      appBar: AppBar(title: const Text('File')),
      body: Column(
        children: [
          VideoPlayer(controller: controller),
        ],
      ),
    );
  }
}
