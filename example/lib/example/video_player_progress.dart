import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class VideoPlayerProgressColors {
  VideoPlayerProgressColors({
    required Color playedColor,
    required Color bufferedColor,
    required Color handleColor,
    required Color backgroundColor,
  })  : playedPaint = Paint()..color = playedColor,
        bufferedPaint = Paint()..color = bufferedColor,
        handlePaint = Paint()..color = handleColor,
        backgroundPaint = Paint()..color = backgroundColor;

  final Paint playedPaint;
  final Paint bufferedPaint;
  final Paint handlePaint;
  final Paint backgroundPaint;
}

class VideoPlayerProgress extends StatefulWidget {
  const VideoPlayerProgress({
    Key? key,
    this.handleImage,
    this.onChangeStart,
    this.onChanged,
    this.onChangeEnd,
    required this.colors,
    required this.position,
    required this.duration,
    required this.buffered,
    required this.barHeight,
    required this.handleHeight,
  }) : super(key: key);

  final Duration buffered;
  final int position;
  final int duration;
  final ui.Image? handleImage;
  final VideoPlayerProgressColors colors;
  final ValueChanged<double>? onChangeStart;
  final ValueChanged<double>? onChanged;
  final ValueChanged<double>? onChangeEnd;

  final double barHeight;
  final double handleHeight;

  @override
  State<VideoPlayerProgress> createState() => _VideoPlayerProgressState();
}

class _VideoPlayerProgressState extends State<VideoPlayerProgress> {
  double _lastPosition = 0.0;

  void _calcRelativePosition(Offset globalPosition) {
    final box = context.findRenderObject()! as RenderBox;
    final Offset tapPos = box.globalToLocal(globalPosition);
    final double relative = tapPos.dx / box.size.width;
    _lastPosition = widget.duration * relative;
    if (_lastPosition < 0) {
      _lastPosition = 0;
    }
    if (_lastPosition > widget.duration) {
      _lastPosition = widget.duration.toDouble();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: (DragStartDetails details) {
        _calcRelativePosition(details.globalPosition);
        widget.onChangeStart?.call(_lastPosition);
      },
      onHorizontalDragUpdate: (DragUpdateDetails details) {
        _calcRelativePosition(details.globalPosition);
        widget.onChanged?.call(_lastPosition);
      },
      onHorizontalDragEnd: (DragEndDetails details) {
        widget.onChangeEnd?.call(_lastPosition);
      },
      // onTapDown: (TapDownDetails details) {
      //   _seekToRelativePosition(details.globalPosition);
      // },
      child: Center(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: Colors.transparent,
          child: CustomPaint(
            painter: _ProgressBarPainter(
              duration: widget.duration,
              position: widget.position,
              buffered: widget.buffered,
              colors: widget.colors,
              barHeight: widget.barHeight,
              handleHeight: widget.handleHeight,
              handleImage: widget.handleImage,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressBarPainter extends CustomPainter {
  _ProgressBarPainter({
    required this.position,
    required this.duration,
    required this.buffered,
    required this.colors,
    required this.barHeight,
    required this.handleHeight,
    this.handleImage,
  });

  final ui.Image? handleImage;
  final Duration buffered;
  final int position;
  final int duration;
  final VideoPlayerProgressColors colors;
  final double barHeight;
  final double handleHeight;

  @override
  bool shouldRepaint(CustomPainter painter) {
    return true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final baseOffset = size.height / 2 - barHeight / 2;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromPoints(
          Offset(0.0, baseOffset),
          Offset(size.width, baseOffset + barHeight),
        ),
        const Radius.circular(4.0),
      ),
      colors.backgroundPaint,
    );
    if (duration == 0) {
      return;
    }
    final double playedPartPercent = position / duration;
    final double playedPart =
    playedPartPercent > 1 ? size.width : playedPartPercent * size.width;

    final double bufferedPartPercent = buffered.inSeconds / duration;
    final double bufferedEndPart =
    bufferedPartPercent > 1 ? size.width : bufferedPartPercent * size.width;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromPoints(
          Offset(0.0, baseOffset),
          Offset(bufferedEndPart, baseOffset + barHeight),
        ),
        const Radius.circular(4.0),
      ),
      colors.bufferedPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromPoints(
          Offset(0.0, baseOffset),
          Offset(playedPart, baseOffset + barHeight),
        ),
        const Radius.circular(4.0),
      ),
      colors.playedPaint,
    );

    if (handleImage != null) {
      canvas.drawImageRect(
        handleImage!,
        Rect.fromLTWH(0, 0, handleImage!.width.toDouble(),
            handleImage!.height.toDouble()),
        Rect.fromLTWH(playedPart, (size.height - handleHeight) / 2,
            handleHeight, handleHeight),
        colors.handlePaint,
      );
    } else {
      canvas.drawCircle(
        Offset(playedPart, baseOffset + barHeight / 2),
        handleHeight / 2,
        colors.handlePaint,
      );
    }
  }
}
