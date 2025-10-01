import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_multi_display_method_channel.dart';

abstract class FlutterMultiDisplayPlatform extends PlatformInterface {
  /// Constructs a FlutterMultiDisplayPlatform.
  FlutterMultiDisplayPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterMultiDisplayPlatform _instance = MethodChannelFlutterMultiDisplay();

  /// The default instance of [FlutterMultiDisplayPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterMultiDisplay].
  static FlutterMultiDisplayPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterMultiDisplayPlatform] when
  /// they register themselves.
  static set instance(FlutterMultiDisplayPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
