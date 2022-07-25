import 'dart:async';
import 'dart:io';

import 'package:html_unescape/html_unescape.dart';
import 'package:a_player/a_player_constant.dart';
import 'package:a_player/a_player_controller.dart';
import 'package:a_player/a_player_value.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:dlna_dart/dlna.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:orientation/orientation.dart';
import 'package:rpx/rpx.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:volume_controller/volume_controller.dart';
import 'package:wakelock/wakelock.dart';
import '../danmaku/src/flutter_danmaku_controller.dart';
import 'dlna_page.dart';

typedef VideoSourceResolver = Future<VideoSourceResolve> Function(
    VideoPlayerItem playerItem);
typedef VideoResolverFailed = void Function(VideoPlayerItem playerItem);

class VideoSourceResolve {
  final bool isSuccess;
  final String url;
  final List<APlayerConfigHeader> headers;
  final APlayerKernel kernel;

  VideoSourceResolve(this.isSuccess, this.url, this.headers, this.kernel);
}

enum VideoPlayerPlayMode {
  loop,
  listLoop,
  pauseAfterCompleted,
}

enum VideoPlayerAdType { video, image }

class LabelValue<T> {
  final String label;
  final T value;

  LabelValue(this.label, this.value);
}

class VideoPlayerItem {
  final String source;
  final String title;
  final dynamic extra;

  VideoPlayerItem(this.source, this.title, this.extra);
}

class VideoAdItem {
  final VideoPlayerAdType type;
  final String source;
  final int minTime;

