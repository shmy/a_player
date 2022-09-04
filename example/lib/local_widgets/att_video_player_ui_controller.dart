import 'package:a_player_example/local_widgets/att_video_player_constant.dart';
import 'package:get/get.dart';

class AttVideoPlayerUIController {
  final Rx<AttVideoPlayerStatus> status =
  Rx<AttVideoPlayerStatus>(AttVideoPlayerStatus.idle);
  final RxString reson = ''.obs;
  final RxInt duration = 0.obs;
  final RxInt position = 0.obs;
  final RxDouble playSpeed = (0.0).obs;
}