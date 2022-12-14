import 'package:a_player/a_player_constant.dart';
import 'package:a_player/a_player_value.dart';
import 'package:a_player_example/example/video_player.dart';
import 'package:a_player_example/example/video_player_controller.dart';
import 'package:flutter/material.dart';

import 'danmaku/src/flutter_danmaku_bullet.dart';
import 'data.dart';
import 'example/video_player_constant.dart';
import 'example/video_player_util.dart';

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
      ..setResolver((item) async {
        List<DanmakuItem> data =
            (danmakuData['data'] as dynamic).map<DanmakuItem>((e) {
          return DanmakuItem(
              content: e[4],
              duration: (e[0] * 1000).toDouble(),
              color: VideoPlayerUtil.fromHex(e[3] as String),
              bulletType: e[1] == 0
                  ? FlutterDanmakuBulletType.scroll
                  : FlutterDanmakuBulletType.fixed);
        }).toList();
        data.sort((a, b) {
          return (a.duration - b.duration).toInt();
        });
        data.insert(
            0,
            DanmakuItem(
              color: Colors.blue,
              content: item.title,
              bulletType: FlutterDanmakuBulletType.scroll,
              duration: 0,
            ));
        return VideoSourceResolve(
          isSuccess: true,
          url: item.source,
          headers: [
            APlayerConfigHeader('user-Agent',
                'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/103.0.5060.53 Safari/537.36 Edg/103.0.1264.37'),
            // APlayerConfigHeader('referer', 'https://www.baidu.com'),
            APlayerConfigHeader('bb', 'cc'),
          ],
          kernel: APlayerKernel.exo,
          danmakuList: data,
        );
      })
      ..initialize(userMaxSpeed: 3.0).then((value) {
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
            // VideoPlayerItem(
            //     'https://ccp-bj29-video-preview.oss-cn-beijing.aliyuncs.com/lt/C7181956BDE9F8806D784382C4E25A47D82B6D93_1963855800__sha1_bj29/FHD/media.m3u8?di=bj29&dr=87844842&f=62318414b8c375dfbafb4302b67060a39198634d&u=78eea0a5ea6b45ac9ac74c89a03c9244&x-oss-access-key-id=LTAI5t8sJLSvMtxoes9pGyTv&x-oss-expires=1658073753&x-oss-process=hls%2Fsign&x-oss-signature=w7uoTkqk5DN0t1MLC5DY0pbSAv1un8kpUPN6L%2BbqnxM%3D&x-oss-signature-version=OSS2',
            //     '1',
            //     ''),
            // VideoPlayerItem(
            //     'https://sg.storage.bunnycdn.com/dmcc/%5BYMDMACG%5D???????????????%20(EP%2009).mp4?AccessKey=a0477265-40ea-474d-bc9607af00a3-7cb0-467a&v=123&tt=9',
            //     'bunnycdn',
            //     ''),
            // VideoPlayerItem(
            //     'https://m3u8.taopianplay.com/taopian/54fdb532-e89b-4567-bc07-aa93a0c6a79b/a891bf2e-a823-4ae0-ac07-107cdf1703d8/45148/6d3af2a3-090b-486b-ac82-2c3fc6d21603/SD/playlist.m3u8',
            //     'taopianplay',
            //     ''),
            // VideoPlayerItem(
            //     'https://tx.dogevideo.com/vcloud/17/v/20190424/1556036075_818c4125ec9c8cbc7a7a8a7cc1601512/1037/7d515b22c4958598c0fbd1e6290a5ca5.mp4?vkey=8B15F3&tkey=16588306949216421315&auth_key=1658845094-STZdmt7zXpnZoF93-0-adff3352ce5761b899ac21877e9be5c0',
            //     '???????????? ?????????[mp4]',
            //     ''),
            VideoPlayerItem(
                'https://vfx.mtime.cn/Video/2019/02/04/mp4/190204084208765161.mp4',
                '???????????? ?????????[mp4]',
                ''),
            VideoPlayerItem(
                'https://video.pddugc.com/backbone-video/2022-06-21/9d29d0f5668c0f5c1256748b3386313d.mp4',
                '????????????2 ??????[mp4]',
                ''),
            VideoPlayerItem(
                'https://g.gszyvv.com:65/20220506/aU8xJQ47/index.m3u8',
                '????????????2 TC[m3u8]',
                ''),
            VideoPlayerItem(
                'https://g.gszyvv.com:65/20220619/ytW2Mt0c/index.m3u8',
                '??????????????? [m3u8]',
                ''),
            VideoPlayerItem(
                'https://dy.sszyplay.com/20220308/1Tb7f6Io/index.m3u8',
                '???????????? [??????m3u8]',
                ''),
            VideoPlayerItem(
                'https://iqiyi.sd-play.com/20211113/Pec6qZpa/index.m3u8',
                '??????????????? [??????m3u8]',
                ''),
            VideoPlayerItem(
                'https://s1.zoubuting.com/20220622/ImosQ0I4/index.m3u8',
                '????????? [??????m3u8]',
                ''),
            VideoPlayerItem('http://220.161.87.62:8800/hls/0/index.m3u8',
                '????????????HD [m3u8]', ''),
          ])
          ..onResolveFailed((playerItem) {
            print(playerItem);
          })
          ..playByIndex(0, 9000);
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
      body: Column(
        children: [
          VideoPlayer(
            controller: controller,
            watermark: Opacity(
              opacity: 0.5,
              child: Image.network(
                'https://m.gmw.cn/baijia/logo.png',
                width: 50,
                height: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
