import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_multi_display_platform_interface.dart';

/// An implementation of [FlutterMultiDisplayPlatform] that uses method channels.
class MethodChannelFlutterMultiDisplay extends FlutterMultiDisplayPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel(
    'flutter_multi_display/shared_state',
  ); // Match your channel

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }

  // Implement shared state methods
  @override
  Future<void> updateState(String type, Map<String, dynamic>? state) async {
    await methodChannel.invokeMethod('updateState', {
      'type': type,
      'state': state,
    });
  }

  @override
  Future<Map<String, dynamic>?> getState(String type) async {
    final result = await methodChannel.invokeMapMethod<String, dynamic>(
      'getState',
      {'type': type},
    );
    return result;
  }

  @override
  Future<Map<String, dynamic>> getAllState() async {
    final result =
        await methodChannel.invokeMapMethod<String, dynamic>('getAllState') ??
        {};
    return result;
  }

  @override
  Future<void> clearState(String type) async {
    await methodChannel.invokeMethod('clearState', {'type': type});
  }

  @override
  Future<void> setupMultiDisplay(List<String> entrypoints) async {
    await methodChannel.invokeMethod('setupMultiDisplay', {
      'entrypoints': entrypoints,
    });
  }
}
