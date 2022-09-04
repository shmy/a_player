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

  final Rxn<AttVideoAnalysisResult> _analysisResult =
      Rxn<AttVideoAnalysisResult>(null);
  final List<AttVideoItem> _playlist = [];
  int _playIndex = -1;
  bool _visible = true;
  bool _freezed = false;
  VoidCallback? _blockAutoPlayCallback;
  ValueChanged<int>? _onPlayIndexChangedCallback;
  AttVideoAnalyzer? _videoAnalyzerCallback;

  APlayerController get aPlayerController => _aPlayerController;

  AttVideoAnalysisResult? get analysisResult => _analysisResult.value;

  AttVideoPlayerController() {
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> initialize() async {
    uiController.status.value = AttVideoPlayerStatus.initializing;
    aPlayerController.onInitialized.addListener(_onInitialized);
    aPlayerController.onVideoSizeChanged.addListener(_onVideoSizeChanged);
    aPlayerController.onReadyToPlay.addListener(_onReadyToPlay);
    aPlayerController.onError.addListener(_onError);
    aPlayerController.onCompletion.addListener(_onCompletion);
    aPlayerController.onCurrentPositionChanged.addListener(_onCurrentPositionChanged);
    aPlayerController.onBufferedPositionChanged.addListener(_onBufferedPositionChanged);
    aPlayerController.onCurrentDownloadSpeedChanged.addListener(_onCurrentDownloadSpeedChanged);
    aPlayerController.onLoadingProgress.addListener(_onLoadingProgress);
    aPlayerController.onLoadingBegin.addListener(_onLoadingBegin);
    aPlayerController.onLoadingEnd.addListener(_onLoadingEnd);

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

  void setBlockAutoPlayCallback(VoidCallback callback) {
    _blockAutoPlayCallback = callback;
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
    aPlayerController.onPlaying.removeListener(_onPlaying);
    aPlayerController.stop();
    uiController.resetState();
    if (_videoAnalyzerCallback == null) {
      _setDataSource(video.source);
      return;
    }
    uiController.status.value = AttVideoPlayerStatus.analyzing;
    final AttVideoAnalysisResult result =
        await _videoAnalyzerCallback!.call(video);
    if (result.isSuccess) {
      _analysisResult.value = result;
      if (!result.playable) {
        uiController.status.value = AttVideoPlayerStatus.nonPlayable;
      } else {
        _setDataSource(result.url,
            headers: result.headers, position: result.position);
      }
    } else {
      uiController.status.value = AttVideoPlayerStatus.analysisFailed;
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
    uiController.status.value = AttVideoPlayerStatus.preparing;
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

  void _onInitialized() {
    uiController.status.value = AttVideoPlayerStatus.initialized;
  }

  void _onVideoSizeChanged() {
    final VideoSizeChangedData size = aPlayerController.onVideoSizeChanged.value;
    uiController.height.value = size.height;
    uiController.width.value = size.width;
  }

  void _onReadyToPlay() {
    aPlayerController.onPlaying.addListener(_onPlaying);
    if (_blockAutoPlayCallback != null) {
      _freezed = true;
      _blockAutoPlayCallback?.call();
    } else {
      aPlayerController.play();
    }
    uiController.duration.value = Duration(milliseconds: aPlayerController.onReadyToPlay.value.duration);
    uiController.playSpeed.value = aPlayerController.onReadyToPlay.value.playSpeed;
    uiController.status.value = AttVideoPlayerStatus.readyToPlay;
  }

  void _onError() {
    final String errorDescription = aPlayerController.onError.value;
    uiController.status.value = AttVideoPlayerStatus.playFailed;
    uiController.errorDescription.value = errorDescription;
  }

  void _onCompletion() {
    uiController.isCompletion.value = true;
  }

  void _onCurrentPositionChanged() {
    final int position = aPlayerController.onCurrentPositionChanged.value;
    uiController.position.value = Duration(milliseconds: position);
    _trySee(position);
  }

  void _onBufferedPositionChanged() {
    final int buffered = aPlayerController.onBufferedPositionChanged.value;
    uiController.buffered.value = Duration(milliseconds: buffered);
  }
  void _onLoadingProgress() {
    final int progress = aPlayerController.onLoadingProgress.value;
    uiController.bufferingPercentage.value = progress;
  }
  void _onLoadingBegin() {
    uiController.isBuffering.value = true;
  }
  void _onLoadingEnd() {
    uiController.isBuffering.value = false;
  }
  void _onCurrentDownloadSpeedChanged() {
    final int speed = aPlayerController.onCurrentDownloadSpeedChanged.value;
    uiController.bufferingSpeed.value = speed;
  }

  void _onPlaying() {
    final bool playing = aPlayerController.onPlaying.value;
    if (playing) {
      uiController.status.value = AttVideoPlayerStatus.playing;
    } else {
      uiController.status.value = AttVideoPlayerStatus.paused;
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
      uiController.isTryItToEnd.value = true;
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
