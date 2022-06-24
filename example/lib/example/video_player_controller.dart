import 'dart:async';

import 'package:a_player/a_player_controller.dart';
import 'package:a_player/a_player_network_controller.dart';
import 'package:a_player/a_player_value.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
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
  final RxBool isLocked = false.obs;
  final RxBool isTempSeekEnable = false.obs;
  final Rx<Duration> tempSeekPosition = (Duration.zero).obs;
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
  final Connectivity _connectivity = Connectivity();
  final Battery _battery = Battery();
  final Rxn<ConnectivityResult> connectivityResult = Rxn<ConnectivityResult>();
  final Rxn<int> batteryLevel = Rxn<int>();
  final Rxn<BatteryState> batteryState = Rxn<BatteryState>();
  final Rxn<String> currentTime = Rxn<String>();
  Timer? _currentTimer;
  StreamSubscription<ConnectivityResult>? _connectivityResultSubscription;
  StreamSubscription<BatteryState>? _batteryStateSubscription;
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
    if (isFullscreen.value) {
      _exitFullscreen();
    } else {
      _enterFullscreen(widget);
    }
  }

  void _enterFullscreen(Widget widget) async {
    await Future.wait([
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []),
      SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]),
      _refreshSystemInfo(),
      () async {
        Get.to(
          () => WillPopScope(
            onWillPop: () async {
              if (isLocked.value) {
                isShowBar.value = true;
                return false;
              }
              _exitFullscreen();
              return true;
            },
            child: widget,
          ),
          transition: Transition.noTransition,
        );
      }(),
    ]);
    isFullscreen.value = !isFullscreen.value;
  }

  void _exitFullscreen() async {
    await Future.wait([
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]),
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]),
      _removeListener(),
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
  Future<void> _refreshSystemInfo() async {
    var connectivityResult = await _connectivity.checkConnectivity();
    var batteryLevel = await _battery.batteryLevel;
    var batteryState = await _battery.batteryState;
    this.connectivityResult.value = connectivityResult;
    this.batteryLevel.value = batteryLevel;
    this.batteryState.value = batteryState;
    _connectivityResultSubscription = _connectivity.onConnectivityChanged.listen((event) {
      this.connectivityResult.value = event;
    });
    _batteryStateSubscription = _battery.onBatteryStateChanged.listen((event) {
      this.batteryState.value = event;
    });
    _currentTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final DateTime now = DateTime.now();
      currentTime.value = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    });
  }
  Future<void> _removeListener() async {
    _connectivityResultSubscription?.cancel();
    _batteryStateSubscription?.cancel();
    _currentTimer?.cancel();
    _connectivityResultSubscription = null;
    _batteryStateSubscription = null;
    _currentTimer = null;
  }
  void dispose() {
    playerController.dispose();
  }

  void _listener() {
    value.value = playerController.value;
  }
}
