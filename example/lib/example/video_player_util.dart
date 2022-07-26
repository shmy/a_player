import 'package:flutter/material.dart';

class VideoPlayerUtil {
  static String formatDuration(Duration duration) {
    int seconds = duration.inMilliseconds ~/ 1000;
    final int hours = seconds ~/ 3600;
    seconds = seconds % 3600;
    var minutes = seconds ~/ 60;
    seconds = seconds % 60;

    final hoursString = hours >= 10
        ? '$hours'
        : hours == 0
            ? '00'
            : '0$hours';

    final minutesString = minutes >= 10
        ? '$minutes'
        : minutes == 0
            ? '00'
            : '0$minutes';

    final secondsString = seconds >= 10
        ? '$seconds'
        : seconds == 0
            ? '00'
            : '0$seconds';

    final formattedTime =
        '${hoursString == '00' ? '' : '$hoursString:'}$minutesString:$secondsString';

    return formattedTime;
  }

  static String formatBytes(int count) {
    String unit = 'b';
    double result = count.toDouble();
    if (result >= 1024) {
      result = result / 1024;
      unit = 'KB';
    }
    if (result >= 1024) {
      result = result / 1024;

      unit = 'MB';
    }
    if (result >= 1024) {
      result = result / 1024;

      unit = 'GB';
    }
    if (result >= 1024) {
      result = result / 1024;
      unit = 'TB';
    }
    return '${result.toStringAsFixed(2)} $unit';
  }
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
