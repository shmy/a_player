import 'package:flutter/material.dart';

class APlayerFitDefs {
  const APlayerFitDefs({
    this.alignment = Alignment.center,
    this.aspectRatio = -1,
    this.sizeFactor = 1.0,
  });

  final Alignment alignment;
  final double aspectRatio;
  final double sizeFactor;

  static const APlayerFitDefs fill = APlayerFitDefs(
    sizeFactor: 1.0,
    aspectRatio: double.infinity,
    alignment: Alignment.center,
  );

  static const APlayerFitDefs contain = APlayerFitDefs(
    sizeFactor: 1.0,
    aspectRatio: -1,
    alignment: Alignment.center,
  );

  static const APlayerFitDefs cover = APlayerFitDefs(
    sizeFactor: -0.5,
    aspectRatio: -1,
    alignment: Alignment.center,
  );

  // static const APlayerFitDefs fitWidth = APlayerFitDefs(sizeFactor: -1.5);
  // static const APlayerFitDefs fitHeight = APlayerFitDefs(sizeFactor: -2.5);
  static const APlayerFitDefs ar16_9 = APlayerFitDefs(aspectRatio: 16.0 / 9.0);
  static const APlayerFitDefs ar4_3 = APlayerFitDefs(aspectRatio: 4.0 / 3.0);
  static const APlayerFitDefs ar1_1 = APlayerFitDefs(aspectRatio: 1.0 / 1.0);
  static APlayerFitDefs fromEnum(APlayerFitMode fitMode) {
    switch(fitMode) {
      case APlayerFitMode.contain:
       return contain;
      case APlayerFitMode.fill:
        return fill;
      case APlayerFitMode.cover:
        return cover;
      case APlayerFitMode.ar16_9:
        return ar16_9;
      case APlayerFitMode.ar4_3:
        return ar4_3;
      case APlayerFitMode.ar1_1:
        return ar1_1;
    }
  }
}


enum APlayerFitMode { contain, fill, cover, ar16_9, ar4_3, ar1_1 }

enum APlayerMirrorMode { none, horizontal, vertical }

enum APlayerKernel { aliyun, ijk, exo, av }

class VideoSizeChangedData {
  final int height;
  final int width;

  VideoSizeChangedData(this.height, this.width);

  factory VideoSizeChangedData.fromJSON(dynamic json) =>
      VideoSizeChangedData(json['height'], json['width']);
}

class VideoReadyData {
  final int duration;
  final double playSpeed;

  VideoReadyData(this.duration, this.playSpeed);

  factory VideoReadyData.fromJSON(dynamic json) =>
      VideoReadyData(json['duration'], json['playSpeed']);
}
// class APlayerValue {
//   final bool isInitialized;
//   final bool isPlaying;
//   final bool isError;
//   final bool isCompletion;
//   final bool isReadyToPlay;
//   final String errorDescription;
//   final Duration duration;
//   final Duration position;
//   final int height;
//   final int width;
//   final double playSpeed;
//   final bool loop;
//   final bool isBuffering;
//   final int bufferingPercentage;
//   final int bufferingSpeed;
//   final Duration buffered;
//   final bool featurePictureInPicture;
//   final APlayerKernel kernel;
//
//   APlayerValue({
//     required this.isInitialized,
//     required this.isPlaying,
//     required this.isError,
//     required this.isCompletion,
//     required this.isReadyToPlay,
//     required this.errorDescription,
//     required this.duration,
//     required this.position,
//     required this.height,
//     required this.width,
//     required this.playSpeed,
//     required this.loop,
//     required this.isBuffering,
//     required this.bufferingPercentage,
//     required this.bufferingSpeed,
//     required this.buffered,
//     required this.featurePictureInPicture,
//     required this.kernel,
//   });
//
//   factory APlayerValue.uninitialized() => APlayerValue(
//         isInitialized: false,
//         isPlaying: false,
//         isError: false,
//         isCompletion: false,
//         isReadyToPlay: false,
//         errorDescription: '',
//         duration: Duration.zero,
//         position: Duration.zero,
//         height: 9,
//         width: 16,
//         playSpeed: 1.0,
//         loop: false,
//         isBuffering: false,
//         bufferingPercentage: 0,
//         bufferingSpeed: 0,
//         buffered: Duration.zero,
//         featurePictureInPicture: false,
//         kernel: APlayerKernel.aliyun,
//       );
//
//   factory APlayerValue.fromJSON(dynamic json) => APlayerValue(
//         isInitialized: json['isInitialized'],
//         isPlaying: json['isPlaying'],
//         isError: json['isError'],
//         isCompletion: json['isCompletion'],
//         isReadyToPlay: json['isReadyToPlay'],
//         errorDescription: json['errorDescription'],
//         duration: Duration(milliseconds: json['duration']),
//         position: Duration(milliseconds: json['position']),
//         height: json['height'],
//         width: json['width'],
//         playSpeed: json['playSpeed'],
//         loop: json['loop'],
//         isBuffering: json['isBuffering'],
//         bufferingPercentage: json['bufferingPercentage'],
//         bufferingSpeed: json['bufferingSpeed'],
//         buffered: Duration(milliseconds: json['buffered']),
//         featurePictureInPicture: json['featurePictureInPicture'],
//         kernel: APlayerKernel.values[json['kernel']],
//       );
// }
