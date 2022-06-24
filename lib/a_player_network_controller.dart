import 'package:a_player/a_player_controller.dart';

class APlayerNetworkController extends APlayerControllerInterface {
  String url;
  List<String> headers;
  bool isAutoPlay;

  APlayerNetworkController(this.url,
      {this.headers = const [], this.isAutoPlay = true});

  Future<void> setDataSouce(String url,
      {List<String> headers = const [], bool isAutoPlay = true}) async {
    this.url = url;
    this.headers = headers;
    this.isAutoPlay = true;
    await stop();
    seekTo(0);
    await _setNetworkDataSource(url);
  }

  @override
  Future<void> initialize() async {
    await super.initialize();
    await _setNetworkDataSource(url);
  }

  Future<void> _setNetworkDataSource(String url) async {
    await methodChannel?.invokeMethod('setNetworkDataSource', url);
    await prepare(isAutoPlay: isAutoPlay);
  }
}
