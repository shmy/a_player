import 'package:a_player/a_player_constant.dart';
import 'package:a_player/a_player_controller.dart';
import 'package:a_player/a_player_value.dart';
import 'package:a_player_example/local_widgets/att_video_player_constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AttVideoPlayerController with WidgetsBindingObserver {
  final APlayerController _aPlayerController = APlayerController();
  final Rx<AttVideoPlayerStatus> _status =
      Rx<AttVideoPlayerStatus>(AttVideoPlayerStatus.idle);
  final List<AttVideoItem> _playlist = [];
  int _playIndex = -1;
  bool _visible = true;
  bool _freezed = false;
  VoidCallback? _beforePlayCallback;
  ValueChanged<int>? _onPlayIndexChangedCallback;
  AttVideoAnalyzer? _videoAnalyzerCallback;

  APlayerController get aPlayerController => _aPlayerController;

  AttVideoPlayerStatus get status => _status.value;

  AttVideoPlayerController() {
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> initialize() async {
    _status.value = AttVideoPlayerStatus.initializing;
    aPlayerController
      ..onInitialized(_onInitialized)
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

  void setVideoAnalyzerCallback(AttVideoAnalyzer callback) {
    _videoAnalyzerCallback = callback;
  }

  void setBeforePlayCallback(VoidCallback callback) {
    _beforePlayCallback = callback;
  }

  void setPlayIndexChangedCallback(ValueChanged<int> callback) {
    _onPlayIndexChangedCallback = callback;
  }

  void setPlaylist(List<AttVideoItem> playlist) {
    _playlist.assignAll(playlist);
  }

  void playByIndex(int index) async {
    if (_playIndex != index) {
      _playIndex = index;
      final AttVideoItem video = _playlist[_playIndex];
      if (_videoAnalyzerCallback == null) {
        _setDataSource(video.source);
        return;
      }
      final AttVideoAnalysisResults result =
          await _videoAnalyzerCallback!.call(video);
      if (result.isSuccess) {
        _setDataSource(result.url, headers: result.headers, position: result.position);
      } else {
        _status.value = AttVideoPlayerStatus.analysisFailed;
      }
    }
  }

  void _setDataSource(
    String dataSource, {
    APlayerKernel kernel = APlayerKernel.aliyun,
    List<APlayerConfigHeader> headers = const [],
    int position = 0,
  }) async {
    // TODO: setKernel
    // await aPlayerController.setKernel(kernel, position);
    await aPlayerController.setDataSouce(dataSource, headers: headers, position: position);
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

  void _onInitialized(_) {
    _status.value = AttVideoPlayerStatus.initialized;
  }

  void _onReadyToPlay(_) {
    if (_beforePlayCallback != null) {
      _freezed = true;
      _beforePlayCallback?.call();
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
