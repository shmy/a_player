import 'dart:async';

import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'a_player_constant.dart';
import 'a_player_value.dart';

const _methodChannel = MethodChannel(APlayerConstant.methodChannelName);

class APlayerController extends ChangeNotifier with WidgetsBindingObserver {
  EventChannel? eventChannel;
  MethodChannel? methodChannel;
  int textureId = -1;
  APlayerFit _fit = APlayerFit.contain;
  APlayerMirrorMode _mirrorMode = APlayerMirrorMode.none;
  int _videoHeight = 0;
  int _videoWidth = 0;
  final StreamController<APlayerValue> _streamController =
      StreamController<APlayerValue>();

  bool get hasTextureId => textureId != -1;

  APlayerFit get fit => _fit;

  APlayerMirrorMode get mirrorMode => _mirrorMode;

  int get videoHeight => _videoHeight;

  int get videoWidth => _videoWidth;
  bool isPipMode = false;
  BuildContext? context;

  Stream<APlayerValue> get stream => _streamController.stream;
  Throttle<APlayerValue>? _streamThrottle;

  @mustCallSuper
  Future<void> initialize({
  APlayerKernel kernel = APlayerKernel.ijk
}) async {
    final textureId = await _methodChannel.invokeMethod<int>('initialize', kernel.index);
    if (textureId != null) {
      WidgetsBinding.instance.addObserver(this);
      this.textureId = textureId;
      eventChannel =
          EventChannel('${APlayerConstant.playerEventChanneName}$textureId');
      methodChannel =
          MethodChannel('${APlayerConstant.playerMethodChannelName}$textureId');
      _streamThrottle = Throttle<APlayerValue>(
          const Duration(milliseconds: 100),
          initialValue: APlayerValue.uninitialized(), onChanged: (value) {
        _streamController.add(value);
      });
      _listen();
      notifyListeners();
    }
  }

  Future<void> setDataSouce(String source,
      {List<APlayerConfigHeader> headers = const [],
      bool isAutoPlay = true}) async {
    String? userAgent;
    String? referer;
    List<String> customHeaders = [];
    for (APlayerConfigHeader header in headers) {
      final String key = header.key.toUpperCase();
      if (key == "USER-AGENT") {
        userAgent = header.value;
      } else if (key == "REFERER") {
        referer = header.value;
      } else {
        customHeaders.add('${header.key}:${header.value}');
      }
    }
    await methodChannel?.invokeMethod('setDataSource', {
      "url": source,
      "userAgent": userAgent,
      "referer": referer,
      "customHeaders": customHeaders
    });
    prepare(isAutoPlay: isAutoPlay);
  }

  Future<void> play() async {
    await methodChannel?.invokeMethod('play');
  }

  Future<void> pause() async {
    await methodChannel?.invokeMethod('pause');
  }

  Future<void> prepare({bool isAutoPlay = true}) async {
    await methodChannel?.invokeMethod('prepare', isAutoPlay);
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
  Future<void> setKernel(APlayerKernel kernel) async {
    await methodChannel?.invokeMethod('setKernel', kernel.index);
  }

  Future<void> seekTo(int position) async {
    await methodChannel?.invokeMethod('seekTo', position);
  }

  Future<void> setHardwareDecoderEnable(bool loop) async {
    await methodChannel?.invokeMethod('setHardwareDecoderEnable', loop);
  }

  void enterPip(BuildContext context) {
    if (isPipMode) {
      return;
    }
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
      Navigator.of(context!).pop();
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
      final APlayerValue value = APlayerValue.fromJSON(event);
      if (value.height != _videoHeight || value.width != _videoWidth) {
        _videoHeight = value.height;
        _videoWidth = value.width;
        notifyListeners();
      }
      if (!_streamController.isClosed) {
        _streamThrottle?.setValue(value);
      }
    });
  }

  @mustCallSuper
  @override
  void dispose() {
    super.dispose();
    _streamController.close();
    _streamThrottle?.cancel();
    _streamThrottle = null;
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
