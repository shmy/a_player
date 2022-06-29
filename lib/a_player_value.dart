import 'package:flutter/material.dart';

class APlayerRatio {
  APlayerRatio._();

  static const double ratio16x9 = 16 / 9;
  static const double ratio4x3 = 4 / 3;
  static const double ratio1x1 = 1.0;
}

class APlayerFit {
  const APlayerFit(
      {this.alignment = Alignment.center,
      this.aspectRatio = -1,
      this.sizeFactor = 1.0});

  final Alignment alignment;
  final double aspectRatio;
  final double sizeFactor;

  static const APlayerFit fill = APlayerFit(
    sizeFactor: 1.0,
    aspectRatio: double.infinity,
    alignment: Alignment.center,
  );

  static const APlayerFit contain = APlayerFit(
    sizeFactor: 1.0,
    aspectRatio: -1,
    alignment: Alignment.center,
  );

  static const APlayerFit cover = APlayerFit(
    sizeFactor: -0.5,
    aspectRatio: -1,
    alignment: Alignment.center,
  );

  static const APlayerFit fitWidth = APlayerFit(sizeFactor: -1.5);
  static const APlayerFit fitHeight = APlayerFit(sizeFactor: -2.5);
  static const APlayerFit ar16_9 = APlayerFit(aspectRatio: 16.0 / 9.0);
  static const APlayerFit ar4_3 = APlayerFit(aspectRatio: 4.0 / 3.0);
  static const APlayerFit ar1_1 = APlayerFit(aspectRatio: 1.0 / 1.0);
}

enum APlayerMirrorMode { none, horizontal, vertical }

class _APlayerState {
  static const int unknow = -1;
  static const int idle = 0;
  static const int initalized = 1;
  static const int prepared = 2;
  static const int started = 3;
  static const int paused = 4;
  static const int stopped = 5;
  static const int completion = 6;
  static const int error = 7;
}

class APlayerValue {
  final int state;
  final String errorDescription;
  final Duration duration;
  final Duration position;
  final int height;
  final int width;
  final double playSpeed;
  final bool loop;
  final bool enableHardwareDecoder;
  final bool isBuffering;
  final int bufferingPercentage;
  final int bufferingSpeed;
  final Duration buffered;
  final bool featurePictureInPicture;
  final bool ready;

  bool get isUnknow => state == _APlayerState.unknow;

  bool get isIdle => state == _APlayerState.idle;

  bool get isInitialized => state == _APlayerState.initalized;

  bool get isPrepared => state == _APlayerState.prepared;

  bool get isStarted => state == _APlayerState.started;

  bool get isPaused => state == _APlayerState.paused;

  bool get isStopped => state == _APlayerState.stopped;

  bool get isCompletion => state == _APlayerState.completion;

  bool get isError => state == _APlayerState.error;

  APlayerValue(
      {required this.state,
      required this.errorDescription,
      required this.duration,
      required this.position,
      required this.height,
      required this.width,
      required this.playSpeed,
      required this.loop,
      required this.enableHardwareDecoder,
      required this.isBuffering,
      required this.bufferingPercentage,
      required this.bufferingSpeed,
      required this.buffered,
      required this.featurePictureInPicture,
      required this.ready});

  factory APlayerValue.uninitialized() => APlayerValue(
        state: -1,
        errorDescription: '',
        duration: Duration.zero,
        position: Duration.zero,
        height: 9,
        width: 16,
        playSpeed: 1.0,
        loop: false,
        enableHardwareDecoder: true,
        isBuffering: false,
        bufferingPercentage: 0,
        bufferingSpeed: 0,
        buffered: Duration.zero,
        featurePictureInPicture: false,
        ready: false,
      );

  factory APlayerValue.fromJSON(dynamic json) => APlayerValue(
        state: json['state'],
        errorDescription: json['errorDescription'],
        duration: Duration(milliseconds: json['duration']),
        position: Duration(milliseconds: json['position']),
        height: json['height'],
        width: json['width'],
        playSpeed: json['playSpeed'],
        loop: json['loop'],
        enableHardwareDecoder: json['enableHardwareDecoder'],
        isBuffering: json['isBuffering'],
        bufferingPercentage: json['bufferingPercentage'],
        bufferingSpeed: json['bufferingSpeed'],
        buffered: Duration(milliseconds: json['buffered']),
        featurePictureInPicture: json['featurePictureInPicture'],
        ready: json['ready'],
      );
}
