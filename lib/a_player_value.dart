class APlayerRatio {
  APlayerRatio._();
  static const double ratio16x9 = 16 / 9;
  static const double ratio4x3 = 4 / 3;
  static const double ratio1x1 = 1.0;
}
enum APlayerFit {
  fitDefault,
  fit16x9,
  fit4x3,
  fit1x1,
  fitStretch,
  fitFill
}

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
  final int mirrorMode;
  final bool loop;
  final bool enableHardwareDecoder;
  final bool isBuffering;
  final int bufferingPercentage;
  final double bufferingSpeed;
  final Duration buffered;

  bool get isUnknow => state == _APlayerState.unknow;

  bool get isIdle => state == _APlayerState.idle;

  bool get isInitialized => ![_APlayerState.unknow, _APlayerState.idle, _APlayerState.error].contains(state);

  bool get isPrepared => state == _APlayerState.prepared;

  bool get isStarted => state == _APlayerState.started;

  bool get isPaused => state == _APlayerState.paused;

  bool get isStopped => state == _APlayerState.stopped;

  bool get isCompletion => state == _APlayerState.completion;

  bool get isError => state == _APlayerState.error;

  double get aspectRatio {
    if (height == 0.0) {
      return APlayerRatio.ratio16x9;
    }
    return width / height;
  }

  APlayerValue(
      {required this.state,
      required this.errorDescription,
      required this.duration,
      required this.position,
      required this.height,
      required this.width,
      required this.playSpeed,
      required this.mirrorMode,
      required this.loop,
      required this.enableHardwareDecoder,
      required this.isBuffering,
      required this.bufferingPercentage,
      required this.bufferingSpeed,
      required this.buffered});

  @override
  String toString() {
    return 'APlayerValue(state: $state, errorDescription: $errorDescription, duration: $duration, position: $position, height: $height, width: $width, playSpeed: $playSpeed, mirrorMode: $mirrorMode, loop: $loop, enableHardwareDecoder: $enableHardwareDecoder, isBuffering: $isBuffering, bufferingPercentage: $bufferingPercentage, bufferingSpeed: $bufferingSpeed, buffered: $buffered)';
  }

  factory APlayerValue.uninitialized() => APlayerValue(
        state: -1,
        errorDescription: '',
        duration: Duration.zero,
        position: Duration.zero,
        height: 9,
        width: 16,
        playSpeed: 1.0,
        mirrorMode: 0,
        loop: false,
        enableHardwareDecoder: true,
        isBuffering: false,
        bufferingPercentage: 0,
        bufferingSpeed: 0,
        buffered: Duration.zero,
      );

  factory APlayerValue.fromJSON(dynamic json) => APlayerValue(
        state: json['state'],
        errorDescription: json['errorDescription'],
        duration: Duration(milliseconds: json['duration']),
        position: Duration(milliseconds: json['position']),
        height: json['height'],
        width: json['width'],
        playSpeed: json['playSpeed'],
        mirrorMode: json['mirrorMode'],
        loop: json['loop'],
        enableHardwareDecoder: json['enableHardwareDecoder'],
        isBuffering: json['isBuffering'],
        bufferingPercentage: json['bufferingPercentage'],
        bufferingSpeed: json['bufferingSpeed'],
        buffered: Duration(milliseconds: json['buffered']),
      );
}
