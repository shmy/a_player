import 'package:a_player/a_player_constant.dart';
import 'package:a_player/a_player_controller.dart';
import 'package:a_player/a_player_value.dart';
import 'package:a_player_example/local_widgets/att_video_player_constant.dart';
import 'package:a_player_example/local_widgets/att_video_player_ui_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AttVideoPlayerController with WidgetsBindingObserver {
  final AttVideoPlayerUIController uiController = AttVideoPlayerUIController();
  final APlayerController _aPlayerController = APlayerController();
  final Rx<AttVideoPlayerStatus> _status =
      Rx<AttVideoPlayerStatus>(AttVideoPlayerStatus.idle);
  final Rxn<AttVideoAnalysisResult> _analysisResult =
      Rxn<AttVideoAnalysisResult>(null);
  final List<AttVideoItem> _playlist = [];
  int _playIndex = -1;
  bool _visible = true;
  bool _freezed = false;
  VoidCallback? _beforePlayCallback;
  ValueChanged<int>? _onPlayIndexChangedCallback;
  AttVideoAnalyzer? _videoAnalyzerCallback;

  APlayerController get aPlayerController => _aPlayerController;

  AttVideoPlayerStatus get status => _status.value;

  AttVideoAnalysisResult? get analysisResult => _analysisResult.value;

  AttVideoPlayerController() {
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> initialize() async {
    _status.value = AttVideoPlayerStatus.initializing;
    aPlayerController
      ..onInitialized(_onInitialized)
      ..onReadyToPlay(_onReadyToPlay)
      ..onError(_onError)
      ..onCompletion(_onCompletion)
      ..onCurrentPositionChanged(_onCurrentPositionChanged)
      ..onCurrentDownloadSpeedChanged((int speed) {
        print('onCurrentDownloadSpeedChanged $speed');
      });
    await aPlayerController.initialize();
    await aPlayerController.setKernel(APlayerKernel.aliyun, 0);
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

  void playByIndex(int index) {
    if (_playIndex != index) {
      _playIndex = index;
      final AttVideoItem video = _playlist[_playIndex];
      _startAnalyzeToPlay(video);
    }
  }

  Future<void> _startAnalyzeToPlay(AttVideoItem video) async {
    aPlayerController.stop();
    if (_videoAnalyzerCallback == null) {
      _setDataSource(video.source);
      return;
    }
    _status.value = AttVideoPlayerStatus.analyzing;
    final AttVideoAnalysisResult result =
        await _videoAnalyzerCallback!.call(video);
    if (result.isSuccess) {
      _analysisResult.value = result;
      if (!result.playable) {
        _status.value = AttVideoPlayerStatus.nonPlayable;
      } else {
        _setDataSource(result.url,
            headers: result.headers, position: result.position);
      }
    } else {
      _status.value = AttVideoPlayerStatus.analysisFailed;
    }
  }

  void _setDataSource(
    String dataSource, {
    APlayerKernel kernel = APlayerKernel.aliyun,
    List<APlayerConfigHeader> headers = const [],
    int position = 0,
  }) async {
    aPlayerController.clearOnPlayingListener();
    // TODO: setKernel
    // await aPlayerController.setKernel(kernel, position);
    _status.value = AttVideoPlayerStatus.preparing;
    await aPlayerController.setDataSouce(
      dataSource,
      headers: headers,
      position: position,
    );
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
    // aPlayerController.onPlaying(_onPlaying);
    if (_beforePlayCallback != null) {
      _freezed = true;
      _beforePlayCallback?.call();
    } else {
      aPlayerController.play();
    }
    _status.value = AttVideoPlayerStatus.readyToPlay;
  }

  void _onError(_) {
    _status.value = AttVideoPlayerStatus.playFailed;
  }

  void _onCompletion(_) {
    _status.value = AttVideoPlayerStatus.playCompleted;
  }

  void _onCurrentPositionChanged(int position) {
    _trySee(position);
  }
  void _onPlaying(bool playing) {
    if (playing) {
      _status.value = AttVideoPlayerStatus.playing;
    } else {
      _status.value = AttVideoPlayerStatus.paused;
    }
  }

  void _trySee(int position) {
    if (analysisResult == null) {
      return;
    }
    if (analysisResult!.duration == 0) {
      return;
    }
    if (position >= analysisResult!.duration) {
      _freezed = true;
      pause();
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
