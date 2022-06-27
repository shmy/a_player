import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'a_player_constant.dart';
import 'a_player_value.dart';

const _methodChannel = MethodChannel(APlayerConstant.methodChannelName);

class APlayerController extends ChangeNotifier {
  EventChannel? eventChannel;
  MethodChannel? methodChannel;
  int textureId = -1;
  APlayerFit _fit = APlayerFit.contain;
  int _videoHeight = 0;
  int _videoWidth = 0;
  final StreamController<APlayerValue> _streamController = StreamController<APlayerValue>();

  bool get hasTextureId => textureId != -1;

  APlayerFit get fit => _fit;
  int get videoHeight => _videoHeight;
  int get videoWidth => _videoWidth;

  Stream<APlayerValue> get stream => _streamController.stream;
  @mustCallSuper
  Future<void> initialize() async {
    final textureId =
        await _methodChannel.invokeMethod<int>('initialize');
    if (textureId != null) {
      this.textureId = textureId;
      eventChannel = EventChannel('${APlayerConstant.playerEventChanneName}$textureId');
      methodChannel = MethodChannel('${APlayerConstant.playerMethodChannelName}$textureId');
      _listen();
      notifyListeners();
    }
  }
  Future<void> setDataSouce(String source,
      {List<APlayerConfigHeader> headers = const [], bool isAutoPlay = true}) async {
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

  Future<void> reload() async {
    await methodChannel?.invokeMethod('reload');
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

  Future<void> setMirrorMode(int mode) async {
    await methodChannel?.invokeMethod('setMirrorMode', mode);
  }

  Future<void> setHardwareDecoderEnable(bool loop) async {
    await methodChannel?.invokeMethod('setHardwareDecoderEnable', loop);
  }

  void setFit(APlayerFit fit) async {
    _fit = fit;
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
        _streamController.add(value);
      }
    });
  }

  @mustCallSuper
  @override
  void dispose() {
    super.dispose();
    _streamController.close();
    release();
  }
}
