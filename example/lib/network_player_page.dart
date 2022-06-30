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
            VideoPlayerItem(
                'https://apd-vlive.apdcdn.tc.qq.com/vipzj.video.tc.qq.com/szg_3769_50001_0bc3cyadoaaajuadzu432nqvcfwdg4laan2a.f204110.mp4?vkey=DB8ABC520A73E40C846FE246411FF82B9F79D125A06C8CA39A192EA44798F98DB380D4B9EA4F3A1AEE70902295EA96FE2AAF955F8AF763096DAE89D5A80FAC16FB79B3601A11E73C225D5ED082839CF36D79B56BB5BA31965EC166CFA2ABF385EEDC0561C3F6F4553870E096023EF66594A1599D5485BB66',
                '??',
                ''),
            VideoPlayerItem(
                'https://upos-szbyjkm8g1.bilivideo.com//upgcxcode//76//67//757156776//757156776_nb3-1-112.flv?e=ig8euxZM2rNcNbTH7bdVhwdl7bejhwdVhoNvNC8BqJIzNbfqXBvEqxTEto8BTrNvN0GvT90W5JZMkX_YN0MvXg8gNEV4NC8xNEV4N03eN0B5tZlqNxTEto8BTrNvNeZVuJ10Kj_g2UB02J0mN0B5tZlqNCNEto8BTrNvNC7MTX502C8f2jmMQJ6mqF2fka1mqx6gqj0eN0B599M=&uipk=5&nbs=1&deadline=1656575206&gen=playurlv2&os=hwbv&oi=2034112005&trid=7f1d25d9a9ef4d57bfea21a8383b8d63u&mid=1623204697&platform=pc&upsig=65407b8cb09f81c8ab03432b6f265a95&uparams=e,uipk,nbs,deadline,gen,os,oi,trid,mid,platform&bvc=vod&nettype=0&orderid=0,3&agrr=1&bw=696713&logo=80000000&_t=1656568006845&YIM&qq=452507220',
                'b [m3u8]',
                ''),
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
      appBar: AppBar(title: const Text('Player Page'),),
      body: Column(
        children: [
          VideoPlayer(controller: controller),
        ],
      ),
    );
  }
}
