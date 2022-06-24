import 'package:a_player/a_player.dart';
import 'package:a_player_example/example/video_player_controller.dart';
import 'package:a_player_example/example/video_player_progress.dart';
import 'package:a_player_example/example/video_player_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rpx/rpx.dart';

const _iconFontFamily = 'MaterialIcons';
const _animationDuration = Duration(milliseconds: 300);

class VideoPlayer extends StatelessWidget {
  final VideoPlayerController controller;

  const VideoPlayer({Key? key, required this.controller}) : super(key: key);

  double get barHeight => controller.isFullscreen.value ? 38.rpx : 28.rpx;
  double get barOffset => controller.isFullscreen.value ? 16.rpx : 0.0;

  double get barPadding => controller.isFullscreen.value ? 30.rpx : 10.rpx;

  double get iconSize => controller.isFullscreen.value ? 28.rpx : 24.rpx;

  double get gap => controller.isFullscreen.value ? 10.rpx : 6.rpx;

  double get primaryFontSize => controller.isFullscreen.value ? 16.rpx : 14.rpx;

  double get secondaryFontSize =>
      controller.isFullscreen.value ? 12.rpx : 10.rpx;

  BoxShadow get overlayShadow => BoxShadow(
        color: Colors.black.withOpacity(0.05),
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

  Widget _buildBar({required Widget child}) {
    return Container(
      width: double.infinity,
      height: barHeight,
      decoration: BoxDecoration(
        boxShadow: [overlayShadow],
        color: Colors.transparent,
      ),
      padding: EdgeInsets.symmetric(horizontal: barPadding),
      child: child,
    );
  }

  Widget _buildTop() {
    return Obx(() {
      return AnimatedPositioned(
        duration: _animationDuration,
        top: controller.isShowBar.value && !controller.isLocked.value
            ? barOffset
            : -barHeight,
        left: 0,
        right: 0,
        child: _buildBar(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildClickableIcon(
                  icon: Icons.arrow_back_ios_outlined, onTap: controller.back),
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
        ),
      );
    });
  }

  Widget _buildBottom() {
    return Obx(() {
      return AnimatedPositioned(
        duration: _animationDuration,
        bottom: controller.isShowBar.value && !controller.isLocked.value
            ? barOffset
            : -barHeight,
        left: 0,
        right: 0,
        child: _buildBar(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  icon: icon, onTap: controller.togglePlay);
            }),
            SizedBox(
              width: gap,
            ),
            Text(
              VideoPlayerUtil.formatDuration(controller.playerValue.position),
              style: TextStyle(fontSize: primaryFontSize),
            ),
            SizedBox(
              width: gap * 2,
            ),
            Expanded(
              child: Obx(
                () => VideoPlayerProgress(
                  onChanged: (double value) {
                    controller.tempSeekPosition.value = value;
                  },
                  onChangeStart: (double value) {
                    controller.isTempSeekEnable.value = true;
                    controller.tempSeekPosition.value = value;
                  },
                  onChangeEnd: (double value) {
                    controller.isTempSeekEnable.value = false;
                    controller.tempSeekPosition.value = 0.0;
                    controller.playerController.seekTo(value.toInt());
                  },
                  position: controller.isTempSeekEnable.value
                      ? controller.tempSeekPosition.value.toInt()
                      : controller.playerValue.position.inMilliseconds,
                  duration: controller.playerValue.duration.inMilliseconds,
                  barHeight: 3.rpx,
                  handleHeight: controller.isFullscreen.value ? 18.rpx : 14.rpx,
                  buffered: controller.playerValue.buffered,
                  colors: VideoPlayerProgressColors(
                    backgroundColor: Colors.white.withOpacity(0.7),
                    playedColor: Colors.white,
                    handleColor: Colors.white,
                    bufferedColor: Colors.blue,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: gap * 2,
            ),
            Text(
              VideoPlayerUtil.formatDuration(controller.playerValue.duration),
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
        )),
      );
    });
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
            color: Colors.black.withOpacity(0.7),
            child: ListView(
              padding:
                  EdgeInsets.symmetric(vertical: 10.rpx, horizontal: 15.rpx),
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
        onTap: () => controller.toggleBar(),
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
    return Text(
      title,
      style: const TextStyle(color: Colors.grey),
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
        onTap: () => controller.toggleBar(),
        onDoubleTap: () => controller.togglePlay(),
        onLongPressStart: (_) => controller.startQuickPlay(),
        onLongPressEnd: (_) => controller.endQuickPlay(),
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
