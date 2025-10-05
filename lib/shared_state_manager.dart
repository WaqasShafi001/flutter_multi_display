import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Callback function type for state change listeners.
///
/// Called whenever a shared state is updated or cleared.
typedef OnSharedStateChangeListener = void Function(Map<String, dynamic>?);

const _sharedStateChannelName = 'flutter_multi_display/shared_state';

/// Abstract base class for creating type-safe shared state objects.
///
/// [SharedState] provides a reactive way to share state across multiple
/// Flutter engines running on different displays. It extends [ChangeNotifier]
/// and implements [ValueListenable] to integrate seamlessly with Flutter's
/// reactive framework.
///
/// Key features:
/// - Type-safe state management with generic type [T]
/// - Automatic synchronization across all displays
/// - Integration with Flutter's [ChangeNotifier] pattern
/// - Caching for immediate access to current state
/// - JSON serialization/deserialization support
///
/// Example usage:
/// ```dart
/// class UserProfileState extends SharedState<UserProfile> {
///   @override
///   UserProfile fromJson(Map<String, dynamic> json) {
///     return UserProfile.fromJson(json);
///   }
///
///   @override
///   Map<String, dynamic>? toJson(UserProfile? data) {
///     return data?.toJson();
///   }
/// }
///
/// // In your widget
/// final profileState = UserProfileState();
///
/// // Update state (will sync across all displays)
/// profileState.sync(UserProfile(name: 'John', age: 30));
///
/// // Listen to changes
/// profileState.addListener(() {
///   print('Profile updated: ${profileState.state}');
/// });
///
abstract class SharedState<T>
    with ChangeNotifier
    implements ValueListenable<T?> {
  T? _state;
  final String _type;

  /// The current state value.
  ///
  /// Returns null if no state has been set.
  T? get state => _state;

  /// Implements [ValueListenable.value] to return the current state.
  @override
  T? get value => _state;

  /// Creates a new [SharedState] instance.
  ///
  /// The state type identifier is automatically derived from the generic
  /// type [T] using [T.toString()].
  ///
  /// Upon creation:
  /// 1. Registers a listener with [SharedStateManager]
  /// 2. Loads cached state if available
  /// 3. Syncs state from native side asynchronously
  SharedState() : _type = T.toString() {
    // Automatically register listener with SharedStateManager
    SharedStateManager.instance.addStateChangeListener(_type, _onStateChange);

    // Initialize with cached state if available
    final cachedState = SharedStateManager.instance.getCachedState(_type);
    if (cachedState != null) {
      _state = fromJson(cachedState);
      debugPrint('[SharedState] Initial cached state for $_type: $_state');
    } else {
      // Sync state asynchronously
      _syncState();
    }
  }

  /// Updates the shared state and notifies all displays.
  ///
  /// This method:
  /// 1. Updates the local state
  /// 2. Notifies local listeners via [notifyListeners]
  /// 3. Propagates the change to all other Flutter engines
  ///
  /// If the new state equals the current state, no update occurs.
  ///
  /// @param state The new state value, or null to clear
  void sync(T? state) {
    if (_state == state) return; // Avoid unnecessary updates
    _state = state;
    debugPrint('[SharedState] Syncing state for $_type: $state');
    notifyListeners();
    SharedStateManager.instance.updateState(_type, toJson(state));
  }

  /// Clears the shared state and notifies all displays.
  ///
  /// Sets the state to null and propagates this change to all other
  /// Flutter engines.
  void clear() {
    _state = null;
    debugPrint('[SharedState] Clearing state for $_type');
    notifyListeners();
    SharedStateManager.instance.clearState(_type);
  }

  /// Synchronizes state from the native side.
  ///
  /// This is called during initialization to ensure the Flutter side
  /// has the latest state from the native SharedStateManager.
  Future<void> _syncState() async {
    final json = await SharedStateManager.instance.getState(_type);
    if (json != null) {
      _onStateChange(json);
    }
    debugPrint('[SharedState] Initial sync completed for $_type: $_state');
  }

  /// Internal callback invoked when state changes from another engine.
  ///
  /// This method:
  /// 1. Deserializes the JSON state
  /// 2. Updates the local state
  /// 3. Notifies local listeners
  ///
  /// @param newState The new state as a JSON map, or null
  void _onStateChange(Map<String, dynamic>? newState) {
    debugPrint('[SharedState] Received state change for $_type: $newState');
    try {
      final newValue = newState == null ? null : fromJson(newState);
      if (_isSameState(newValue)) return;
      _state = newValue;
      debugPrint('[SharedState] Updated state for $_type: $_state');
      notifyListeners();
    } catch (e) {
      debugPrint(
        '[SharedState] Failed to parse for $_type from: $newState, $e',
      );
    }
  }

  /// Checks if the new state equals the current state.
  ///
  /// @param newState The state to compare
  /// @return true if states are equal, false otherwise
  bool _isSameState(T? newState) {
    if (newState == null && _state == null) return true;
    if (newState == null || _state == null) return false;
    return newState == _state;
  }

  /// Disposes the shared state and unregisters listeners.
  ///
  /// Call this when the state object is no longer needed to prevent
  /// memory leaks.
  @override
  void dispose() {
    debugPrint('[SharedState] Disposing $_type');
    SharedStateManager.instance.removeStateChangeListener(
      _type,
      _onStateChange,
    );
    super.dispose();
  }

  /// Converts a JSON map to the state object of type [T].
  ///
  /// Implement this method to deserialize your state from JSON.
  ///
  /// Example:
  /// ```dart
  /// @override
  /// UserProfile fromJson(Map<String, dynamic> json) {
  ///   return UserProfile.fromJson(json);
  /// }
  /// ```
  ///
  /// @param json The JSON map to deserialize
  /// @return The deserialized state object
  T fromJson(Map<String, dynamic> json);

  /// Converts the state object to a JSON map.
  ///
  /// Implement this method to serialize your state to JSON.
  ///
  /// Example:
  /// ```dart
  /// @override
  /// Map<String, dynamic>? toJson(UserProfile? data) {
  ///   return data?.toJson();
  /// }
  /// ```
  ///
  /// @param data The state object to serialize, or null
  /// @return The serialized JSON map, or null if data is null
  Map<String, dynamic>? toJson(T? data);
}

