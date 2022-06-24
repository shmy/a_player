import 'package:a_player/a_player_controller.dart';
import 'package:a_player/a_player_network_controller.dart';
import 'package:a_player/a_player_value.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class LableValue<T> {
  final String label;
  final T value;

  LableValue(this.label, this.value);
}

class VideoPlayerController {
  late final APlayerControllerInterface playerController;
  final Rx<APlayerValue> value = Rx<APlayerValue>(APlayerValue.uninitialized());
  final RxList<String> playlist = RxList<String>([]);
  final RxBool isShowBar = false.obs;
  final RxBool isQuickPlaying = false.obs;
  final RxBool isFullscreen = false.obs;
  final RxBool isShowSettings = false.obs;
  final RxBool isLocked = true.obs;
  final RxBool isTempSeekEnable = false.obs;
  final RxDouble tempSeekPosition = (0.0).obs;
  final List<LableValue<double>> speedList = [
    LableValue<double>('0.5', 0.5),
    LableValue<double>('1.0', 1.0),
    LableValue<double>('1.5', 1.5),
    LableValue<double>('2.0', 2.0),
    LableValue<double>('2.5', 2.5),
    LableValue<double>('3.0', 3.0),
    LableValue<double>('3.5', 3.5),
    LableValue<double>('4.0', 4.0),
    LableValue<double>('4.5', 4.5),
    LableValue<double>('5.0', 5.0),
  ];
  final List<LableValue<APlayerFit>> fitList = [
    LableValue<APlayerFit>('默认', APlayerFit.fitDefault),
    LableValue<APlayerFit>('拉伸', APlayerFit.fitStretch),
    LableValue<APlayerFit>('充满', APlayerFit.fitFill),
    LableValue<APlayerFit>('16:9', APlayerFit.fit16x9),
    LableValue<APlayerFit>('4:3', APlayerFit.fit4x3),
    LableValue<APlayerFit>('1:1', APlayerFit.fit1x1),
  ];

  final List<LableValue<int>> mirrorModeList = [
    LableValue<int>('正常', 0),
    LableValue<int>('水平镜像', 1),
    LableValue<int>('垂直镜像', 2),
  ];

  final List<LableValue<bool>> decoderList = [
    LableValue<bool>('硬件解码', true),
    LableValue<bool>('软件解码', false),
  ];

  APlayerValue get playerValue => value.value;

  VideoPlayerController() {
    playerController = APlayerNetworkController()..addListener(_listener);
  }

  Future<void> initialize() {
    return playerController.initialize();
  }

  void setPlaylist(List<String> playlist) {
    this.playlist.assignAll(playlist);
  }

  void playByIndex(int index) {
    playerController.setDataSouce(playlist[index]);
    playerController.prepare();
  }

  void togglePlay() {
    if (playerValue.isPaused) {
      playerController.play();
    } else {
      playerController.pause();
    }
  }

  void toggleBar() {
    if (isShowSettings.value) {
      toggleSettings();
      return;
    }
    isShowBar.value = !isShowBar.value;
  }

  void toggleSettings() {
    isShowBar.value = false;
    isShowSettings.value = !isShowSettings.value;
  }
  void toggleLock() {
    isLocked.value = !isLocked.value;
  }

  void toggleFullscreen(Widget widget) {
    final List<Future<void>> tasks = [];
    if (isFullscreen.value) {
      _exitFullscreen();
    } else {
      _enterFullscreen(widget);
    }
  }

  void _enterFullscreen(Widget widget) {
    Future.wait([
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []),
      SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]),
      () async {
        Get.to(() => WillPopScope(
            onWillPop: () async {
              _exitFullscreen();
              return true;
            },
            child: widget));
      }(),
    ]);
    isFullscreen.value = !isFullscreen.value;
  }

  void _exitFullscreen() {
    Future.wait([
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]),
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]),
      () async {
        Get.back();
      }(),
    ]);
    isFullscreen.value = !isFullscreen.value;
  }

  void startQuickPlay() {
    playerController.setSpeed(speedList.last.value);
    playerController.play();
    isQuickPlaying.value = true;
  }

  void endQuickPlay() {
    playerController.setSpeed(1.0);
    isQuickPlaying.value = false;
  }

  void back() {
    if (isFullscreen.value) {
      _exitFullscreen();
    } else {
      Get.back();
    }
  }

  void dispose() {
    playerController.dispose();
  }

  void _listener() {
    value.value = playerController.value;
  }
}
