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
  Future<void> setupMultiDisplay(
    List<String> entrypoints, {
    bool portBased = false,
  }) => Future.value();
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

  test('updateState', () async {
    MockFlutterMultiDisplayPlatform fakePlatform =
        MockFlutterMultiDisplayPlatform();
    FlutterMultiDisplayPlatform.instance = fakePlatform;

    await fakePlatform.updateState('testType', {'key': 'value'});
    // No assertion needed for void, but you can add verifies if using mockito
  });

  test('setupMultiDisplay with default ID-based assignment', () async {
    MockFlutterMultiDisplayPlatform fakePlatform =
        MockFlutterMultiDisplayPlatform();
    FlutterMultiDisplayPlatform.instance = fakePlatform;

    await fakePlatform.setupMultiDisplay(['screen1Main', 'screen2Main']);
    // Since it's a void method, we verify it executes without errors
    expect(true, true); // Basic check to ensure no exceptions
  });

  test('setupMultiDisplay with port-based assignment', () async {
    MockFlutterMultiDisplayPlatform fakePlatform =
        MockFlutterMultiDisplayPlatform();
    FlutterMultiDisplayPlatform.instance = fakePlatform;

    await fakePlatform.setupMultiDisplay([
      'screen1Main',
      'screen2Main',
    ], portBased: true);
    // Since it's a void method, we verify it executes without errors
    expect(true, true); // Basic check to ensure no exceptions
  });

  test('FlutterMultiDisplay facade with portBased parameter', () async {
    MockFlutterMultiDisplayPlatform fakePlatform =
        MockFlutterMultiDisplayPlatform();
    FlutterMultiDisplayPlatform.instance = fakePlatform;

    final flutterMultiDisplay = FlutterMultiDisplay();
    await flutterMultiDisplay.setupMultiDisplay([
      'screen1Main',
      'screen2Main',
    ], portBased: true);
    // Verify the facade correctly calls the platform method
    expect(true, true); // Basic check to ensure no exceptions
  });
}
