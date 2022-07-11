import 'package:a_player/a_player.dart';
import 'package:a_player/a_player_controller.dart';
import 'package:a_player_example/example/video_player_controller.dart';
import 'package:flutter/material.dart';
import 'package:rpx/rpx.dart';

class PlayerAdView extends StatefulWidget {
  final VideoAdItem adItem;
  final VoidCallback? onDone;

  const PlayerAdView({Key? key, required this.adItem, this.onDone}) : super(key: key);

  @override
  State<PlayerAdView> createState() => _PlayerAdViewState();
}

class _PlayerAdViewState extends State<PlayerAdView> {
  VideoAdItem get adItem => widget.adItem;
  APlayerController? aPlayerController;
  int duration = 0;
  int position = 0;

  int get remaining => duration - position;
  bool get canSkip => position > adItem.minTime - 1;

  @override
  void initState() {
    if (adItem.type == VideoPlayerAdType.video) {
      aPlayerController = APlayerController()
        ..initialize().then((_) {
          aPlayerController!
            ..setDataSouce(adItem.source)
            ..play();
        })
        ..stream.listen((event) {
          setState(() {
            duration = event.duration.inSeconds;
            position = event.position.inSeconds + 1;
          });
          if (event.isCompletion) {
            widget.onDone?.call();
          }
        });
    }
    super.initState();
  }

  @override
  void dispose() {
    aPlayerController?.dispose();
    aPlayerController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          Container(
            color: Colors.black,
            child: Builder(builder: (BuildContext context) {
              if (adItem.type == VideoPlayerAdType.video) {
                return _buildVideo();
              } else if (adItem.type == VideoPlayerAdType.image) {
                return _buildImage();
              }
              return const SizedBox();
            }),
          ),
          if (duration != 0)
          Positioned(
            top: 10.rpx,
            right: 10.rpx,
            child: DefaultTextStyle(
              style: TextStyle(color: Colors.white, fontSize: 18.rpx, fontWeight: FontWeight.bold,),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('$remaining'),
                  if (canSkip)
                  GestureDetector(onTap: widget.onDone, child: const Text(' | 跳过')),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildVideo() {
    return Center(
        child: APlayer(
      controller: aPlayerController!,
    ));
  }

  Widget _buildImage() {
    return Center(child: Image.network(adItem.source));
  }
}
