import 'dart:ui' as ui;
import 'package:a_player/a_player.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rpx/rpx.dart';
import 'video_player_controller.dart';
import 'video_player_progress.dart';
import 'video_player_util.dart';

const _iconFontFamily = 'MaterialIcons';
const _animationDuration = Duration(milliseconds: 300);
final double videoPlayerHeight = 220.rpx;

class VideoPlayer extends StatelessWidget {
  final VideoPlayerController controller;
  final bool featureDLNA;
  final VideoPlayerProgressColors? videoPlayerProgressColors;
  final ui.Image? handleImage;
  final Widget? watermark;
  final Alignment watermarkAlignment;

  const VideoPlayer({
    Key? key,
    required this.controller,
    this.featureDLNA = true,
    this.videoPlayerProgressColors,
    this.handleImage,
    this.watermark,
    this.watermarkAlignment = Alignment.topLeft,
  }) : super(key: key);

  double get topBarHeight => controller.isFullscreen.value ? 44.rpx : 32.rpx;

  double get bottomBarHeight => controller.isFullscreen.value ? 64.rpx : 32.rpx;

  double get barPadding => controller.isFullscreen.value ? 30.rpx : 10.rpx;

  double get iconSize => controller.isFullscreen.value ? 28.rpx : 24.rpx;

  double get indicatorSize => controller.isFullscreen.value ? 42.rpx : 32.rpx;

  double get gap => controller.isFullscreen.value ? 10.rpx : 6.rpx;

  double get percentSize => controller.isFullscreen.value ? 10.rpx : 8.rpx;

  double get primaryFontSize => controller.isFullscreen.value ? 16.rpx : 14.rpx;

