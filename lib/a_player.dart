import 'package:a_player/a_player_value.dart';
import 'package:flutter/material.dart';
import 'a_player_controller.dart';
import 'dart:math';

class APlayer extends StatefulWidget {
  final APlayerController controller;

  const APlayer({Key? key, required this.controller}) : super(key: key);

  @override
  State<APlayer> createState() => _APlayerState();
}

class _APlayerState extends State<APlayer> {
  int _videoHeight = 0;
  int _videoWidth = 0;

  @override
  void initState() {
    widget.controller.addListener(_listenter);
    super.initState();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_listenter);
    super.dispose();
  }

  void _listenter() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.black,
      ),
      child: Builder(builder: (BuildContext context) {
        if (!widget.controller.hasTextureId) {
          return const SizedBox();
        }
        final Widget texture = Texture(textureId: widget.controller.textureId);
        _videoHeight = widget.controller.videoHeight;
        _videoWidth = widget.controller.videoWidth;
        return LayoutBuilder(
          builder: (context, constraints) {
            final APlayerFit fit = widget.controller.fit;
            final APlayerMirrorMode mirrorMode = widget.controller.mirrorMode;
            final Size childSize = _getTxSize(constraints, fit);
            final Offset offset = _getTxOffset(constraints, childSize, fit);
            final Rect pos = Rect.fromLTWH(
                offset.dx, offset.dy, childSize.width, childSize.height);

            return Stack(
              children: [
                Positioned.fromRect(
                  rect: pos,
                  child: Transform(
                    transform: _getMatrix4(mirrorMode),
                    alignment: Alignment.center,
                    child: texture,
                  ),
                ),
              ],
            );
          },
        );
      }),
    );
  }
  Matrix4 _getMatrix4(APlayerMirrorMode mirrorMode) {
    Matrix4 matrix4 = Matrix4.identity();
    switch (mirrorMode) {
      case APlayerMirrorMode.none:
        return matrix4;
      case APlayerMirrorMode.horizontal:
        return matrix4..rotateY(pi);
      case APlayerMirrorMode.vertical:
        return matrix4..rotateX(pi);
    }
  }
  Size _getTxSize(BoxConstraints constraints, APlayerFit fit) {
    Size childSize = _applyAspectRatio(
        constraints, _getAspectRatio(constraints, fit.aspectRatio));
    double sizeFactor = fit.sizeFactor;
    if (-1.0 < sizeFactor && sizeFactor < -0.0) {
      sizeFactor = max(constraints.maxWidth / childSize.width,
          constraints.maxHeight / childSize.height);
    } else if (-2.0 < sizeFactor && sizeFactor < -1.0) {
      sizeFactor = constraints.maxWidth / childSize.width;
    } else if (-3.0 < sizeFactor && sizeFactor < -2.0) {
      sizeFactor = constraints.maxHeight / childSize.height;
    } else if (sizeFactor < 0) {
      sizeFactor = 1.0;
    }
    childSize = childSize * sizeFactor;
    return childSize;
  }

  Size _applyAspectRatio(BoxConstraints constraints, double aspectRatio) {
    assert(constraints.hasBoundedHeight && constraints.hasBoundedWidth);

    constraints = constraints.loosen();

    double width = constraints.maxWidth;
    double height = width;

    if (width.isFinite) {
      height = width / aspectRatio;
    } else {
      height = constraints.maxHeight;
      width = height * aspectRatio;
    }

    if (width > constraints.maxWidth) {
      width = constraints.maxWidth;
      height = width / aspectRatio;
    }

    if (height > constraints.maxHeight) {
      height = constraints.maxHeight;
      width = height * aspectRatio;
    }

    if (width < constraints.minWidth) {
      width = constraints.minWidth;
      height = width / aspectRatio;
    }

    if (height < constraints.minHeight) {
      height = constraints.minHeight;
      width = height * aspectRatio;
    }

    return constraints.constrain(Size(width, height));
  }

  double _getAspectRatio(BoxConstraints constraints, double ar) {
    if (ar < 0) {
      ar = _videoWidth / _videoHeight;
    } else if (ar.isInfinite) {
      ar = constraints.maxWidth / constraints.maxHeight;
    }
    return ar;
  }

  Offset _getTxOffset(
      BoxConstraints constraints, Size childSize, APlayerFit fit) {
    final Alignment resolvedAlignment = fit.alignment;
    final Offset diff = (constraints.biggest - childSize) as Offset;
    return resolvedAlignment.alongOffset(diff);
  }
}
