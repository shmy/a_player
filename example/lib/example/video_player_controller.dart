import 'dart:async';
import 'dart:io';

import 'package:a_player/a_player_controller.dart';
import 'package:a_player/a_player_network_controller.dart';
import 'package:a_player/a_player_value.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:orientation/orientation.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:volume_controller/volume_controller.dart';
import 'package:wakelock/wakelock.dart';

class LableValue<T> {
  final String label;
  final T value;

  LableValue(this.label, this.value);
}
mixin _VideoPlayerOptions {
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
}
mixin _VideoPlayerOrientationPlugin {
  final RxBool isFullscreen = false.obs;
  DeviceOrientation _deviceOrientation = DeviceOrientation.landscapeLeft;
  StreamSubscription<DeviceOrientation>? _deviceOrientationSubscription;

  final List<DeviceOrientation> _fullScreenOrientations = [
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight
  ];
  void _initOrientationPlugin() {
    _deviceOrientationSubscription = OrientationPlugin.onOrientationChange.listen((evnet) {
      if (_fullScreenOrientations.contains(evnet)) {
        _deviceOrientation = evnet;
        if (isFullscreen.value) {
          _rotateFullscreen();
        }
      }
    });
  }
  void _deinitOrientationPlugin() {
    _deviceOrientationSubscription?.cancel();
  }
  void _rotateFullscreen() {}
}
mixin _VideoPlayerVolumeBrightnessPlugin {
  final VolumeController _volumeController = VolumeController();
  final ScreenBrightness _screenBrightness = ScreenBrightness();
  final RxDouble volume = (0.0).obs;
  final RxDouble brightness = (0.0).obs;

  late final Throttle<double> _volumeThrottle;
  late final Throttle<double> _brightnessThrottle;
  StreamSubscription<double>? _screenBrightnessSubscription;

  void _initVolumeBrightnessPlugin() {
    _volumeController.listener((value) {
      volume.value = value;
    });
    _screenBrightnessSubscription = _screenBrightness.onCurrentBrightnessChanged.listen((value) {
      brightness.value = value;
    });
    _volumeController.getVolume().then((value) {
      volume.value = value;
    });
    _screenBrightness.current.then((value) {
      brightness.value = value;
    });
  }
  void _deinitVolumeBrightnessPlugin() {
    _screenBrightnessSubscription?.cancel();
    _volumeController.removeListener();
  }
}
mixin _VideoPlayerBatteryConnectivityPlugin {
  final Connectivity _connectivity = Connectivity();
  final Battery _battery = Battery();
  final Rxn<ConnectivityResult> connectivityResult = Rxn<ConnectivityResult>();
  final Rxn<int> batteryLevel = Rxn<int>();
  final Rxn<BatteryState> batteryState = Rxn<BatteryState>();
  final Rxn<String> currentTime = Rxn<String>();
  Timer? _currentTimer;
  StreamSubscription<ConnectivityResult>? _connectivityResultSubscription;
  StreamSubscription<BatteryState>? _batteryStateSubscription;

  Future<void> _refreshBatteryConnectivity() async {
    var connectivityResult = await _connectivity.checkConnectivity();
    var batteryLevel = await _battery.batteryLevel;
    var batteryState = await _battery.batteryState;
    this.connectivityResult.value = connectivityResult;
    this.batteryLevel.value = batteryLevel;
    this.batteryState.value = batteryState;
  }
  void _initBatteryConnectivityPlugin() {
    _connectivityResultSubscription = _connectivity.onConnectivityChanged.listen((event) {
      connectivityResult.value = event;
    });
    _batteryStateSubscription = _battery.onBatteryStateChanged.listen((event) {
      batteryState.value = event;
    });
    _currentTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final DateTime now = DateTime.now();
      currentTime.value = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    });
  }
  void _deinitBatteryConnectivityPlugin() {
    _connectivityResultSubscription?.cancel();
    _batteryStateSubscription?.cancel();
    _currentTimer?.cancel();
    _connectivityResultSubscription = null;
    _batteryStateSubscription = null;
    _currentTimer = null;
  }
}
mixin _VideoPlayerGestureDetector {
  APlayerControllerInterface get playerController;
  APlayerValue get playerValue;
  final RxBool isShowBar = false.obs;
  final RxBool isQuickPlaying = false.obs;
  final RxBool isShowSettings = false.obs;
  final RxBool isLocked = false.obs;
  final RxBool isTempSeekEnable = false.obs;
  final Rx<Duration> tempSeekPosition = (Duration.zero).obs;

  void onTap() {
    if (isShowSettings.value) {
      toggleSettings();
      return;
    }
    isShowBar.value = !isShowBar.value;
  }
  void onDoubleTap() {
    if (playerValue.isPaused) {
      playerController.play();
    } else {
      playerController.pause();
    }
  }
  void onLongPressStart() {
    playerController.setSpeed(5.0);
    playerController.play();
    isQuickPlaying.value = true;
  }
  void onLongPressEnd() {
    playerController.setSpeed(1.0);
    isQuickPlaying.value = false;
  }
  void onHorizontalDragStart(DragStartDetails details) {}
  void onHorizontalDragUpdate(DragUpdateDetails details) {}
  void onHorizontalDragEnd(DragEndDetails details) {}
  void toggleSettings() {
    isShowBar.value = false;
    isShowSettings.value = !isShowSettings.value;
  }

  void toggleLock() {
    isLocked.value = !isLocked.value;
  }

}

