import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_multi_display_platform_interface.dart';

/// An implementation of [FlutterMultiDisplayPlatform] that uses method channels.
class MethodChannelFlutterMultiDisplay extends FlutterMultiDisplayPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_multi_display');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
