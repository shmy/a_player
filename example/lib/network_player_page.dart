import 'package:a_player/a_player_constant.dart';
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
    controller = VideoPlayerController()..setResolver((item) async {
      return VideoSourceResolve(true, item.source, [
        APlayerConfigHeader('user-Agent',
            'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/103.0.5060.53 Safari/537.36 Edg/103.0.1264.37'),
      ]);
    })
      ..initialize().then((value) {
        controller
          ..setPlaylist([
            // VideoPlayerItem(
            //     'http://150.158.130.238:4434/m3u8/b.m3u8',
            //     'b [m3u8]',
            //     ''),
            VideoPlayerItem(
                'https://vfx.mtime.cn/Video/2019/02/04/mp4/190204084208765161.mp4',
                '惊奇队长 预告片[mp4]',
                ''),
            VideoPlayerItem(
                'https://video.pddugc.com/backbone-video/2022-06-21/9d29d0f5668c0f5c1256748b3386313d.mp4',
                '奇艺博士2 高清[mp4]',
                ''),
            VideoPlayerItem(
                'https://g.gszyvv.com:65/20220506/aU8xJQ47/index.m3u8',
                '奇艺博士2 TC[m3u8]',
                ''),
            VideoPlayerItem(
                'https://g.gszyvv.com:65/20220619/ytW2Mt0c/index.m3u8',
                '法律和秩序 [m3u8]',
                ''),
            VideoPlayerItem(
                'https://dy.sszyplay.com/20220308/1Tb7f6Io/index.m3u8',
                '烈性摔跤 [神速m3u8]',
                ''),
            VideoPlayerItem(
                'https://iqiyi.sd-play.com/20211113/Pec6qZpa/index.m3u8',
                '凡人修仙传 [闪电m3u8]',
                ''),
            VideoPlayerItem(
                'https://s1.zoubuting.com/20220622/ImosQ0I4/index.m3u8',
                '偷窥狂 [无尽m3u8]',
                ''),
            VideoPlayerItem(
                'http://220.161.87.62:8800/hls/0/index.m3u8',
                '漳浦综合HD [m3u8]',
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
      body: Column(
        children: [
          VideoPlayer(controller: controller),
        ],
      ),
    );
  }
}
