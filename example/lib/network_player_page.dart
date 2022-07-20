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
        // APlayerConfigHeader('referer', 'https://www.baidu.com'),
        APlayerConfigHeader('bb', 'cc'),
      ]);
    })
      ..initialize().then((value) {
        controller
          ..setPlaylist([
            // VideoPlayerItem(
            //     'https://apd-vlive.apdcdn.tc.qq.com/vipzj.video.tc.qq.com/szg_3769_50001_0bc3cyadoaaajuadzu432nqvcfwdg4laan2a.f204110.mp4?vkey=DB8ABC520A73E40C846FE246411FF82B9F79D125A06C8CA39A192EA44798F98DB380D4B9EA4F3A1AEE70902295EA96FE2AAF955F8AF763096DAE89D5A80FAC16FB79B3601A11E73C225D5ED082839CF36D79B56BB5BA31965EC166CFA2ABF385EEDC0561C3F6F4553870E096023EF66594A1599D5485BB66',
            //     '??',
            //     ''),
            // VideoPlayerItem(
            //     'https://upos-szbyjkm8g1.bilivideo.com//upgcxcode//76//67//757156776//757156776_nb3-1-112.flv?e=ig8euxZM2rNcNbTH7bdVhwdl7bejhwdVhoNvNC8BqJIzNbfqXBvEqxTEto8BTrNvN0GvT90W5JZMkX_YN0MvXg8gNEV4NC8xNEV4N03eN0B5tZlqNxTEto8BTrNvNeZVuJ10Kj_g2UB02J0mN0B5tZlqNCNEto8BTrNvNC7MTX502C8f2jmMQJ6mqF2fka1mqx6gqj0eN0B599M=&uipk=5&nbs=1&deadline=1656575206&gen=playurlv2&os=hwbv&oi=2034112005&trid=7f1d25d9a9ef4d57bfea21a8383b8d63u&mid=1623204697&platform=pc&upsig=65407b8cb09f81c8ab03432b6f265a95&uparams=e,uipk,nbs,deadline,gen,os,oi,trid,mid,platform&bvc=vod&nettype=0&orderid=0,3&agrr=1&bw=696713&logo=80000000&_t=1656568006845&YIM&qq=452507220',
            //     'b [m3u8]',
            //     ''),
            VideoPlayerItem(
                'https://ccp-bj29-video-preview.oss-cn-beijing.aliyuncs.com/lt/C7181956BDE9F8806D784382C4E25A47D82B6D93_1963855800__sha1_bj29/FHD/media.m3u8?di=bj29&dr=87844842&f=62318414b8c375dfbafb4302b67060a39198634d&u=78eea0a5ea6b45ac9ac74c89a03c9244&x-oss-access-key-id=LTAI5t8sJLSvMtxoes9pGyTv&x-oss-expires=1658073753&x-oss-process=hls%2Fsign&x-oss-signature=w7uoTkqk5DN0t1MLC5DY0pbSAv1un8kpUPN6L%2BbqnxM%3D&x-oss-signature-version=OSS2',
                '1',
                ''),
            VideoPlayerItem(
                'https://sg.storage.bunnycdn.com/dmcc/%5BYMDMACG%5D间谍过家家%20(EP%2009).mp4?AccessKey=a0477265-40ea-474d-bc9607af00a3-7cb0-467a&v=123&tt=9',
                'bunnycdn',
                ''),
            VideoPlayerItem(
                'https://m3u8.taopianplay.com/taopian/54fdb532-e89b-4567-bc07-aa93a0c6a79b/a891bf2e-a823-4ae0-ac07-107cdf1703d8/45148/6d3af2a3-090b-486b-ac82-2c3fc6d21603/SD/playlist.m3u8',
                'taopianplay',
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
          ..onResolveFailed((playerItem) {
            print(playerItem);
          })
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
      appBar: AppBar(title: const Text('Network'),),
      body: Column(
        children: [
          VideoPlayer(controller: controller, watermark: Opacity(
            opacity: 0.5,
            child: Image.network(
              'https://m.gmw.cn/baijia/logo.png',
              width: 50,
              height: 20,
            ),
          ),),
        ],
      ),
    );
  }
}
