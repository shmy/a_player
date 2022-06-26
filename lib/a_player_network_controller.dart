import 'package:a_player/a_player_controller.dart';

import 'a_player_constant.dart';

class APlayerNetworkController extends APlayerControllerInterface {
  @override
  Future<void> setDataSouce(String source,
      {List<APlayerConfigHeader> headers = const [], bool isAutoPlay = true}) async {
    String? userAgent;
    String? referer;
    List<String> customHeaders = [];
    for (APlayerConfigHeader header in headers) {
      final String key = header.key.toUpperCase();
      if (key == "USER-AGENT") {
        userAgent = header.value;
      } else if (key == "REFERER") {
        referer = header.value;
      } else {
        customHeaders.add('${header.key}:${header.value}');
      }
    }
    await methodChannel?.invokeMethod('setNetworkDataSource', {
      "url": source,
      "userAgent": userAgent,
      "referer": referer,
      "customHeaders": customHeaders
    });
    prepare(isAutoPlay: isAutoPlay);
  }
}
