import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_multi_display_method_channel.dart';

/// The platform interface for the flutter_multi_display plugin.
///
/// This abstract class provides the interface that platform-specific implementations
/// must implement. It handles platform-specific functionality for managing multiple
/// displays and shared state across displays in Flutter applications.
///
/// To implement a new platform-specific implementation of `flutter_multi_display`,
/// extend this class with an implementation that performs the platform-specific
/// behavior. Each method throws [UnimplementedError] by default to ensure
/// implementations override all required functionality.
abstract class FlutterMultiDisplayPlatform extends PlatformInterface {
  /// Constructs a FlutterMultiDisplayPlatform.
  ///
  /// Subclasses must call this constructor through their own constructor
  /// to establish themselves as the platform instance.
  FlutterMultiDisplayPlatform() : super(token: _token);

  /// A unique token used to verify that subclasses are implemented correctly.
  static final Object _token = Object();

  /// The default instance of [FlutterMultiDisplayPlatform] to use.
  ///
  /// Platform-specific implementations should override this instance
  /// when registering themselves.
  static FlutterMultiDisplayPlatform _instance =
      MethodChannelFlutterMultiDisplay();

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

  /// Gets the version of the current platform.
  ///
  /// Returns a [Future] that completes with the platform version as a [String],
  /// or null if the platform version could not be determined.
  ///
  /// This method is primarily used for testing platform integration.
  Future<String?> getPlatformVersion() {
    throw UnimplementedError('getPlatformVersion() has not been implemented.');
  }

  /// Updates the shared state for a specific type across displays.
  ///
  /// Parameters:
  /// - [type]: The identifier for the state type to update
  /// - [state]: A map containing the new state data. Can be null to clear the state.
  ///
  /// Platform implementations should ensure this state is accessible
  /// across all active displays.
  Future<void> updateState(String type, Map<String, dynamic>? state) {
    throw UnimplementedError('updateState() has not been implemented.');
  }

  /// Retrieves the shared state for a specific type.
  ///
  /// Parameters:
  /// - [type]: The identifier for the state type to retrieve
  ///
  /// Returns a [Future] that completes with the state data as a [Map],
  /// or null if no state exists for the given type.
  ///
  /// This method should return consistent state across all displays.
  Future<Map<String, dynamic>?> getState(String type) {
    throw UnimplementedError('getState() has not been implemented.');
  }

  /// Retrieves all shared states across all types.
  ///
  /// Returns a [Future] that completes with a [Map] containing all stored states.
  /// If no states exist, returns an empty map.
  ///
  /// This method provides a snapshot of all current shared states in the
  /// multi-display environment.
  Future<Map<String, dynamic>> getAllState() {
    throw UnimplementedError('getAllState() has not been implemented.');
  }

  /// Clears the shared state for a specific type.
  ///
  /// Parameters:
  /// - [type]: The identifier for the state type to clear
  ///
  /// This operation removes the state across all displays and cannot be undone.
  /// After clearing, [getState] will return null for the specified type until
  /// new state is set.
  Future<void> clearState(String type) {
    throw UnimplementedError('clearState() has not been implemented.');
  }

  /// Initializes the multi-display functionality with the specified configuration.
  ///
  /// Parameters:
  /// - [entrypoints]: A list of entry point identifiers for the displays
  /// - [portBased]: Whether to use port-based communication (defaults to false)
  ///
  /// This method must be called before using any multi-display features.
  /// Platform implementations should:
  /// * Initialize necessary platform-specific display management
  /// * Set up communication channels between displays
  /// * Configure entry points for secondary displays
  ///
  /// Throws [UnimplementedError] if the platform implementation does not
  /// override this method.
  Future<void> setupMultiDisplay(
    List<String> entrypoints, {
    bool portBased = false,
  }) {
    throw UnimplementedError('setupMultiDisplay() has not been implemented.');
  }
}