  VideoAdItem(this.type, this.source, this.minTime);
}
mixin _DanmakuMixin {
  int danIndex = 0;

  FlutterDanmakuController flutterDanmakuController =
  FlutterDanmakuController();


}
mixin _VideoPlayerOptions {
  final List<LabelValue<APlayerFit>> fitList = [
    LabelValue<APlayerFit>('适应', APlayerFit.contain),
    LabelValue<APlayerFit>('拉伸', APlayerFit.fill),
    LabelValue<APlayerFit>('填充', APlayerFit.cover),
    LabelValue<APlayerFit>('16:9', APlayerFit.ar16_9),
    LabelValue<APlayerFit>('4:3', APlayerFit.ar4_3),
    LabelValue<APlayerFit>('1:1', APlayerFit.ar1_1),
  ];

  final List<LabelValue<VideoPlayerPlayMode>> playModeList = [
    LabelValue<VideoPlayerPlayMode>('列表循环', VideoPlayerPlayMode.listLoop),
    LabelValue<VideoPlayerPlayMode>('单集循环', VideoPlayerPlayMode.loop),
    LabelValue<VideoPlayerPlayMode>(
        '播完暂停', VideoPlayerPlayMode.pauseAfterCompleted),
  ];

  final List<LabelValue<APlayerMirrorMode>> mirrorModeList = [
    LabelValue<APlayerMirrorMode>('默认', APlayerMirrorMode.none),
    LabelValue<APlayerMirrorMode>('水平镜像', APlayerMirrorMode.horizontal),
    LabelValue<APlayerMirrorMode>('垂直镜像', APlayerMirrorMode.vertical),
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
  APlayerController get playerController;

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

  double get maxSpeed;

  VoidCallback? _onPausedCallback;

  Timer? _showBarTimer;
  double _startDx = 0.0;
  double _startDy = 0.0;
  Duration _startDxValue = Duration.zero;
  double _startDyValue = 0.0;
  double _lastPlaySpeed = 1.0;

  void onPausedCallback(VoidCallback callback) {
    _onPausedCallback = callback;
  }

  void onTap() {
    if (isShowSettings.value) {
      toggleSettings();
      return;
    }
    if (isShowSelections.value) {
      toggleSelections();
      return;
    }
    _toggleBar();
  }

  void restart() {
    playerController.restart();
  }

  void onDoubleTap() {
    if (!playerValue.isPlaying) {
      playerController.play();
    } else {
      playerController.pause();
      _onPausedCallback?.call();
    }
  }

  void onLongPressStart() {
    _lastPlaySpeed = playerValue.playSpeed;
    playerController.setSpeed(maxSpeed);
    playerController.play();
    isQuickPlaying.value = true;
  }

  void onLongPressEnd() {
    playerController.setSpeed(_lastPlaySpeed);
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
    _hideBar();
    isShowSettings.value = !isShowSettings.value;
  }

  void toggleLock() {
    isLocked.value = !isLocked.value;
    if (!isLocked.value) {
      _showBar();
    }
  }

  void toggleSelections() {
    _hideBar();
    isShowSelections.value = !isShowSelections.value;
  }

  void setVolume(double value);

  void setBrightness(double value);

  void _showBar() {
    _clearShowBarTimer();
    isShowBar.value = true;
    _showBarTimer = Timer(const Duration(seconds: 3), _hideBar);
  }

  void _hideBar() {
    isShowBar.value = false;
  }

  void _toggleBar() {
    if (isShowBar.value) {
      _hideBar();
    } else {
      _showBar();
    }
  }

  void _clearShowBarTimer() {
    _showBarTimer?.cancel();
    _showBarTimer = null;
  }
}
mixin _VideoPlayerResolver {
  VideoSourceResolver? _videoPlayerResolver;
  VideoResolverFailed? _videoResolverFailed;
  RxBool isResolveing = false.obs;
  RxBool isResolveFailed = false.obs;

  void onResolveFailed(VideoResolverFailed callback) {
    _videoResolverFailed = callback;
  }
}
mixin _VideoPlayerDlnaPlugin {
  final RxMap<String, device> _cacheDevice = RxMap<String, device>();

  List<device> get deviceList => _cacheDevice.values.toList();
  late final StreamSubscription<DeviceOrientation> subscription;
  Timer? _searcherTimer;
  search? _searcher;

  Future<void> _showDlnaSheet(VideoPlayerController controller) async {
    await showMaterialModalBottomSheet(
      context: Get.context!,
      builder: (BuildContext context) {
        return DlnaPage(
          controller: controller,
        );
      },
      elevation: 0,
      barrierColor: Colors.transparent,
    );
  }

  Future<bool> _playToDLAN(device d, String url) async {
    try {
      await d.setUrl(url);
      await d.play();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _initDlnaPlugin() async {
    _searcher = search();
    final manager m = await _searcher!.start();
    Timer.periodic(const Duration(seconds: 3), (timer) {
      _searcherTimer = timer;
      _getDeviceList(m);
    });
  }

  void _deinitDlnaPlugin() {
    _searcher?.stop();
    _searcher = null;
    _searcherTimer?.cancel();
    _searcherTimer = null;
  }

  void _getDeviceList(manager m) {
    m.deviceList.forEach((key, value) {
      _cacheDevice[key] = value;
    });
  }
}

class VideoPlayerController
    with
        _DanmakuMixin,
        _VideoPlayerOptions,
        _VideoPlayerOrientationPlugin,
        _VideoPlayerVolumeBrightnessPlugin,
        _VideoPlayerBatteryConnectivityPlugin,
        _VideoPlayerGestureDetector,
        _VideoPlayerResolver,
        _VideoPlayerDlnaPlugin,
        WidgetsBindingObserver {
  @override
  late final APlayerController playerController;
  final Rx<APlayerValue> value = Rx<APlayerValue>(APlayerValue.uninitialized());
  final RxList<VideoPlayerItem> playlist = RxList<VideoPlayerItem>([]);
  final RxInt currentPlayIndex = (-1).obs;
  final Rx<VideoPlayerPlayMode> playMode =
      Rx<VideoPlayerPlayMode>(VideoPlayerPlayMode.listLoop);
  final HtmlUnescape unescape = HtmlUnescape();
  bool _appPaused = false;
  bool _willPlayResumed = false;
  double _userMaxSpeed = 3.0;
  ValueChanged<APlayerValue>? onEventCallback;

  List<LabelValue<double>> get speedList {
    const double step = 0.5;
    double max = 5.0;
    if ([APlayerKernel.ijk, APlayerKernel.av].contains(value.value.kernel)) {
      max = 2.0;
    }
    int steps = max ~/ step;
    final List<LabelValue<double>> speedList = [];
    for (var i = 0; i < steps; i++) {
      final value = i * step + step;
      speedList.add(LabelValue<double>('$value', value));
    }
    return speedList;
  }

  List<LabelValue<APlayerKernel>> get kernelList {
    final List<LabelValue<APlayerKernel>> items = [
      LabelValue<APlayerKernel>('阿里云', APlayerKernel.aliyun),
      LabelValue<APlayerKernel>('IJK', APlayerKernel.ijk),
    ];
    if (Platform.isAndroid) {
      items.add(LabelValue<APlayerKernel>('EXO', APlayerKernel.exo));
    } else if (Platform.isIOS) {
      items.add(LabelValue<APlayerKernel>('AV_KIT', APlayerKernel.av));
    }
    return items;
  }

  VideoPlayerItem? get currentPlayItem {
    if (currentPlayIndex.value == -1) {
      return null;
    }
    if (currentPlayIndex.value > playlist.length) {
      return null;
    }
    return playlist[currentPlayIndex.value];
  }

  String _realPlayUrl = '';

  String get currentPlayUrl => currentPlayItem?.source ?? '';

  String get title => currentPlayItem?.title ?? '';

  bool get ready => playerValue.isReadyToPlay && !isResolveing.value;
  bool get hasNext {
    return currentPlayIndex.value < playlist.length - 1;
  }
  @override
  APlayerValue get playerValue => value.value;

  Size get danmakuSize {

    return isFullscreen.value
        ? MediaQuery.of(Get.context!).size
        : Size(MediaQuery.of(Get.context!).size.width, 220);
  }
  VideoPlayerController() {
    playerController = APlayerController()..stream.listen(_listener);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      flutterDanmakuController.init(danmakuSize);
    });
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> initialize({APlayerKernel kernel = APlayerKernel.aliyun, double userMaxSpeed = 3.0}) {
    _userMaxSpeed = userMaxSpeed;
    Wakelock.enable();
    _initOrientationPlugin();
    _initVolumeBrightnessPlugin();
    _initBatteryConnectivityPlugin();
    _initDlnaPlugin();
    _showBar();
    return playerController.initialize(kernel: kernel);
  }

  @override
  Future<void> _rotateFullscreen() async {
    if (Platform.isAndroid) {
      OrientationPlugin.forceOrientation(_deviceOrientation);
    } else if (Platform.isIOS) {
      SystemChrome.setPreferredOrientations([_deviceOrientation]);
    }
  }

  void setResolver(VideoSourceResolver resolver) {
    _videoPlayerResolver = resolver;
  }

  void setPlaylist(List<VideoPlayerItem> playlist) {
    this.playlist.assignAll(playlist);
  }

  void playByIndex(int index, [int position = 0]) async {
    _showBar();
    _realPlayUrl = '';
    isResolveFailed.value = false;
    isResolveing.value = true;
    currentPlayIndex.value = index;
    playerController.stop();
    final item = playlist[index];
    final resolve = await _videoPlayerResolver!.call(item);
    isResolveFailed.value = !resolve.isSuccess;
    isResolveing.value = false;
    if (index == currentPlayIndex.value && !isResolveFailed.value) {
      setExpectedDataSource(resolve, position);
    }
  }

  void setExpectedDataSource(VideoSourceResolve resolve, [int position = 0]) {
    isResolveFailed.value = false;
    String url = unescape.convert(resolve.url);
    Uri uri = Uri.parse(url);
    url = Uri(
      scheme: uri.scheme,
      userInfo: uri.userInfo,
      host: uri.host,
      port: uri.port,
      path: Uri.decodeComponent(uri.path),
      query: uri.query,
    ).toString();
    _realPlayUrl = url;
    setKernel(resolve.kernel);
    playerController.setDataSouce(url,
        headers: resolve.headers, position: position, isAutoPlay: true);
  }

  void showResolverFailedSheet() {
    _videoResolverFailed?.call(currentPlayItem!);
  }

  void onEvent(ValueChanged<APlayerValue> callback) {
    onEventCallback = callback;
  }

  void setKernel(APlayerKernel kernel) {
    playerController.setKernel(kernel);
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
  void _resizeDumakuSize() {
    Future.delayed(const Duration(seconds: 1), () {
      flutterDanmakuController.resizeArea(danmakuSize);
    });
  }
  void _enterFullscreen(Widget widget) async {
    isFullscreen.value = !isFullscreen.value;
    await Future.wait([
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []),
      _rotateFullscreen(),
      () async {
        _refreshBatteryConnectivity();
        _showBar();
      }(),
      () async {
        Get.to(
          () => WillPopScope(
            onWillPop: () async {
              if (isLocked.value) {
                _showBar();
                return false;
              }
              _exitFullscreen();
              return true;
            },
            child: widget,
          ),
          transition: Transition.noTransition,
        );
        _resizeDumakuSize();
      }(),
    ]);
  }
  void _exitFullscreen() async {
    isFullscreen.value = !isFullscreen.value;
    isShowSettings.value = false;
    isShowSelections.value = false;
    await Future.wait([
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]),
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]),
      () async {
        _deinitBatteryConnectivityPlugin();
        _showBar();
      }(),
      () async {
        Get.back();
        _resizeDumakuSize();
      }(),
    ]);
  }

  void back() {
    if (isFullscreen.value) {
      _exitFullscreen();
    } else {
      Get.back();
    }
  }

  Future<void> showDlnaSheet() async {
    playerController.pause();
    await _showDlnaSheet(this);
    playerController.play();
  }

  Future<void> playToDLAN(device d) async {
    await _playToDLAN(d, _realPlayUrl);
  }

  void dispose() {
    Wakelock.disable();
    flutterDanmakuController.dispose();
    _videoPlayerResolver = null;
    WidgetsBinding.instance.removeObserver(this);
    _deinitOrientationPlugin();
    _deinitVolumeBrightnessPlugin();
    _deinitBatteryConnectivityPlugin();
    _deinitDlnaPlugin();
    currentPlayIndex.value = -1;
    _realPlayUrl = '';
    _clearShowBarTimer();
    playerController.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        {
          _appPaused = true;
          _willPlayResumed = playerValue.isPlaying;
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
    onEventCallback?.call(value);
    if (_appPaused && value.isPlaying) {
      playerController.pause();
    }
    this.value.value = value;
    if (this.value.value.isCompletion && !isResolveing.value) {
      if (playMode.value == VideoPlayerPlayMode.listLoop) {
        if (hasNext) {
          playNext();
        }
      }
    }
  }

  void onSeekChangeStart(double value) {
    isTempSeekEnable.value = true;
    tempSeekPosition.value = Duration(milliseconds: value.toInt());
    _clearShowBarTimer();
  }

  void onSeekChanged(double value) {
    tempSeekPosition.value = Duration(milliseconds: value.toInt());
  }

  void onSeekChangeEnd(double value) {
    isTempSeekEnable.value = false;
    tempSeekPosition.value = Duration.zero;
    playerController.seekTo(value.toInt());
    playerController.play();
    _showBar();
  }

  void enterPip() {
    playerController.enterPip(Get.context!);
  }

  @override
  void setBrightness(double value) {
    _brightnessThrottle?.setValue(value);
  }

  @override
  void setVolume(double value) {
    _volumeThrottle?.setValue(value);
  }

  playNext() {
    playByIndex(currentPlayIndex.value + 1);
  }
  @override
  double get _currentVolume => volume.value;

  @override
  double get _currentBrightness => brightness.value;

  @override
  double get maxSpeed {
    final playerMaxSpeed = speedList.last.value;
    return _userMaxSpeed > playerMaxSpeed ? playerMaxSpeed : _userMaxSpeed;
  }

}
