import 'package:a_player/a_player_controller.dart';
import 'package:a_player/a_player_value.dart';
import 'package:get/get.dart';

class AttVideoPlayerController {
  final APlayerController aPlayerController = APlayerController();
  final RxBool initializing = true.obs;
  bool _visible = true;
  AttVideoPlayerController() {
    _initialize();
  }
  Future<void> _initialize() async {
    aPlayerController.stream.listen((event) {
      initializing.value = !event.isInitialized;
      if (!event.isPlaying && event.isReadyToPlay && _visible) {
        aPlayerController.play();
      }
    });
    await aPlayerController.initialize();
    await aPlayerController.setKernel(APlayerKernel.ijk);
    await aPlayerController.setDataSouce('https://vfx.mtime.cn/Video/2019/02/04/mp4/190204084208765161.mp4');
  }
  void setVisible(bool visible) {
    _visible = visible;
  }
  void dispose() {
    aPlayerController.dispose();
  }
}