/// Singleton manager for coordinating shared state across multiple Flutter engines.
///
/// [SharedStateManager] acts as a bridge between Flutter and the native
/// Android [SharedStateManager], providing a unified API for state management
/// across all displays in a multi-display application.
///
/// Features:
/// - Singleton pattern for global access
/// - Method channel communication with native code
/// - Local state caching for improved performance
/// - Automatic state synchronization across all engines
/// - Type-safe listener registration
///
/// This manager is automatically initialized when accessed and handles:
/// - Bidirectional state synchronization
/// - Listener management and notification
/// - State caching to reduce native calls
/// - Initial state loading on startup
///
/// Example usage:
/// ```dart
/// // Get the singleton instance
/// final manager = SharedStateManager.instance;
///
/// // Update state
/// await manager.updateState('cartTotal', {'amount': 99.99, 'currency': 'USD'});
///
/// // Get state
/// final cartData = await manager.getState('cartTotal');
///
/// // Listen to changes
/// manager.addStateChangeListener('cartTotal', (data) {
///   print('Cart updated: $data');
/// });
/// ```
class SharedStateManager {
  static SharedStateManager? _instance;

  /// Returns the singleton instance of [SharedStateManager].
  ///
  /// Creates the instance on first access.
  static SharedStateManager get instance {
    _instance ??= SharedStateManager._();
    return _instance!;
  }

  /// Map of state type to registered listeners.
  final Map<String, Set<OnSharedStateChangeListener>> _listeners = {};

  /// Method channel for communication with native Android code.
  late final MethodChannel methodChannel;

  /// Local cache of shared state for quick access.
  Map<String, Map<String, dynamic>?> _cachedSharedState = {};

  /// Flag indicating whether initial state sync has completed.
  bool _hasSyncData = false;

