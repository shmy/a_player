import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rpx/rpx.dart';
import 'video_player_controller.dart';

class DlnaPage extends StatelessWidget {
  final VideoPlayerController controller;

  const DlnaPage({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: const TextStyle(color: Colors.white),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 14.rpx,
                width: 14.rpx,
                child: CircularProgressIndicator(
                  strokeWidth: 2.rpx,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 10.rpx),
              Text(
                '持续搜索设备中...',
                style: TextStyle(
                  fontSize: 16.rpx,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close))
          ],
        ),
        body: CustomScrollView(
          physics: const ClampingScrollPhysics(),
          slivers: [
            Obx(() {
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                  final item = controller.deviceList[index];
                  return GestureDetector(
                    onTap: () => controller.playToDLAN(item),
                    child: Center(
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 10.rpx),
                        padding: EdgeInsets.symmetric(
                            vertical: 8.rpx, horizontal: 15.rpx),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.rpx),
                            border: Border.all(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyText1!
                                    .color!)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.tv_sharp,
                              size: 18.rpx,
                            ),
                            SizedBox(width: 5.rpx),
                            Text(
                              item.info.friendlyName,
                              style: TextStyle(
                                fontSize: 14.rpx,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }, childCount: controller.deviceList.length),
              );
            }),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 20.rpx),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  SizedBox(height: 40.rpx),
                  Text(
                    '找不到想投屏的设备？请检查：',
                    style: TextStyle(
                      fontSize: 16.rpx,
                    ),
                  ),
                  Text(
                    '1. 设备和手机是否连接同一网络？\n2. 设备是否支持投屏？\n3. 推荐在电视设备上安装乐播投屏软件。',
                    style: TextStyle(
                      fontSize: 14.rpx,
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
