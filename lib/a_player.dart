import 'package:a_player/a_player_value.dart';
import 'package:flutter/material.dart';
import 'a_player_controller.dart';

class APlayer extends StatefulWidget {
  final APlayerControllerInterface controller;

  const APlayer({Key? key, required this.controller}) : super(key: key);

  @override
  State<APlayer> createState() => _APlayerState();
}

class _APlayerState extends State<APlayer> {
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
        return Center(
          child: AspectRatio(
            aspectRatio: _aspectRatio,
            child: Texture(textureId: widget.controller.textureId),
          ),
        );
      }),
    );
  }

  double get _aspectRatio {
    switch (widget.controller.fit) {
      case APlayerFit.fitDefault:
        return widget.controller.value.aspectRatio;
      case APlayerFit.fit4x3:
        return APlayerRatio.ratio4x3;
      case APlayerFit.fit1x1:
        return APlayerRatio.ratio1x1;
      // case APlayerFit.fit_stretch:
      //   return APlayerRatio.ratio1_1;
      default:
        return APlayerRatio.ratio16x9;
    }
  }
}
