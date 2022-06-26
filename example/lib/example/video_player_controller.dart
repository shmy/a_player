import 'dart:async';
import 'dart:io';

import 'package:a_player/a_player_constant.dart';
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
import 'package:rpx/rpx.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:volume_controller/volume_controller.dart';
import 'package:wakelock/wakelock.dart';
typedef VideoSourceResolver = Future<VideoSourceResolve> Function(VideoPlayerItem playerItem);
class VideoSourceResolve {
  final String url;
  final List<APlayerConfigHeader> headers;
  VideoSourceResolve(this.url, this.headers);
}
enum VideoPlayerPlayMode {
  loop,
  listLoop,
  pauseAfterCompleted,
}

class LableValue<T> {
  final String label;
  final T value;

  LableValue(this.label, this.value);
}

class VideoPlayerItem {
  final String source;
  final String title;
  final dynamic extra;

  VideoPlayerItem(this.source, this.title, this.extra);
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
    LableValue<APlayerFit>('适应', APlayerFit.contain),
    LableValue<APlayerFit>('拉伸', APlayerFit.fill),
    LableValue<APlayerFit>('填充', APlayerFit.cover),
    LableValue<APlayerFit>('16:9', APlayerFit.ar16_9),
    LableValue<APlayerFit>('4:3', APlayerFit.ar4_3),
    LableValue<APlayerFit>('1:1', APlayerFit.ar1_1),
  ];

  final List<LableValue<VideoPlayerPlayMode>> playModeList = [
    LableValue<VideoPlayerPlayMode>('列表循环', VideoPlayerPlayMode.listLoop),
    LableValue<VideoPlayerPlayMode>('单集循环', VideoPlayerPlayMode.loop),
    LableValue<VideoPlayerPlayMode>(
        '播完暂停', VideoPlayerPlayMode.pauseAfterCompleted),
  ];

  final List<LableValue<int>> mirrorModeList = [
    LableValue<int>('默认', 0),
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
  DeviceOrientation _deviceOrientation = DeviceOrientation.landscapeRight;
  StreamSubscription<DeviceOrientation>? _deviceOrientationSubscription;

  final List<DeviceOrientation> _fullScreenOrientations = [
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight
  ];

  void _initOrientationPlugin() {
    _deviceOrientationSubscription =
        OrientationPlugin.onOrientationChange.listen((evnet) {
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
  final Duration _throttleDuration = const Duration(milliseconds: 100);

  Throttle<double>? _volumeThrottle;
  Throttle<double>? _brightnessThrottle;
  StreamSubscription<double>? _screenBrightnessSubscription;

  void _initVolumeBrightnessPlugin() {
    _volumeController.listener((value) {
      volume.value = value;
    });
    _screenBrightnessSubscription =
        _screenBrightness.onCurrentBrightnessChanged.listen((value) {
      brightness.value = value;
    });
    _volumeController.getVolume().then((value) {
      volume.value = value;
      _volumeThrottle = Throttle<double>(_throttleDuration, initialValue: value,
          onChanged: (value) {
        _volumeController.setVolume(value, showSystemUI: false);
      });
    });
    _screenBrightness.current.then((value) {
      brightness.value = value;
      _brightnessThrottle = Throttle<double>(_throttleDuration,
          initialValue: value, onChanged: (value) {
        _screenBrightness.setScreenBrightness(value);
      });
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
    _connectivityResultSubscription =
        _connectivity.onConnectivityChanged.listen((event) {
      connectivityResult.value = event;
    });
    _batteryStateSubscription = _battery.onBatteryStateChanged.listen((event) {
      batteryState.value = event;
    });
    _currentTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final DateTime now = DateTime.now();
      currentTime.value =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
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

  double get _currentVolume;

  double get _currentBrightness;

  final RxBool isShowBar = false.obs;
  final RxBool isQuickPlaying = false.obs;
  final RxBool isShowSettings = false.obs;
  final RxBool isShowVolumeControl = false.obs;
  final RxBool isShowBrightnessControl = false.obs;
  final RxBool isLocked = false.obs;
  final RxBool isTempSeekEnable = false.obs;
  final RxBool isShowSelections = false.obs;
  final Rx<Duration> tempSeekPosition = (Duration.zero).obs;
  double _startDx = 0.0;
  double _startDy = 0.0;
  Duration _startDxValue = Duration.zero;
  double _startDyValue = 0.0;

  void onTap() {
    if (isShowSettings.value) {
      toggleSettings();
      return;
    }
    if (isShowSelections.value) {
      toggleSelections();
      return;
    }
    if (playerValue.isCompletion) {
      _rePlay();
    }
    isShowBar.value = !isShowBar.value;
  }

  void _rePlay() {
    playerController.seekTo(0);
    playerController.play();
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

  void onHorizontalDragStart(DragStartDetails details) {
    _startDx = details.localPosition.dx;
    _startDxValue = playerValue.position;
    isTempSeekEnable.value = true;
  }

  void onHorizontalDragUpdate(DragUpdateDetails details) {
    final moveDistX = details.localPosition.dx - _startDx;
    final dist = 5.rpx;
    double seekValue = _startDyValue + moveDistX ~/ dist;
    tempSeekPosition.value =
        _startDxValue + Duration(milliseconds: (seekValue * 1000).toInt());
    if (tempSeekPosition.value < Duration.zero) {
      tempSeekPosition.value = Duration.zero;
    }
    if (tempSeekPosition.value > playerValue.duration) {
      tempSeekPosition.value = playerValue.duration;
    }
  }

  void onHorizontalDragEnd(DragEndDetails details) {
    isTempSeekEnable.value = false;
    playerController.seekTo(tempSeekPosition.value.inMilliseconds);
    playerController.play();
  }

  void onVerticalDragStart(DragStartDetails details) {
    _startDx = details.localPosition.dx;
    _startDy = details.localPosition.dy;
    final isLeft = _startDx < Get.width / 2;
    if (isLeft) {
      _startDyValue = _currentBrightness;
      isShowBrightnessControl.value = true;
    } else {
      _startDyValue = _currentVolume;
      isShowVolumeControl.value = true;
    }
  }

  void onVerticalDragUpdate(DragUpdateDetails details) {
    final moveDistY = details.localPosition.dy - _startDy;
    final isLeft = _startDx < Get.width / 2;
    const steps = 100;
    final dist = 4.rpx;
    double seekValue = _startDyValue + -moveDistY ~/ dist / steps;
    if (seekValue > 1.0) {
      seekValue = 1.0;
    }
    if (seekValue < 0.0) {
      seekValue = 0.0;
    }
    if (isLeft) {
      setBrightness(seekValue);
    } else {
      setVolume(seekValue);
    }
  }

  void onVerticalDragEnd(DragEndDetails details) {
    isShowVolumeControl.value = false;
    isShowBrightnessControl.value = false;
  }

  void toggleSettings() {
    isShowBar.value = false;
    isShowSettings.value = !isShowSettings.value;
  }

  void toggleLock() {
    isLocked.value = !isLocked.value;
  }

  void toggleSelections() {
    isShowBar.value = false;
    isShowSelections.value = !isShowSelections.value;
  }

  void setVolume(double value);

  void setBrightness(double value);
}

mixin _VideoPlayerResolver {
  VideoSourceResolver? _videoPlayerResolver;
}

class VideoPlayerController
    with
        _VideoPlayerOptions,
        _VideoPlayerOrientationPlugin,
        _VideoPlayerVolumeBrightnessPlugin,
        _VideoPlayerBatteryConnectivityPlugin,
        _VideoPlayerGestureDetector,
        _VideoPlayerResolver,
        WidgetsBindingObserver {
  @override
  late final APlayerControllerInterface playerController;
  final Rx<APlayerValue> value = Rx<APlayerValue>(APlayerValue.uninitialized());
  final RxList<VideoPlayerItem> playlist = RxList<VideoPlayerItem>([]);
  final RxInt currentPlayIndex = (-1).obs;
  final Rx<VideoPlayerPlayMode> playMode =
      Rx<VideoPlayerPlayMode>(VideoPlayerPlayMode.listLoop);
  bool _appPaused = false;
  bool _willPlayResumed = false;

  String get title {
    final int index = currentPlayIndex.value;
    if (index == -1) {
      return '';
    }
    return playlist[index].title;
  }

  @override
  APlayerValue get playerValue => value.value;

  VideoPlayerController() {
    playerController = APlayerNetworkController()..stream.listen(_listener);
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> initialize(VideoSourceResolver resolver) {
    Wakelock.enable();
    _videoPlayerResolver = resolver;
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

  void setPlaylist(List<VideoPlayerItem> playlist) {
    this.playlist.assignAll(playlist);
  }

  void playByIndex(int index) async {
    currentPlayIndex.value = index;
    final resolve = await _videoPlayerResolver!.call(playlist[index]);
    (playerController as APlayerNetworkController)
        .setDataSouce(resolve.url, headers: resolve.headers);
    playerController.prepare();
  }

  void setPlayMode(VideoPlayerPlayMode mode) {
    playMode.value = mode;
    switch (playMode.value) {
      case VideoPlayerPlayMode.loop:
        playerController.setLoop(true);
        break;
      case VideoPlayerPlayMode.listLoop:
      case VideoPlayerPlayMode.pauseAfterCompleted:
        playerController.setLoop(false);
        break;
    }
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
    isShowSettings.value = false;
    isShowSelections.value = false;
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
    _videoPlayerResolver = null;
    WidgetsBinding.instance.removeObserver(this);
    _deinitOrientationPlugin();
    _deinitVolumeBrightnessPlugin();
    _deinitBatteryConnectivityPlugin();
    currentPlayIndex.value = -1;
    playerController.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        {
          _appPaused = true;
          _willPlayResumed = playerValue.isStarted;
          playerController.pause();
          break;
        }
      case AppLifecycleState.resumed:
        {
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

  void _listener(APlayerValue value) {
    if (_appPaused && !value.isPaused) {
      playerController.pause();
    }
    this.value.value = value;
    if (this.value.value.isCompletion) {
      if (playMode.value == VideoPlayerPlayMode.listLoop) {
        if (currentPlayIndex.value < playlist.length - 1) {
          playByIndex(currentPlayIndex.value + 1);
        }
      }
    }
  }

  @override
  void setBrightness(double value) {
    _brightnessThrottle?.setValue(value);
  }

  @override
  void setVolume(double value) {
    _volumeThrottle?.setValue(value);
  }

  @override
  double get _currentVolume => volume.value;

  @override
  double get _currentBrightness => brightness.value;
}