  /// Private constructor for singleton pattern.
  ///
  /// Initializes the method channel and sets up the method call handler
  /// to receive state change notifications from the native side.
  SharedStateManager._() {
    methodChannel = const MethodChannel(_sharedStateChannelName);
    methodChannel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onStateChanged':
          if (!_hasSyncData) {
            await _syncSharedState();
          }
          final type = call.arguments['type'] as String;
          final rawData = call.arguments['data'];
          final newState = rawData != null
              ? Map<String, dynamic>.from(rawData)
              : null;
          // Only notify if the state has changed
          if (_cachedSharedState[type] != newState) {
            _cachedSharedState[type] = newState;
            debugPrint(
              '[SharedStateManager] Caching state for $type: $newState',
            );
            _notifyListeners(type, newState);
          }
          break;
        default:
          debugPrint("SharedStateManager: Unknown method ${call.method}");
      }
      return null;
    });
  }

  /// Synchronizes all shared state from the native side.
  ///
  /// This is called once during initialization to populate the local cache
  /// with all existing state data from the native [SharedStateManager].
  ///
  /// Sets [_hasSyncData] to true once completed to prevent redundant syncs.
  Future _syncSharedState() async {
    final res = await methodChannel.invokeMapMethod<String, dynamic>(
      'getAllState',
    );
    _cachedSharedState =
        res?.map(
          (key, value) => MapEntry(
            key,
            value == null ? null : Map<String, dynamic>.from(value),
          ),
        ) ??
        {};
    _hasSyncData = true;
    debugPrint(
      '[SharedStateManager] Initial sync completed: $_cachedSharedState',
    );
  }

  /// Retrieves the shared state for a specific type.
  ///
  /// If state hasn't been synced yet, performs an initial sync.
  /// Returns the cached state if available.
  ///
  /// @param type The state type identifier (e.g., 'userProfile', 'cartItems')
  /// @return A Future that resolves to the state data, or null if not found
  Future<Map<String, dynamic>?> getState(String type) async {
    if (!_hasSyncData) {
      await _syncSharedState();
    }
    return _cachedSharedState[type];
  }

  /// Gets the cached state for a specific type without triggering a sync.
  ///
  /// Use this for immediate access to state that's already been loaded.
  /// Returns null if the state hasn't been cached yet.
  ///
  /// @param type The state type identifier
  /// @return The cached state data, or null if not cached
  Map<String, dynamic>? getCachedState(String type) {
    return _cachedSharedState[type];
  }

  /// Updates the shared state for a specific type.
  ///
  /// This method:
  /// 1. Ensures state is synced
  /// 2. Updates the local cache
  /// 3. Notifies local listeners
  /// 4. Sends the update to the native side
  /// 5. Native side propagates to all other Flutter engines
  ///
  /// If the state hasn't changed, no update is performed.
  ///
  /// @param type The state type identifier
  /// @param data The state data as a JSON-serializable map, or null to clear
  Future<void> updateState(String type, Map<String, dynamic>? data) async {
    try {
      if (!_hasSyncData) {
        await _syncSharedState();
      }
      if (_cachedSharedState[type] != data) {
        _cachedSharedState[type] = data;
        debugPrint('[SharedStateManager] Updating state for $type: $data');
        _notifyListeners(type, data);
        await methodChannel.invokeMethod('updateState', {
          'type': type,
          'state': data,
        });
      }
    } on PlatformException catch (e) {
      debugPrint('Error updating shared state: ${e.message}');
    }
  }

  /// Clears the shared state for a specific type.
  ///
  /// This method:
  /// 1. Ensures state is synced
  /// 2. Sets the cached state to null
  /// 3. Notifies local listeners
  /// 4. Sends the clear command to the native side
  ///
  /// @param type The state type identifier to clear
  Future<void> clearState(String type) async {
    try {
      if (!_hasSyncData) {
        await _syncSharedState();
      }
      if (_cachedSharedState[type] != null) {
        _cachedSharedState[type] = null;
        debugPrint('[SharedStateManager] Clearing state for $type');
        _notifyListeners(type, null);
        await methodChannel.invokeMethod('clearState', {'type': type});
      }
    } on PlatformException catch (e) {
      debugPrint('Error clearing shared state: ${e.message}');
    }
  }

  /// Registers a listener for state changes of a specific type.
  ///
  /// The listener will be called whenever the state for the specified type
  /// is updated or cleared. Multiple listeners can be registered for the
  /// same type.
  ///
  /// Example:
  /// ```dart
  /// SharedStateManager.instance.addStateChangeListener('userProfile', (data) {
  ///   if (data != null) {
  ///     print('User profile updated: ${data['name']}');
  ///   } else {
  ///     print('User profile cleared');
  ///   }
  /// });
  /// ```
  ///
  /// @param type The state type identifier to listen to
  /// @param listener The callback function to invoke on state changes
  void addStateChangeListener(
    String type,
    OnSharedStateChangeListener listener,
  ) {
    _listeners.putIfAbsent(type, () => {});
    _listeners[type]!.add(listener);
    debugPrint(
      '[SharedStateManager] Added listener for type=$type, total=${_listeners[type]!.length}',
    );
  }

  /// Unregisters a previously registered listener.
  ///
  /// @param type The state type identifier
  /// @param listener The callback function to remove
  void removeStateChangeListener(
    String type,
    OnSharedStateChangeListener listener,
  ) {
    final stateListeners = _listeners[type];
    if (stateListeners == null || stateListeners.isEmpty) return;
    stateListeners.remove(listener);
    debugPrint(
      '[SharedStateManager] Removed listener for type=$type, total=${_listeners[type]!.length}',
    );
  }

  /// Notifies all registered listeners for a specific state type.
  ///
  /// Creates a copy of the listener list before iteration to prevent
  /// concurrent modification issues.
  ///
  /// @param type The state type that changed
  /// @param data The new state data, or null if cleared
  void _notifyListeners(String type, Map<String, dynamic>? data) {
    debugPrint(
      '[SharedStateManager] Notifying listeners for type=$type, data=$data',
    );
    final listeners = _listeners[type];
    if (listeners != null) {
      for (final listener in listeners.toList()) {
        debugPrint('[SharedStateManager] Calling listener for type=$type');
        listener(data);
      }
    } else {
      debugPrint('[SharedStateManager] No listeners for type=$type');
    }
  }
}