  double get durationAreaWidth =>
      controller.isFullscreen.value ? 70.rpx : 55.rpx;

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
        height: videoPlayerHeight,
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
            child: Obx(() => Stack(
                  children: [
                    Positioned.fill(
                        child:
                            APlayer(controller: controller.playerController)),
                    if (!controller.ready)
                      Positioned.fill(child: Container(color: Colors.black)),
                    Positioned.fill(
                      child: Padding(
                        padding: EdgeInsets.all(10.rpx),
                        child: Align(
                          alignment: watermarkAlignment,
                          // alignment: watermarkAlignment,
                          child: watermark,
                        ),
                      ),
                    ),
                    _buildIndicator(),
                    _buildGestureDetector(),
                    _buildTop(),
                    _buildBottom(),
                    if (controller.isLocked.value &&
                        controller.isFullscreen.value)
                      _buildLockedView(),
                    if (controller.isFullscreen.value) _buildRight(),
                    if (controller.isResolveFailed.value)
                      _buildResolveFailedIndicator(),
                    if (controller.playerValue.isError) _buildErrorIndicator(),
                    if (controller.playerValue.isCompletion &&
                        !controller.isResolveing.value)
                      _buildCompletedIndicator(),
                    _buildSettings(),
                    _buildSelections(),
                  ],
                )),
          ),
        ),
      ),
    );
  }

  Widget _buildBar(
      {required Widget child,
      required Alignment alignment,
      required double height}) {
    return Container(
      width: double.infinity,
      height: height,
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
      alignment: alignment,
      child: child,
    );
  }

  Widget _buildTop() {
    return Obx(() {
      return AnimatedPositioned(
        duration: _animationDuration,
        top: controller.isShowBar.value && !controller.isLocked.value
            ? 0
            : -topBarHeight,
        left: 0,
        right: 0,
        child: _buildBar(
          height: topBarHeight,
          alignment: Alignment.bottomCenter,
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                  Expanded(
                    child: Obx(
                      () => Text(
                        controller.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  if (controller.playerValue.featurePictureInPicture &&
                      controller.ready)
                    Padding(
                      padding: EdgeInsets.only(left: gap),
                      child: _buildClickableIcon(
                        icon: Icons.picture_in_picture_alt,
                        onTap: () => controller.enterPip(),
                      ),
                    ),
                  if (featureDLNA && controller.ready)
                    Padding(
                      padding: EdgeInsets.only(left: gap * 2),
                      child: _buildClickableIcon(
                        icon: Icons.connected_tv_rounded,
                        onTap: () => controller.showDlnaSheet(),
                      ),
                    ),
                  if (!controller.isResolveing.value &&
                      !controller.isResolveFailed.value)
                    Padding(
                      padding: EdgeInsets.only(left: gap),
                      child: _buildClickableIcon(
                        icon: Icons.more_vert_outlined,
                        onTap: () => controller.toggleSettings(),
                      ),
                    ),
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

  Widget _buildDurationArea({
    required Duration duration,
    required Alignment alignment,
  }) {
    return Container(
      width: durationAreaWidth,
      alignment: alignment,
      child: Text(
        VideoPlayerUtil.formatDuration(duration),
        style: TextStyle(fontSize: primaryFontSize),
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
              : -bottomBarHeight,
          left: 0,
          right: 0,
          child: _buildBar(
            height: bottomBarHeight,
            alignment: Alignment.topCenter,
            child: Obx(
              () {
                if (!controller.ready) {
                  return const SizedBox();
                }
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Obx(() {
                      IconData icon = Icons.block;
                      if (controller.playerValue.isPlaying) {
                        icon = Icons.pause;
                      } else {
                        icon = Icons.play_arrow;
                      }
                      return _buildClickableIcon(
                          icon: icon, onTap: () => controller.onDoubleTap());
                    }),
                    if (controller.hasNext)
                      SizedBox(
                        width: gap,
                      ),
                    if (controller.hasNext)
                      _buildClickableIcon(
                          icon: Icons.skip_next_sharp,
                          onTap: () => controller.playNext()),
                    _buildDurationArea(
                      alignment: Alignment.centerRight,
                      duration: controller.isTempSeekEnable.value
                          ? controller.tempSeekPosition.value
                          : controller.playerValue.position,
                    ),
                    SizedBox(
                      width: gap * 2,
                    ),
                    Expanded(
                      child: SizedBox(
                        height: topBarHeight / 2,
                        child: Obx(
                          () {
                            if (!controller.ready) {
                              return const SizedBox();
                            }
                            return VideoPlayerProgress(
                              onChanged: (double value) =>
                                  controller.onSeekChanged(value),
                              onChangeStart: (double value) =>
                                  controller.onSeekChangeStart(value),
                              onChangeEnd: (double value) =>
                                  controller.onSeekChangeEnd(value),
                              position: controller.isTempSeekEnable.value
                                  ? controller.tempSeekPosition.value
                                  : controller.playerValue.position,
                              duration: controller.playerValue.duration,
                              barHeight: 3.rpx,
                              handleHeight: controller.isFullscreen.value
                                  ? 18.rpx
                                  : 14.rpx,
                              handleImage: handleImage,
                              buffered: controller.playerValue.buffered,
                              colors: videoPlayerProgressColors ??
                                  VideoPlayerProgressColors(
                                    backgroundColor:
                                        Colors.white.withOpacity(0.3),
                                    playedColor: Colors.white,
                                    handleColor: Colors.white,
                                    bufferedColor:
                                        Colors.white.withOpacity(0.7),
                                  ),
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      width: gap * 2,
                    ),
                    _buildDurationArea(
                      alignment: Alignment.centerRight,
                      duration: controller.playerValue.duration,
                    ),
                    SizedBox(
                      width: gap,
                    ),
                    if (controller.isFullscreen.value)
                      GestureDetector(
                        onTap: () => controller.toggleSelections(),
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
                );
              },
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
                  onTap: () => controller.toggleLock(),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSettings() {
    final double width =
        Get.width / (controller.isFullscreen.value ? 2.5 : 1.35);
    return AnimatedPositioned(
      duration: _animationDuration,
      top: 0,
      right: controller.isShowSettings.value ? 0 : -width,
      bottom: 0,
      width: width,
      child: Container(
        color: Colors.black.withOpacity(0.8),
        child: ListView(
          padding: EdgeInsets.only(bottom: 10.rpx, left: 10.rpx, right: 10.rpx),
          children: [
            _buildTitle('播放内核'),
            _buildRadius(
              options: controller.kernelList,
              value: controller.playerValue.kernel,
              onTap: controller.setKernel,
            ),
            if (controller.ready) _buildTitle('播放速度'),
            if (controller.ready)
              _buildRadius(
                options: controller.speedList,
                value: controller.playerValue.playSpeed,
                onTap: controller.playerController.setSpeed,
              ),
            if (controller.ready) _buildTitle('画面尺寸'),
            if (controller.ready)
              _buildRadius(
                options: controller.fitList,
                value: controller.playerController.fit,
                onTap: controller.playerController.setFit,
              ),
            if (controller.ready) _buildTitle('播放方式'),
            if (controller.ready)
              _buildRadius(
                options: controller.playModeList,
                value: controller.playMode.value,
                onTap: controller.setPlayMode,
              ),
            if (controller.ready) _buildTitle('镜像翻转'),
            if (controller.ready)
              _buildRadius(
                options: controller.mirrorModeList,
                value: controller.playerController.mirrorMode,
                onTap: controller.playerController.setMirrorMode,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelections() {
    final double width = Get.width / 2.5;
    return AnimatedPositioned(
      duration: _animationDuration,
      top: 0,
      right: controller.isShowSelections.value ? 0 : -width,
      bottom: 0,
      width: width,
      child: Container(
        color: Colors.black.withOpacity(0.8),
        padding: EdgeInsets.symmetric(vertical: 10.rpx),
        child: Obx(
          () => ListView.builder(
            padding: EdgeInsets.all(10.rpx),
            itemBuilder: (BuildContext context, int index) {
              return Obx(() {
                final item = controller.playlist[index];
                final isSelected = controller.currentPlayIndex.value == index;
                return Builder(builder: (context) {
                  final color = isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.white;
                  return GestureDetector(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.rpx,
                        vertical: 6.rpx,
                      ),
                      margin: EdgeInsets.symmetric(
                        vertical: 6.rpx,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: color),
                        borderRadius: BorderRadius.circular(4.rpx),
                      ),
                      child: Text(
                        item.title,
                        style: TextStyle(color: color),
                      ),
                    ),
                    onTap: () {
                      controller.isShowSelections.value = false;
                      controller.playByIndex(index);
                    },
                  );
                });
              });
            },
            itemCount: controller.playlist.length,
          ),
        ),
      ),
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
                int duration = controller.playerValue.duration.inMilliseconds;
                if (duration == 0) {
                  duration = 1;
                }
                double? widthFactor =
                    controller.playerValue.position.inMilliseconds / duration;
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

  Widget _buildTitle(String title, {String? subtitle}) {
    return Padding(
      padding: EdgeInsets.only(top: 10.rpx, bottom: 6.rpx),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.grey),
          ),
          if (subtitle != null)
            SizedBox(
              width: 5.rpx,
            ),
          if (subtitle != null)
            Text(
              '($subtitle)',
              style: TextStyle(color: Colors.grey, fontSize: secondaryFontSize),
            ),
        ],
      ),
    );
  }

  Widget _buildRadius<T>(
      {required List<LabelValue<T>> options,
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
      {required IconData icon, required VoidCallback onTap, double? size}) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Text(
        String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontFamily: _iconFontFamily,
          fontSize: size ?? iconSize,
        ),
      ),
    );
  }

  Positioned _buildGestureDetector() {
    final bool isDetectorable = controller.playerValue.isError ||
        controller.playerValue.isCompletion ||
        controller.isResolveFailed.value;
    return Positioned.fill(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => controller.onTap(),
        onDoubleTap: isDetectorable ? null : () => controller.onDoubleTap(),
        onLongPressStart:
            isDetectorable ? null : (_) => controller.onLongPressStart(),
        onLongPressEnd:
            isDetectorable ? null : (_) => controller.onLongPressEnd(),
        onHorizontalDragStart: isDetectorable
            ? null
            : (details) => controller.onHorizontalDragStart(details),
        onHorizontalDragUpdate: isDetectorable
            ? null
            : (details) => controller.onHorizontalDragUpdate(details),
        onHorizontalDragEnd: isDetectorable
            ? null
            : (details) => controller.onHorizontalDragEnd(details),
        onVerticalDragStart: isDetectorable
            ? null
            : (details) => controller.onVerticalDragStart(details),
        onVerticalDragUpdate: isDetectorable
            ? null
            : (details) => controller.onVerticalDragUpdate(details),
        onVerticalDragEnd: isDetectorable
            ? null
            : (details) => controller.onVerticalDragEnd(details),
      ),
    );
  }

  Widget _buildVolumeBrightnessDisplay({
    required IconData icon,
    required bool isShow,
    required double value,
  }) {
    return Positioned(
      top: topBarHeight,
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
                    Text(
                      String.fromCharCode(icon.codePoint),
                      style: TextStyle(
                          fontSize: 18.rpx, fontFamily: _iconFontFamily),
                    ),
                    SizedBox(width: 5.rpx),
                    Text(
                      '${(value * 100).toStringAsFixed(0)}%',
                    )
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
                        child: Builder(builder: (context) {
                          return Container(
                            color: Theme.of(context).primaryColor,
                          );
                        }),
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
            top: topBarHeight,
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
          Positioned(
            top: topBarHeight,
            left: 0,
            right: 0,
            child: Center(
              child: Obx(
                () => AnimatedOpacity(
                  duration: _animationDuration,
                  opacity: controller.isTempSeekEnable.value ? 1 : 0,
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [overlayShadow],
                    ),
                    child: Text(
                      '${VideoPlayerUtil.formatDuration(controller.tempSeekPosition.value)}/${VideoPlayerUtil.formatDuration(controller.playerValue.duration)}',
                      style: TextStyle(fontSize: primaryFontSize),
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
          _buildCenterIndicator(
            isShow: (controller.isResolveing.value ||
                    controller.playerValue.isBuffering ||
                    !controller.playerValue.isInitialized) &&
                controller.currentPlayUrl != '' &&
                !controller.isResolveFailed.value &&
                !controller.playerValue.isError,
            child: _buildBufferingIndicator(),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorIndicator() {
    return _buildCenterIndicator(
      isShow: true,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            String.fromCharCode(Icons.error_outline_sharp.codePoint),
            style:
                TextStyle(fontSize: indicatorSize, fontFamily: _iconFontFamily),
          ),
          SizedBox(
            height: gap,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.rpx),
            child: Text(
              '播放失败',
              style: TextStyle(fontSize: secondaryFontSize),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MaterialButton(
                onPressed: () => controller.toggleSelections(),
                child: const Text(
                  '重新选集',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              MaterialButton(
                onPressed: () => controller.showResolverFailedSheet(),
                child: const Text(
                  '选择线路',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              MaterialButton(
                onPressed: () => controller.toggleSettings(),
                child: const Text(
                  '切换内核',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildResolveFailedIndicator() {
    return _buildCenterIndicator(
      isShow: true,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            String.fromCharCode(Icons.bug_report_sharp.codePoint),
            style:
                TextStyle(fontSize: indicatorSize, fontFamily: _iconFontFamily),
          ),
          SizedBox(
            height: gap,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.rpx),
            child: Text(
              '解析失败',
              style: TextStyle(fontSize: secondaryFontSize),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MaterialButton(
                onPressed: () => controller.back(),
                child: const Text(
                  '返回上级',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              MaterialButton(
                onPressed: () => controller.showResolverFailedSheet(),
                child: const Text(
                  '选择线路',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedIndicator() {
    return _buildCenterIndicator(
      isShow: true,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            String.fromCharCode(Icons.refresh.codePoint),
            style:
                TextStyle(fontSize: indicatorSize, fontFamily: _iconFontFamily),
          ),
          SizedBox(
            height: gap,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.rpx),
            child: Text(
              '播放结束',
              style: TextStyle(fontSize: secondaryFontSize),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MaterialButton(
                onPressed: () => controller.back(),
                child: const Text(
                  '返回上级',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              MaterialButton(
                onPressed: () => controller.restart(),
                child: const Text(
                  '重新播放',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCenterIndicator({
    required bool isShow,
    required Widget child,
  }) {
    return Positioned.fill(
      child: Center(
        child: AnimatedOpacity(
          duration: _animationDuration,
          opacity: isShow ? 1 : 0,
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [overlayShadow],
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _buildBufferingIndicator() {
    return DefaultTextStyle(
      style: TextStyle(fontSize: secondaryFontSize),
      child: Container(
        height: 80.rpx,
        width: 80.rpx,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(80.rpx),
          boxShadow: [overlayShadow],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: indicatorSize,
              width: indicatorSize,
              child: Obx(
                () => Stack(
                  children: [
                    Positioned.fill(
                      child: CircularProgressIndicator(
                        strokeWidth: 2.rpx,
                        color: Colors.white,
                        backgroundColor: Colors.white.withOpacity(0.3),
                      ),
                    ),
                    if (controller.playerValue.isBuffering)
                      Positioned.fill(
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Obx(
                                () => Text(
                                    '${controller.playerValue.bufferingPercentage}'),
                              ),
                              Text(
                                '%',
                                style: TextStyle(fontSize: percentSize),
                              )
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: gap),
            Obx(
              () {
                String text =
                    '${VideoPlayerUtil.formatBytes(controller.playerValue.bufferingSpeed)}/s';
                if (controller.isResolveing.value) {
                  text = '解析中...';
                }
                return Text(
                  text,
                  style: TextStyle(fontSize: secondaryFontSize),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
