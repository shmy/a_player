import 'package:a_player/a_player_controller.dart';
import 'package:flutter/material.dart';

class APlayerPip extends StatefulWidget {
  final APlayerController controller;
  const APlayerPip({Key? key, required this.controller}) : super(key: key);

  @override
  State<APlayerPip> createState() => _APlayerPipState();
}

class _APlayerPipState extends State<APlayerPip> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      widget.controller.play();
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: Align(
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Center(
            child: Texture(
              textureId: widget.controller.textureId,
            ),
          ),
        ),
      ),
    );Container();
  }
}
