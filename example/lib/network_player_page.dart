import 'package:a_player/a_player.dart';
import 'package:a_player/a_player_controller.dart';
import 'package:a_player/a_player_value.dart';
import 'package:flutter/material.dart';

class NetworkPlayerPage extends StatefulWidget {
  const NetworkPlayerPage({Key? key}) : super(key: key);

  @override
  State<NetworkPlayerPage> createState() => _NetworkPlayerPageState();
}

class _NetworkPlayerPageState extends State<NetworkPlayerPage> {
  late final APlayerController controller;

  @override
  void initState() {
    controller = APlayerController()..initialize().then((value) async {
      await controller.setKernel(APlayerKernel.aliyun);
      await controller.setDataSouce('https://vfx.mtime.cn/Video/2019/02/04/mp4/190204084208765161.mp4');
    });
    controller.stream.listen((event) {
      print('isInitialized: ${event.isInitialized}, isReadyToPlay: ${event.isReadyToPlay}');
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
      appBar: AppBar(
        title: const Text('Network'),
      ),
      body: APlayer(
        controller: controller,
      ),
    );
  }
}
