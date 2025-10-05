import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_multi_display_platform_interface.dart';

/// An implementation of [FlutterMultiDisplayPlatform] that uses method channels.
///
/// This class provides the Android implementation of the flutter_multi_display
/// plugin using Flutter's method channel mechanism for communication between
/// Dart and native Kotlin/Java code.
///
/// ## Method Channel Communication
///
/// This implementation communicates with the native Android plugin via the
/// `flutter_multi_display/shared_state` method channel. It sends method calls
/// to native code and receives responses asynchronously.
///
/// ## Supported Methods
///
/// The following methods are invoked on the native side:
/// - `getPlatformVersion`: Gets the Android version
/// - `updateState`: Updates shared state
/// - `getState`: Retrieves state for a type
/// - `getAllState`: Retrieves all states
/// - `clearState`: Clears state for a type
/// - `setupMultiDisplay`: Initializes multi-display
///
/// ## Testing
///
/// The [methodChannel] field is exposed with [@visibleForTesting] to allow
/// unit tests to mock the method channel behavior.
///
/// Example test:
/// ```dart
/// test('getPlatformVersion returns correct value', () async {
///   const channel = MethodChannel('flutter_multi_display/shared_state');
///   TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
///       .setMockMethodCallHandler(channel, (call) async {
///     if (call.method == 'getPlatformVersion') {
///       return 'Android 11';
///     }
///     return null;
///   });
///
///   final platform = MethodChannelFlutterMultiDisplay();
///   expect(await platform.getPlatformVersion(), 'Android 11');
/// });
/// ```
class MethodChannelFlutterMultiDisplay extends FlutterMultiDisplayPlatform {
  /// The method channel used to interact with the native platform.
  ///
  /// This channel is named `flutter_multi_display/shared_state` and must
  /// match the channel name used in the native Android plugin code.
  ///
  /// Exposed for testing purposes with [@visibleForTesting].
  @visibleForTesting
  final methodChannel = const MethodChannel(
    'flutter_multi_display/shared_state',
  ); // Match your channel

  /// Gets the platform version from the native Android platform.
  ///
  /// Returns a [Future] that completes with the platform version as a [String],
  /// or null if the platform version could not be determined.
  ///
  /// This method is typically used for testing platform integration.
  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }

  /// Updates the shared state for a specific type.
  ///
  /// Parameters:
  /// - [type]: The identifier for the state type to update
  /// - [state]: A map containing the new state data. Can be null to clear the state.
  ///
  /// The state is stored on the native platform and can be retrieved later
  /// using [getState] or [getAllState].
  @override
  Future<void> updateState(String type, Map<String, dynamic>? state) async {
    await methodChannel.invokeMethod('updateState', {
      'type': type,
      'state': state,
    });
  }

  /// Retrieves the shared state for a specific type.
  ///
  /// Parameters:
  /// - [type]: The identifier for the state type to retrieve
  ///
  /// Returns a [Future] that completes with the state data as a [Map],
  /// or null if no state exists for the given type.
  @override
  Future<Map<String, dynamic>?> getState(String type) async {
    final result = await methodChannel.invokeMapMethod<String, dynamic>(
      'getState',
      {'type': type},
    );
    return result;
  }

  /// Retrieves all shared states across all types.
  ///
  /// Returns a [Future] that completes with a [Map] containing all stored states.
  /// If no states exist, returns an empty map.
  @override
  Future<Map<String, dynamic>> getAllState() async {
    final result =
        await methodChannel.invokeMapMethod<String, dynamic>('getAllState') ??
        {};
    return result;
  }

  /// Clears the shared state for a specific type.
  ///
  /// Parameters:
  /// - [type]: The identifier for the state type to clear
  ///
  /// This operation cannot be undone. After clearing, [getState] will return null
  /// for the specified type until new state is set.
  @override
  Future<void> clearState(String type) async {
    await methodChannel.invokeMethod('clearState', {'type': type});
  }

  /// Initializes the multi-display functionality with the specified configuration.
  ///
  /// Parameters:
  /// - [entrypoints]: A list of entry point identifiers for the displays
  /// - [portBased]: Whether to use port-based communication (default: false)
  ///
  /// This method must be called before using any multi-display features.
  /// The [entrypoints] parameter defines the entry points that will be available
  /// for displaying content on secondary screens.
  @override
  Future<void> setupMultiDisplay(
    List<String> entrypoints, {
    bool portBased = false,
  }) async {
    await methodChannel.invokeMethod('setupMultiDisplay', {
      'entrypoints': entrypoints,
      'portBased': portBased,
    });
  }
}
