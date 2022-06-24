import 'package:flutter_test/flutter_test.dart';
import 'package:a_player/a_player.dart';
import 'package:a_player/a_player_platform_interface.dart';
import 'package:a_player/a_player_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAPlayerPlatform 
    with MockPlatformInterfaceMixin
    implements APlayerPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final APlayerPlatform initialPlatform = APlayerPlatform.instance;

  test('$MethodChannelAPlayer is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelAPlayer>());
  });

  test('getPlatformVersion', () async {
    APlayer aPlayerPlugin = APlayer();
    MockAPlayerPlatform fakePlatform = MockAPlayerPlatform();
    APlayerPlatform.instance = fakePlatform;
  
    expect(await aPlayerPlugin.getPlatformVersion(), '42');
  });
}
