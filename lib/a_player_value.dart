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

enum APlayerKernel { aliyun, ijk, exo, av }

class VideoSizeChangedData {
  final int height;
  final int width;
  VideoSizeChangedData(this.height, this.width);
  factory VideoSizeChangedData.fromJSON(dynamic json) => VideoSizeChangedData(json['height'], json['width']);
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
