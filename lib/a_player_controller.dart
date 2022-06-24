import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'a_player_constant.dart';
import 'a_player_value.dart';

const _methodChannel = MethodChannel(APlayerConstant.methodChannelName);

abstract class APlayerControllerInterface extends ValueNotifier<APlayerValue> {
  EventChannel? eventChannel;
  MethodChannel? methodChannel;
  int textureId = -1;
  APlayerFit _fit = APlayerFit.fitDefault;

  APlayerControllerInterface() : super(APlayerValue.uninitialized());

  bool get hasTextureId => textureId != -1;

  APlayerFit get fit => _fit;

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
      value = APlayerValue.fromJSON(event);
      notifyListeners();
    });
  }

  @mustCallSuper
  @override
  void dispose() {
    super.dispose();
    release();
  }
}
