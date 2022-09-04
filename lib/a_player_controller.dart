import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'a_player_constant.dart';
import 'a_player_value.dart';

const _methodChannel = MethodChannel(APlayerConstant.methodChannelName);

typedef VideoSizeChangedCallback = void Function(int height, int width);

class APlayerValueListener<T> {
  final List<ValueChanged<T>> listeners = [];

  void addListener(ValueChanged<T> listener) {
    listeners.add(listener);
  }

  void notify(T value) {
    for (var listener in listeners) {
      listener.call(value);
    }
  }
}

mixin APlayerControllerListener {
  final APlayerValueListener<void> _onInitialized = APlayerValueListener<void>();
  final APlayerValueListener<void> _onReadyToPlay = APlayerValueListener<void>();
  final APlayerValueListener<VideoSizeChangedData> _onVideoSizeChanged =
      APlayerValueListener<VideoSizeChangedData>();
  final APlayerValueListener<void> _onLoadingBegin = APlayerValueListener<void>();
  final APlayerValueListener<int> _onLoadingProgress = APlayerValueListener<int>();
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

  ValueChanged<ValueChanged<void>> get onInitialized => _onInitialized.addListener;
  ValueChanged<ValueChanged<void>> get onReadyToPlay => _onReadyToPlay.addListener;
  ValueChanged<ValueChanged<VideoSizeChangedData>> get onVideoSizeChanged => _onVideoSizeChanged.addListener;
  ValueChanged<ValueChanged<void>> get onloadingBegin => _onLoadingBegin.addListener;
  ValueChanged<ValueChanged<int>> get onLoadingProgress => _onLoadingProgress.addListener;
  ValueChanged<ValueChanged<void>> get onLoadingEnd => _onLoadingEnd.addListener;
  ValueChanged<ValueChanged<int>> get onCurrentPositionChanged => _onCurrentPositionChanged.addListener;
  ValueChanged<ValueChanged<int>> get onCurrentDownloadSpeedChanged => _onCurrentDownloadSpeedChanged.addListener;
  ValueChanged<ValueChanged<int>> get onBufferedPositionChanged => _onBufferedPositionChanged.addListener;
  ValueChanged<ValueChanged<bool>> get onPlaying => _onPlaying.addListener;
  ValueChanged<ValueChanged<String>> get onError => _onError.addListener;
  ValueChanged<ValueChanged<void>> get onCompletion => _onCompletion.addListener;
  void clearOnPlayingListener() {
    _onPlaying.listeners.clear();
  }
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

  bool get hasTextureId => textureId != -1;

  APlayerFit get fit => _fit;

  APlayerMirrorMode get mirrorMode => _mirrorMode;

  int get videoHeight => _videoHeight;

  int get videoWidth => _videoWidth;
  bool isPipMode = false;
  BuildContext? context;
  Size screenSize = Size.zero;

  @mustCallSuper
  Future<void> initialize({APlayerKernel kernel = APlayerKernel.ijk}) async {
    final textureId =
        await _methodChannel.invokeMethod<int>('initialize', kernel.index);
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

  Future<void> setDataSouce(String source,
      {List<APlayerConfigHeader> headers = const [], int position = 0}) async {
    Map<String, String> httpHeaders = {};
    for (var header in headers) {
      httpHeaders[header.key] = header.value;
    }
    await methodChannel?.invokeMethod('setDataSource', {
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

  Future<void> setKernel(APlayerKernel kernel, int position) async {
    await methodChannel?.invokeMethod('setKernel', {
      "kernel": kernel.index,
      "position": position,
    });
  }

  Future<void> seekTo(int position) async {
    await methodChannel?.invokeMethod('seekTo', position);
  }

  void enterPip(BuildContext context) {
    if (isPipMode) {
      return;
    }
    screenSize = MediaQuery.of(context).size;
    methodChannel?.invokeMethod('enterPip').then((isOpened) {
      isPipMode = isOpened;
      if (isOpened) {
        this.context = context;
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return Material(
            color: Colors.black,
            child: Align(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Texture(
                  textureId: textureId,
                ),
              ),
            ),
          );
        }));
      } else {
        methodChannel?.invokeMethod('openSettings');
      }
    });
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
        case "initialized":
          _onInitialized.notify(null);
          break;
        case "readyToPlay":
          _onReadyToPlay.notify(null);
          break;
        case "videoSizeChanged":
          final size = VideoSizeChangedData.fromJSON(event['data']);
          _videoHeight = size.height;
          _videoWidth = size.width;
          notifyListeners();
          _onVideoSizeChanged.notify(size);
          break;
        case "loadingBegin":
          _onLoadingBegin.notify(null);
          break;
        case "loadingProgress":
          _onLoadingProgress.notify(event['data'] as int);
          break;
        case "loadingEnd":
          _onLoadingEnd.notify(null);
          break;
        case "currentPositionChanged":
          _onCurrentPositionChanged.notify(event['data'] as int);
          break;
        case "currentDownloadSpeedChanged":
          _onCurrentDownloadSpeedChanged.notify(event['data'] as int);
          break;
        case "bufferedPositionChanged":
          _onBufferedPositionChanged.notify(event['data'] as int);
          break;
        case "playing":
          _onPlaying.notify(event['data'] as bool);
          break;
        case "error":
          _onError.notify(event['data'] as String);
          break;
        case "completion":
          _onCompletion.notify(null);
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
