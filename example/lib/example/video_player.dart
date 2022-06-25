import 'package:a_player/a_player.dart';
import 'package:a_player_example/example/video_player_controller.dart';
import 'package:a_player_example/example/video_player_progress.dart';
import 'package:a_player_example/example/video_player_util.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rpx/rpx.dart';

const _iconFontFamily = 'MaterialIcons';
const _animationDuration = Duration(milliseconds: 300);

class VideoPlayer extends StatelessWidget {
  final VideoPlayerController controller;

  const VideoPlayer({Key? key, required this.controller}) : super(key: key);

  double get barHeight => controller.isFullscreen.value ? 48.rpx : 28.rpx;

  double get barPadding => controller.isFullscreen.value ? 30.rpx : 10.rpx;

  double get iconSize => controller.isFullscreen.value ? 28.rpx : 24.rpx;

  double get gap => controller.isFullscreen.value ? 10.rpx : 6.rpx;

  double get primaryFontSize => controller.isFullscreen.value ? 16.rpx : 14.rpx;

  double get secondaryFontSize =>
      controller.isFullscreen.value ? 12.rpx : 10.rpx;
  double get volumeBrightnessDisplayWidth =>
      controller.isFullscreen.value ? 120.rpx : 80.rpx;

  BoxShadow get overlayShadow => BoxShadow(
        color: Colors.black.withOpacity(0.15),
        blurRadius: 10.rpx,
        spreadRadius: 10.rpx,
      );

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SizedBox(
        height: 240.rpx,
        width: double.infinity,
        child: Obx(
          () => DefaultTextStyle(
            style: TextStyle(
              color: Colors.white,
              fontSize: primaryFontSize,
              shadows: [
                Shadow(
                  blurRadius: (0.5).rpx,
                  color: Colors.black.withOpacity(0.7),
                  offset: Offset((0.5).rpx, (0.5).rpx),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned.fill(
                    child: APlayer(controller: controller.playerController)),
                _buildIndicator(),
                _buildGestureDetector(),
                _buildTop(),
                _buildBottom(),
                _buildSettings(),
                if (controller.isLocked.value && controller.isFullscreen.value)
                  _buildLockedView(),
                if (controller.isFullscreen.value) _buildRight(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBar({required Widget child, required Alignment alignment}) {
    return Container(
      width: double.infinity,
      height: barHeight,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: alignment == Alignment.topCenter
              ? Alignment.bottomCenter
              : Alignment.topCenter,
          end: alignment,
          colors: [
            Colors.black.withOpacity(0.7),
            Colors.black.withOpacity(0.5),
            Colors.black.withOpacity(0.1),
            Colors.transparent
          ],
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: barPadding),
      child: Align(
        alignment: alignment,
        child: child,
      ),
    );
  }

  Widget _buildTop() {
    return Obx(() {
      return AnimatedPositioned(
        duration: _animationDuration,
        top: controller.isShowBar.value && !controller.isLocked.value
            ? 0
            : -barHeight,
        left: 0,
        right: 0,
        child: _buildBar(
          alignment: Alignment.bottomCenter,
          child: Column(
            children: [
              if (controller.isFullscreen.value) _buildStatusBar(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildClickableIcon(
                      icon: Icons.arrow_back_ios_outlined,
                      onTap: controller.back),
                  SizedBox(
                    width: gap,
                  ),
                  const Expanded(
                    child: Text(
                      '惊奇队长[腾讯]',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(
                    width: gap,
                  ),
                  _buildClickableIcon(
                    icon: Icons.more_vert_outlined,
                    onTap: () => controller.toggleSettings(),
                  )
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildStatusBar() {
    return DefaultTextStyle(
      style: TextStyle(fontSize: 8.rpx),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.rpx),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Expanded(child: SizedBox()),
            if (controller.currentTime.value != null)
              Expanded(
                  child: Center(
                      child: Text(
                controller.currentTime.value!,
                style: TextStyle(fontSize: 10.rpx, fontWeight: FontWeight.bold),
              ))),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (ConnectivityResult.wifi ==
                      controller.connectivityResult.value)
                    const Text('WIFI'),
                  if (ConnectivityResult.mobile ==
                      controller.connectivityResult.value)
                    const Text('数据'),
                  SizedBox(
                    width: 4.rpx,
                  ),
                  if (controller.batteryLevel.value != null)
                    Text('${controller.batteryLevel.value}%'),
                  SizedBox(
                    width: 2.rpx,
                  ),
                  if (BatteryState.charging == controller.batteryState.value)
                    Text(
                      '(充电中)',
                      style: TextStyle(fontSize: 6.rpx),
                    ),
                  if (BatteryState.full == controller.batteryState.value)
                    Text(
                      '(已充满)',
                      style: TextStyle(fontSize: 6.rpx),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottom() {
    return Obx(
      () {
        return AnimatedPositioned(
          duration: _animationDuration,
          bottom: controller.isShowBar.value && !controller.isLocked.value
              ? 0
              : -barHeight,
          left: 0,
          right: 0,
          child: _buildBar(
            alignment: Alignment.topCenter,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Obx(() {
                  IconData icon = Icons.block;
                  if (controller.playerValue.isStarted) {
                    icon = Icons.pause;
                  }
                  if (controller.playerValue.isPaused) {
                    icon = Icons.play_arrow;
                  }
                  return _buildClickableIcon(
                      icon: icon, onTap: () => controller.onDoubleTap());
                }),
                SizedBox(
                  width: gap,
                ),
                Text(
                  VideoPlayerUtil.formatDuration(
                      controller.playerValue.position),
                  style: TextStyle(fontSize: primaryFontSize),
                ),
                SizedBox(
                  width: gap * 2,
                ),
                Expanded(
                  child: SizedBox(
                    height: 20.rpx,
                    child: Obx(
                      () {
                        return VideoPlayerProgress(
                          onChanged: (double value) {
                            controller.tempSeekPosition.value =
                                Duration(milliseconds: value.toInt());
                          },
                          onChangeStart: (double value) {
                            controller.isTempSeekEnable.value = true;
                            controller.tempSeekPosition.value =
                                Duration(milliseconds: value.toInt());
                          },
                          onChangeEnd: (double value) {
                            controller.isTempSeekEnable.value = false;
                            controller.tempSeekPosition.value = Duration.zero;
                            controller.playerController.seekTo(value.toInt());
                            controller.playerController.play();
                          },
                          position: controller.isTempSeekEnable.value
                              ? controller.tempSeekPosition.value
                              : controller.playerValue.position,
                          duration: controller.playerValue.duration,
                          barHeight: 3.rpx,
                          handleHeight:
                              controller.isFullscreen.value ? 18.rpx : 14.rpx,
                          buffered: controller.playerValue.buffered,
                          colors: VideoPlayerProgressColors(
                            backgroundColor: Colors.white.withOpacity(0.3),
                            playedColor: Colors.white,
                            handleColor: Colors.white,
                            bufferedColor: Colors.white.withOpacity(0.7),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(
                  width: gap * 2,
                ),
                Text(
                  VideoPlayerUtil.formatDuration(
                      controller.playerValue.duration),
                  style: TextStyle(fontSize: primaryFontSize),
                ),
                SizedBox(
                  width: gap,
                ),
                if (controller.isFullscreen.value)
                  GestureDetector(
                    onTap: () {},
                    child: const Text('选集'),
                  ),
                SizedBox(
                  width: gap,
                ),
                Obx(
                  () => _buildClickableIcon(
                    icon: controller.isFullscreen.value
                        ? Icons.fullscreen_exit
                        : Icons.fullscreen,
                    onTap: () => controller.toggleFullscreen(this),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRight() {
    return Obx(() {
      final double size = 32.rpx;
      return AnimatedPositioned(
        duration: _animationDuration,
        right: controller.isShowBar.value ? 0 + barPadding : -size,
        top: 0,
        bottom: 0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: size,
              width: size,
              decoration: BoxDecoration(
                  boxShadow: [overlayShadow],
                  borderRadius: BorderRadius.circular(size)),
              child: Obx(
                () => _buildClickableIcon(
                  icon:
                      controller.isLocked.value ? Icons.lock : Icons.lock_open,
                  onTap: controller.toggleLock,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSettings() {
    return Obx(
      () {
        final double width =
            Get.width / (controller.isFullscreen.value ? 2 : 1.35);
        return AnimatedPositioned(
          duration: _animationDuration,
          top: 0,
          right: controller.isShowSettings.value ? 0 : -width,
          bottom: 0,
          width: width,
          child: Container(
            color: Colors.black.withOpacity(0.8),
            child: ListView(
              padding:
                  EdgeInsets.all(10.rpx),
              children: [
                _buildTitle('播放速度'),
                _buildRadius(
                  options: controller.speedList,
                  value: controller.playerValue.playSpeed,
                  onTap: controller.playerController.setSpeed,
                ),
                _buildTitle('画面尺寸'),
                _buildRadius(
                  options: controller.fitList,
                  value: controller.playerController.fit,
                  onTap: controller.playerController.setFit,
                ),
                _buildTitle('镜像翻转'),
                _buildRadius(
                  options: controller.mirrorModeList,
                  value: controller.playerValue.mirrorMode,
                  onTap: controller.playerController.setMirrorMode,
                ),
                _buildTitle('解码方式'),
                _buildRadius(
                  options: controller.decoderList,
                  value: controller.playerValue.enableHardwareDecoder,
                  onTap: controller.playerController.setHardwareDecoderEnable,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLockedView() {
    return Positioned.fill(
      child: GestureDetector(
        onTap: () => controller.onTap(),
        child: Container(
          color: Colors.transparent,
          child: Align(
            alignment: Alignment.bottomLeft,
            child: SizedBox(
              height: 2.rpx,
              child: Obx(() {
                final widthFactor =
                    controller.playerValue.position.inMilliseconds /
                        controller.playerValue.duration.inMilliseconds;
                return FractionallySizedBox(
                  widthFactor: widthFactor,
                  heightFactor: 1,
                  child: Builder(builder: (context) {
                    return Container(color: Theme.of(context).primaryColor);
                  }),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(top: 20.rpx, bottom: 10.rpx),
      child: Text(
        title,
        style: const TextStyle(color: Colors.grey),
      ),
    );
  }

  Widget _buildRadius<T>(
      {required List<LableValue<T>> options,
      required T value,
      required ValueChanged<T> onTap}) {
    return Wrap(
      children: options.map((e) {
        return Builder(builder: (context) {
          final bool isSelected = e.value == value;
          final Color color =
              isSelected ? Theme.of(context).primaryColor : Colors.white;
          return TextButton(
            style: TextButton.styleFrom(
              tapTargetSize: controller.isFullscreen.value
                  ? MaterialTapTargetSize.padded
                  : MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              e.label,
              style: TextStyle(
                  color: color,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
            ),
            onPressed: () {
              if (!isSelected) {
                onTap(e.value);
              }
            },
          );
        });
      }).toList(),
    );
  }

  Widget _buildClickableIcon(
      {required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Text(
        String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontFamily: _iconFontFamily,
          fontSize: iconSize,
        ),
      ),
    );
  }

  Positioned _buildGestureDetector() {
    return Positioned.fill(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => controller.onTap(),
        onDoubleTap: () => controller.onDoubleTap(),
        onLongPressStart: (_) => controller.onLongPressStart(),
        onLongPressEnd: (_) => controller.onLongPressEnd(),
        onHorizontalDragStart: (details) =>
            controller.onHorizontalDragStart(details),
        onHorizontalDragUpdate: (details) =>
            controller.onHorizontalDragUpdate(details),
        onHorizontalDragEnd: (details) =>
            controller.onHorizontalDragEnd(details),
        onVerticalDragStart: (details) =>
            controller.onVerticalDragStart(details),
        onVerticalDragUpdate: (details) =>
            controller.onVerticalDragUpdate(details),
        onVerticalDragEnd: (details) =>
            controller.onVerticalDragEnd(details),
      ),
    );
  }
  Widget _buildVolumeBrightnessDisplay({
  required IconData icon,
  required bool isShow,
  required double value,
}) {
    return  Positioned(
      top: barHeight,
      left: 0,
      right: 0,
      child: Center(
        child: AnimatedOpacity(
          duration: _animationDuration,
          opacity: isShow ? 1 : 0,
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [overlayShadow],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 18.rpx, color: Colors.white,),
                    SizedBox(width: 5.rpx),
                    Text('${(value * 100).toStringAsFixed(0)}%',)
                  ],
                ),
                SizedBox(height: 7.rpx),
                SizedBox(
                  height: 2.rpx,
                  width: volumeBrightnessDisplayWidth,
                  child: Stack(
                    children: [
                      Container(
                        color: Colors.white.withOpacity(0.3),
                        height: double.infinity,
                        width: double.infinity,
                      ),
                      FractionallySizedBox(
                        widthFactor: value,
                        child: Builder(
                            builder: (context) {
                              return Container(
                                color: Theme.of(context).primaryColor,
                              );
                            }
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

  }
  Positioned _buildIndicator() {
    return Positioned.fill(
      child: Stack(
        children: [
          Positioned(
            top: barHeight,
            left: 0,
            right: 0,
            child: Center(
              child: Obx(
                () => AnimatedOpacity(
                  duration: _animationDuration,
                  opacity: controller.isQuickPlaying.value ? 1 : 0,
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [overlayShadow],
                    ),
                    child: Column(
                      children: [
                        Text(
                          '快速播放中',
                          style: TextStyle(fontSize: primaryFontSize),
                        ),
                        Text(
                          '${VideoPlayerUtil.formatDuration(controller.playerValue.position)}/${VideoPlayerUtil.formatDuration(controller.playerValue.duration)}',
                          style: TextStyle(fontSize: secondaryFontSize),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          _buildVolumeBrightnessDisplay(
            icon: Icons.brightness_high,
            isShow: controller.isShowBrightnessControl.value,
            value: controller.brightness.value,
          ),
          _buildVolumeBrightnessDisplay(
            icon: Icons.volume_up_sharp,
            isShow: controller.isShowVolumeControl.value,
            value: controller.volume.value,
          ),
          Positioned.fill(
            child: Center(
              child: Obx(
                () => AnimatedScale(
                  duration: _animationDuration,
                  scale: controller.playerValue.isBuffering ||
                          controller.playerValue.isUnknow ||
                          controller.playerValue.isIdle ||
                          controller.playerValue.isInitialized
                      ? 1
                      : 0,
                  child: _buildBufferingIndicator(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBufferingIndicator() {
    return DefaultTextStyle(
      style: TextStyle(fontSize: secondaryFontSize),
      child: Container(
        height: 50.rpx,
        width: 50.rpx,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50.rpx),
          boxShadow: [overlayShadow],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 28.rpx,
              width: 28.rpx,
              child: Stack(
                children: [
                  CircularProgressIndicator(
                    strokeWidth: (1.5).rpx,
                    color: Colors.white,
                  ),
                  Positioned(
                    child: Center(
                      child: Obx(
                        () => Text(controller.playerValue.bufferingPercentage
                            .toString()),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (controller.playerValue.bufferingSpeed != 0.0)
              SizedBox(height: gap),
            if (controller.playerValue.bufferingSpeed != 0.0)
              Obx(() => Text('${controller.playerValue.bufferingSpeed}kb/s')),
          ],
        ),
      ),
    );
  }
}
