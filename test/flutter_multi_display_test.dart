import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_multi_display/flutter_multi_display.dart';
import 'package:flutter_multi_display/flutter_multi_display_platform_interface.dart';
import 'package:flutter_multi_display/flutter_multi_display_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterMultiDisplayPlatform
    with MockPlatformInterfaceMixin
    implements FlutterMultiDisplayPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterMultiDisplayPlatform initialPlatform = FlutterMultiDisplayPlatform.instance;

  test('$MethodChannelFlutterMultiDisplay is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterMultiDisplay>());
  });

  test('getPlatformVersion', () async {
    FlutterMultiDisplay flutterMultiDisplayPlugin = FlutterMultiDisplay();
    MockFlutterMultiDisplayPlatform fakePlatform = MockFlutterMultiDisplayPlatform();
    FlutterMultiDisplayPlatform.instance = fakePlatform;

    expect(await flutterMultiDisplayPlugin.getPlatformVersion(), '42');
  });
}