class VideoPlayerController with _VideoPlayerOptions, _VideoPlayerOrientationPlugin, _VideoPlayerVolumeBrightnessPlugin, _VideoPlayerBatteryConnectivityPlugin, _VideoPlayerGestureDetector, WidgetsBindingObserver {
  @override
  late final APlayerControllerInterface playerController;
  final Rx<APlayerValue> value = Rx<APlayerValue>(APlayerValue.uninitialized());
  final RxList<String> playlist = RxList<String>([]);

  bool _appPaused = false;
  bool _willPlayResumed = false;

  @override
  APlayerValue get playerValue => value.value;

  VideoPlayerController() {
    playerController = APlayerNetworkController()..addListener(_listener);
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> initialize() {
    Wakelock.enable();
    _initOrientationPlugin();
    _initVolumeBrightnessPlugin();
    _initBatteryConnectivityPlugin();
    return playerController.initialize();
  }
  @override
  Future<void> _rotateFullscreen() async {
    if (Platform.isAndroid) {
      OrientationPlugin.forceOrientation(_deviceOrientation);
    } else if (Platform.isIOS) {
      SystemChrome.setPreferredOrientations([_deviceOrientation]);
    }
  }
  void setPlaylist(List<String> playlist) {
    this.playlist.assignAll(playlist);
  }

  void playByIndex(int index) {
    playerController.setDataSouce(playlist[index]);
    playerController.prepare();
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
      _rotateFullscreen(),
      () async {
        _refreshBatteryConnectivity();
      }(),
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
      () async {
        _deinitBatteryConnectivityPlugin();
      }(),
      () async {
        Get.back();
      }(),
    ]);
    isFullscreen.value = !isFullscreen.value;
  }

  void back() {
    if (isFullscreen.value) {
      _exitFullscreen();
    } else {
      Get.back();
    }
  }

  void dispose() {
    Wakelock.disable();
    WidgetsBinding.instance.removeObserver(this);
    _deinitOrientationPlugin();
    _deinitVolumeBrightnessPlugin();
    _deinitBatteryConnectivityPlugin();
    playerController.dispose();

  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch(state) {
      case AppLifecycleState.paused: {
        _appPaused = true;
        _willPlayResumed = playerValue.isStarted;
        playerController.pause();
        break;
      }
      case AppLifecycleState.resumed: {
        _appPaused = false;
        if (_willPlayResumed) {
          playerController.play();
        }
        break;
      }
      default:
        break;
    }
  }
  void _listener() {
    if (_appPaused && !playerValue.isPaused) {
      playerController.pause();
    }
    value.value = playerController.value;
  }
}
