import 'package:a_player/a_player_controller.dart';
import 'package:a_player/a_player_value.dart';
import 'package:a_player_example/local_widgets/att_video_player_constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

typedef ValueCallback<T> = T Function();

class AttVideoPlayerController with WidgetsBindingObserver {
  final APlayerController _aPlayerController = APlayerController();
  final Rx<AttVideoPlayerStatus> _status =
      Rx<AttVideoPlayerStatus>(AttVideoPlayerStatus.idle);
  APlayerController get aPlayerController => _aPlayerController;
  AttVideoPlayerStatus get status => _status.value;
  bool _visible = true;
  bool _freezed = false;
  ValueCallback<bool>? _autoPlayInspector;

  AttVideoPlayerController() {
    WidgetsBinding.instance.addObserver(this);
    _initialize();
  }


  Future<void> _initialize() async {
    _status.value = AttVideoPlayerStatus.initializing;
    aPlayerController
      ..onInitialized((_) {
        _status.value = AttVideoPlayerStatus.initialized;
        print('onInitialized');
      })
      ..onReadyToPlay(_onReadyToPlay)
      ..onCompletion((_) {
        print('onCompletion');
      })
      ..onCurrentPositionChanged((int position) {
        print('onCurrentPositionChanged $position');
      })
      ..onCurrentDownloadSpeedChanged((int speed) {
        print('onCurrentDownloadSpeedChanged $speed');
      })
      ..onPlaying((bool playing) {
        print('onPlaying $playing');
      })
      ..onVideoSizeChanged((VideoSizeChangedData data) {
        print('onVideoSizeChanged: $data');
      });
    await aPlayerController.initialize();
    await aPlayerController.setKernel(APlayerKernel.ijk, 0);
    await aPlayerController.setDataSouce(
        'https://vfx.mtime.cn/Video/2019/02/04/mp4/190204084208765161.mp4');
  }

  void setVisible(bool visible) {
    _visible = visible;
    if (_visible) {
      if (!_freezed) {
        play();
      }
    } else {
      pause();
    }
  }

  void setAutoPlayInspector(ValueCallback<bool>? inspector) {
    _autoPlayInspector = inspector;
  }

  void play() {
    _freezed = false;
    aPlayerController.play();
  }
  void pause() {
    aPlayerController.pause();
  }

  void dispose() {
    aPlayerController.dispose();
  }

  void _onReadyToPlay(_) {
    if (_autoPlayInspector != null) {
      if (_autoPlayInspector!.call()) {
        aPlayerController.play();
      } else {
        _freezed = true;
      }
    } else {
      aPlayerController.play();
    }
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        if (_visible) {
          pause();
        }
        break;
      case AppLifecycleState.resumed:
        if (!_freezed && _visible) {
          play();
        }
        break;
      default:
        break;
    }
  }
}
