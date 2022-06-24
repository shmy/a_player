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
            'https://vfx.mtime.cn/Video/2019/02/04/mp4/190204084208765161.mp4',
            'https://g.gszyvv.com:65/20220619/ytW2Mt0c/index.m3u8',
            'https://v.gszyvv.com:65/20220619/k9xJdBO1/index.m3u8',
            'https://new.iskcd.com/20220429/4UEZuTEh/index.m3u8',
            'https://new.iskcd.com/20220422/e9LNmEMj/index.m3u8',
            'https://m3u8.taopianplay.com/taopian/ecd7f271-487e-48d6-9873-9edc06e79ce8/1e995a1c-d91d-4e6a-8716-2f76f90f9394/47916/40be6fca-f3f7-4078-9c9e-aba8d0a3512b/SD/playlist.m3u8',
          ])
          ..playByIndex(3);
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
            VideoPlayer(
              controller: controller,
            ),
            // Expanded(
            //     child: ListView(
            //   children: [
            //     MaterialButton(
            //         onPressed: () => controller.setDataSouce(
            //             "https://vfx.mtime.cn/Video/2019/02/04/mp4/190204084208765161.mp4"),
            //         child: const Text('Switch')),
            //     MaterialButton(
            //         onPressed: () => controller.play(),
            //         child: const Text('Play')),
            //     MaterialButton(
            //         onPressed: () => controller.setFit(APlayerFit.fitDefault),
            //         child: const Text('auto')),
            //     MaterialButton(
            //         onPressed: () => controller.setFit(APlayerFit.fit16x9),
            //         child: const Text('16 / 9')),
            //     MaterialButton(
            //         onPressed: () => controller.setFit(APlayerFit.fit4x3),
            //         child: const Text('4 / 3')),
            //     MaterialButton(
            //         onPressed: () => controller.setFit(APlayerFit.fit1x1),
            //         child: const Text('1 / 1')),
            //     MaterialButton(
            //         onPressed: () => controller.pause(),
            //         child: const Text('Pause')),
            //     MaterialButton(
            //         onPressed: () => controller.setSpeed(3.0),
            //         child: const Text('Set speed 3.0')),
            //     MaterialButton(
            //         onPressed: () => controller.seekTo(10 * 1000),
            //         child: const Text('Seek to 30s')),
            //     MaterialButton(
            //         onPressed: () => controller.setMirrorMode(0),
            //         child: const Text('setMirrorMode 0')),
            //     MaterialButton(
            //         onPressed: () => controller.setMirrorMode(1),
            //         child: const Text('setMirrorMode 1')),
            //     MaterialButton(
            //         onPressed: () => controller.setMirrorMode(2),
            //         child: const Text('setMirrorMode 2')),
            //     MaterialButton(
            //         onPressed: () => controller.setLoop(true),
            //         child: const Text('setLoop')),
            //     MaterialButton(
            //         onPressed: () => controller.setHardwareDecoderEnable(false),
            //         child: const Text('setHardwareDecoderEnable false')),
            //     MaterialButton(
            //         onPressed: () => controller.setHardwareDecoderEnable(true),
            //         child: const Text('setHardwareDecoderEnable true')),
            //     MaterialButton(
            //         onPressed: () => controller.dispose(),
            //         child: const Text('dispose')),
            //   ],
            // ))
          ],
        ),
      ),
    );
  }
}
