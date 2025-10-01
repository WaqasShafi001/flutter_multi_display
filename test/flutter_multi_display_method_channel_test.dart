import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_multi_display/flutter_multi_display_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelFlutterMultiDisplay platform = MethodChannelFlutterMultiDisplay();
  const MethodChannel channel = MethodChannel('flutter_multi_display/shared_state');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        if (methodCall.method == 'getPlatformVersion') {
          return '42';
        } else if (methodCall.method == 'getAllState') {
          return {};
        } else if (methodCall.method == 'getState') {
          return {};
        }
        return null; // For void methods
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });

  test('getAllState', () async {
    expect(await platform.getAllState(), {});
  });
}