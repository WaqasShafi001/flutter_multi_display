import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_multi_display/flutter_multi_display_platform_interface.dart';
import 'package:flutter_multi_display/flutter_multi_display_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterMultiDisplayPlatform
    with MockPlatformInterfaceMixin
    implements FlutterMultiDisplayPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<void> updateState(String type, Map<String, dynamic>? state) =>
      Future.value();

  @override
  Future<Map<String, dynamic>?> getState(String type) => Future.value({});

  @override
  Future<Map<String, dynamic>> getAllState() => Future.value({});

  @override
  Future<void> clearState(String type) => Future.value();

  @override
  Future<void> setupMultiDisplay(List<String> entrypoints) => Future.value();
}

void main() {
  final FlutterMultiDisplayPlatform initialPlatform =
      FlutterMultiDisplayPlatform.instance;

  test('$MethodChannelFlutterMultiDisplay is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterMultiDisplay>());
  });

  test('getPlatformVersion', () async {
    MockFlutterMultiDisplayPlatform fakePlatform =
        MockFlutterMultiDisplayPlatform();
    FlutterMultiDisplayPlatform.instance = fakePlatform;

    expect(await fakePlatform.getPlatformVersion(), '42');
  });

  // Add a simple test for updateState (mocked)
  test('updateState', () async {
    MockFlutterMultiDisplayPlatform fakePlatform =
        MockFlutterMultiDisplayPlatform();
    FlutterMultiDisplayPlatform.instance = fakePlatform;

    await fakePlatform.updateState('testType', {'key': 'value'});
    // No assertion needed for void, but you can add verifies if using mockito
  });
}
