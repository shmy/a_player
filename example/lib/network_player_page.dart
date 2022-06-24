import 'package:a_player/a_player.dart';
import 'package:a_player/a_player_network_controller.dart';
import 'package:a_player/a_player_value.dart';
import 'package:flutter/material.dart';

class NetworkPlayerPage extends StatefulWidget {
  const NetworkPlayerPage({Key? key}) : super(key: key);

  @override
  State<NetworkPlayerPage> createState() => _NetworkPlayerPageState();
}

class _NetworkPlayerPageState extends State<NetworkPlayerPage> {
  late final APlayerNetworkController controller;

  @override
  void initState() {
    controller = APlayerNetworkController()
      ..initialize().then((_) {
        controller.setDataSouce("https://vfx.mtime.cn/Video/2019/03/12/mp4/190312083533415853.mp4");
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
        title: const Text('NetworkPlayerPage'),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 220,
            width: double.infinity,
            child: APlayer(controller: controller),
          ),
          Expanded(
              child: ListView(
            children: [
              MaterialButton(
                  onPressed: () => controller.setDataSouce(
                      "https://vfx.mtime.cn/Video/2019/02/04/mp4/190204084208765161.mp4"),
                  child: const Text('Switch')),
              MaterialButton(
                  onPressed: () => controller.play(),
                  child: const Text('Play')),
              MaterialButton(
                  onPressed: () => controller.setFit(APlayerFit.fitDefault),
                  child: const Text('auto')),
              MaterialButton(
                  onPressed: () => controller.setFit(APlayerFit.fit16x9),
                  child: const Text('16 / 9')),
              MaterialButton(
                  onPressed: () => controller.setFit(APlayerFit.fit4x3),
                  child: const Text('4 / 3')),
              MaterialButton(
                  onPressed: () => controller.setFit(APlayerFit.fit1x1),
                  child: const Text('1 / 1')),
              MaterialButton(
                  onPressed: () => controller.pause(),
                  child: const Text('Pause')),
              MaterialButton(
                  onPressed: () => controller.setSpeed(3.0),
                  child: const Text('Set speed 3.0')),
              MaterialButton(
                  onPressed: () => controller.seekTo(10 * 1000),
                  child: const Text('Seek to 30s')),
              MaterialButton(
                  onPressed: () => controller.setMirrorMode(0),
                  child: const Text('setMirrorMode 0')),
              MaterialButton(
                  onPressed: () => controller.setMirrorMode(1),
                  child: const Text('setMirrorMode 1')),
              MaterialButton(
                  onPressed: () => controller.setMirrorMode(2),
                  child: const Text('setMirrorMode 2')),
              MaterialButton(
                  onPressed: () => controller.setLoop(true),
                  child: const Text('setLoop')),
              MaterialButton(
                  onPressed: () => controller.setHardwareDecoderEnable(false),
                  child: const Text('setHardwareDecoderEnable false')),
              MaterialButton(
                  onPressed: () => controller.setHardwareDecoderEnable(true),
                  child: const Text('setHardwareDecoderEnable true')),
              MaterialButton(
                  onPressed: () => controller.dispose(),
                  child: const Text('dispose')),
            ],
          ))
        ],
      ),
    );
  }
}
