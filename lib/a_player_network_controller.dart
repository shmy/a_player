import 'package:a_player/a_player_controller.dart';

class APlayerNetworkController extends APlayerControllerInterface {
  @override
  Future<void> setDataSouce(String source,
      {List<String> headers = const [], bool isAutoPlay = true}) async {
    await methodChannel?.invokeMethod('setNetworkDataSource', source);
    prepare(isAutoPlay: isAutoPlay);
  }
}
