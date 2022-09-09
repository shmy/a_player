import 'dart:async';
import 'package:a_player/a_player_pip.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'a_player_constant.dart';
import 'a_player_value.dart';

const _methodChannel = MethodChannel(APlayerConstant.methodChannelName);

typedef VideoSizeChangedCallback = void Function(int height, int width);

class APlayerValueListener<T> extends ChangeNotifier {
  late T value;
}

mixin APlayerControllerListener {
  final APlayerValueListener<void> _onInitializing =
      APlayerValueListener<void>();
  final APlayerValueListener<void> _onInitialized =
      APlayerValueListener<void>();
  final APlayerValueListener<VideoReadyData> _onReadyToPlay =
      APlayerValueListener<VideoReadyData>();
  final APlayerValueListener<VideoSizeChangedData> _onVideoSizeChanged =
      APlayerValueListener<VideoSizeChangedData>();
  final APlayerValueListener<void> _onLoadingBegin =
      APlayerValueListener<void>();
  final APlayerValueListener<int> _onLoadingProgress =
      APlayerValueListener<int>();
  final APlayerValueListener<void> _onLoadingEnd = APlayerValueListener<void>();
  final APlayerValueListener<int> _onCurrentPositionChanged =
      APlayerValueListener<int>();
  final APlayerValueListener<int> _onCurrentDownloadSpeedChanged =
      APlayerValueListener<int>();
  final APlayerValueListener<int> _onBufferedPositionChanged =
      APlayerValueListener<int>();
  final APlayerValueListener<bool> _onPlaying = APlayerValueListener<bool>();
  final APlayerValueListener<String> _onError = APlayerValueListener<String>();
  final APlayerValueListener<void> _onCompletion = APlayerValueListener<void>();

  APlayerValueListener<void> get onInitializing => _onInitializing;

  APlayerValueListener<void> get onInitialized => _onInitialized;

  APlayerValueListener<VideoReadyData> get onReadyToPlay => _onReadyToPlay;

  APlayerValueListener<VideoSizeChangedData> get onVideoSizeChanged =>
      _onVideoSizeChanged;

  APlayerValueListener<void> get onLoadingBegin => _onLoadingBegin;

  APlayerValueListener<int> get onLoadingProgress => _onLoadingProgress;

  APlayerValueListener<void> get onLoadingEnd => _onLoadingEnd;

  APlayerValueListener<int> get onCurrentPositionChanged =>
      _onCurrentPositionChanged;

  APlayerValueListener<int> get onCurrentDownloadSpeedChanged =>
      _onCurrentDownloadSpeedChanged;

  APlayerValueListener<int> get onBufferedPositionChanged =>
      _onBufferedPositionChanged;

  APlayerValueListener<bool> get onPlaying => _onPlaying;

  APlayerValueListener<String> get onError => _onError;

  APlayerValueListener<void> get onCompletion => _onCompletion;
}

