import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:a_player/a_player_method_channel.dart';

void main() {
  MethodChannelAPlayer platform = MethodChannelAPlayer();
  const MethodChannel channel = MethodChannel('a_player');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
