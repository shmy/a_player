import 'package:a_player_example/local_widgets/att_video_player_constant.dart';
import 'package:get/get.dart';

class AttVideoPlayerUIController {
  final Rx<AttVideoPlayerStatus> status =
      Rx<AttVideoPlayerStatus>(AttVideoPlayerStatus.idle);
  final RxString errorDescription = ''.obs;
  final RxDouble playSpeed = (1.0).obs;
  final Rx<Duration> duration = Rx<Duration>(Duration.zero);
  final Rx<Duration> position = Rx<Duration>(Duration.zero);
  final Rx<Duration> buffered = Rx<Duration>(Duration.zero);
  final RxBool isBuffering = false.obs;
  final RxInt bufferingPercentage = 0.obs;
  final RxInt bufferingSpeed = 0.obs;
  final RxInt height = 0.obs;
  final RxInt width = 0.obs;
  final RxBool isTryItToEnd = false.obs;
  final RxBool isCompletion = false.obs;
  void resetState() {
    errorDescription.value = '';
    playSpeed.value = 1.0;
    duration.value = Duration.zero;
    position.value = Duration.zero;
    buffered.value = Duration.zero;
    isBuffering.value = false;
    bufferingPercentage.value = 0;
    bufferingSpeed.value = 0;
    height.value = 0;
    width.value = 0;
    isTryItToEnd.value = false;
    isCompletion.value = false;
  }
}