class APlayerController extends ChangeNotifier
    with APlayerControllerListener, WidgetsBindingObserver {
  EventChannel? eventChannel;
  MethodChannel? methodChannel;
  int textureId = -1;
  APlayerFit _fit = APlayerFit.contain;
  APlayerMirrorMode _mirrorMode = APlayerMirrorMode.none;
  int _videoHeight = 0;
  int _videoWidth = 0;
  APlayerKernel _kernel = APlayerKernel.aliyun;
  String _currentSource = '';

  bool get hasTextureId => textureId != -1;

  APlayerFit get fit => _fit;

  APlayerMirrorMode get mirrorMode => _mirrorMode;

  APlayerKernel get kernel => _kernel;

  String get currentSource => _currentSource;

  int get videoHeight => _videoHeight;

  int get videoWidth => _videoWidth;
  bool isPipMode = false;
  BuildContext? context;
  Size screenSize = Size.zero;

  @mustCallSuper
  Future<void> initialize() async {
    final textureId = await _methodChannel.invokeMethod<int>('initialize');
    if (textureId != null) {
      WidgetsBinding.instance.addObserver(this);
      this.textureId = textureId;
      eventChannel =
          EventChannel('${APlayerConstant.playerEventChanneName}$textureId');
      methodChannel =
          MethodChannel('${APlayerConstant.playerMethodChannelName}$textureId');
      _listen();
      notifyListeners();
    }
  }

  Future<void> setDataSouce(
    String source, {
    APlayerKernel kernel = APlayerKernel.aliyun,
    List<APlayerConfigHeader> headers = const [],
    int position = 0,
  }) async {
    _currentSource = source;
    notifyListeners();
    Map<String, String> httpHeaders = {};
    for (var header in headers) {
      httpHeaders[header.key] = header.value;
    }
    await methodChannel?.invokeMethod('setDataSource', {
      "kernel": kernel.index,
      "url": source,
      "position": position,
      "httpHeaders": httpHeaders,
    });
    prepare();
  }

  Future<void> play() async {
    await methodChannel?.invokeMethod('play');
  }

  Future<void> restart() async {
    await methodChannel?.invokeMethod('restart');
  }

  Future<void> pause() async {
    await methodChannel?.invokeMethod('pause');
  }

  Future<void> prepare() async {
    await methodChannel?.invokeMethod('prepare');
  }

  Future<void> stop() async {
    await methodChannel?.invokeMethod('stop');
  }

  Future<void> release() async {
    await methodChannel?.invokeMethod('release');
    eventChannel = null;
    methodChannel = null;
  }

  Future<void> setLoop(bool loop) async {
    await methodChannel?.invokeMethod('setLoop', loop);
  }

  Future<void> setSpeed(double speed) async {
    await methodChannel?.invokeMethod('setSpeed', speed);
  }

  Future<void> seekTo(int position) async {
    await methodChannel?.invokeMethod('seekTo', position);
  }

  Future<void> _enterPipPage() async {
    await Navigator.of(context!).push(PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          APlayerPip(controller: this),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return child;
      },
    ));
  }

  Future<bool> enterPip(BuildContext context) async {
    if (isPipMode) {
      return true;
    }
    screenSize = MediaQuery.of(context).size;
    isPipMode = await methodChannel?.invokeMethod('enterPip');
    if (isPipMode) {
      this.context = context;
      _enterPipPage();
    } else {
      methodChannel?.invokeMethod('openSettings');
    }
    return isPipMode;
  }

  void exitPip() {
    isPipMode = false;
    if (context != null) {
      final size = MediaQuery.of(context!).size;
      if (size == screenSize) {
        Navigator.of(context!).pop();
      }
    }
  }

  void setFit(APlayerFit fit) async {
    _fit = fit;
    notifyListeners();
  }

  Future<void> setMirrorMode(APlayerMirrorMode mode) async {
    _mirrorMode = mode;
    notifyListeners();
  }

  void _listen() {
    eventChannel?.receiveBroadcastStream().listen((event) {
      switch (event['type'] as String) {
        case "initializing":
          _onInitializing.notifyListeners();
          break;
        case "initialized":
          _kernel = APlayerKernel.values[event['data']];
          notifyListeners();
          _onInitialized.notifyListeners();
          break;
        case "readyToPlay":
          _onReadyToPlay.value = VideoReadyData.fromJSON(event['data']);
          _onReadyToPlay.notifyListeners();
          break;
        case "videoSizeChanged":
          final size = VideoSizeChangedData.fromJSON(event['data']);
          _videoHeight = size.height;
          _videoWidth = size.width;
          notifyListeners();
          _onVideoSizeChanged.value = size;
          _onVideoSizeChanged.notifyListeners();
          break;
        case "loadingBegin":
          _onLoadingBegin.notifyListeners();
          break;
        case "loadingProgress":
          _onLoadingProgress.value = event['data'] as int;
          _onLoadingProgress.notifyListeners();
          break;
        case "loadingEnd":
          _onLoadingEnd.notifyListeners();
          break;
        case "currentPositionChanged":
          _onCurrentPositionChanged.value = event['data'] as int;
          _onCurrentPositionChanged.notifyListeners();
          break;
        case "currentDownloadSpeedChanged":
          _onCurrentDownloadSpeedChanged.value = event['data'] as int;
          _onCurrentDownloadSpeedChanged.notifyListeners();
          break;
        case "bufferedPositionChanged":
          _onBufferedPositionChanged.value = event['data'] as int;
          _onBufferedPositionChanged.notifyListeners();
          break;
        case "playing":
          _onPlaying.value = event['data'] as bool;
          _onPlaying.notifyListeners();
          break;
        case "error":
          _onError.value = event['data'] as String;
          _onError.notifyListeners();
          break;
        case "completion":
          _onCompletion.notifyListeners();
          break;
      }
    });
  }

  @mustCallSuper
  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    release();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.resumed:
        exitPip();
        break;
      default:
        break;
    }
  }
}
