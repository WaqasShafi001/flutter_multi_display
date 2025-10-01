library;

export 'shared_state_manager.dart'; // Export shared state APIs

import 'flutter_multi_display_platform_interface.dart';

/// Facade for interacting with the flutter_multi_display plugin.
class FlutterMultiDisplay {
  /// Sets up multi-display with the given Dart entrypoints.
  Future<void> setupMultiDisplay(List<String> entrypoints) {
    return FlutterMultiDisplayPlatform.instance.setupMultiDisplay(entrypoints);
  }
  
  /// Updates the shared state for a given type.
  Future<void> updateState(String type, Map<String, dynamic>? state) {
    return FlutterMultiDisplayPlatform.instance.updateState(type, state);
  }

  /// Retrieves the shared state for a given type.
  Future<Map<String, dynamic>?> getState(String type) {
    return FlutterMultiDisplayPlatform.instance.getState(type);
  }

  /// Retrieves all shared states.
  Future<Map<String, dynamic>> getAllState() {
    return FlutterMultiDisplayPlatform.instance.getAllState();
  }

  /// Clears the shared state for a given type.
  Future<void> clearState(String type) {
    return FlutterMultiDisplayPlatform.instance.clearState(type);
  }

  /// Gets the platform version (for compatibility with default plugin setup).
  Future<String?> getPlatformVersion() {
    return FlutterMultiDisplayPlatform.instance.getPlatformVersion();
  }
}