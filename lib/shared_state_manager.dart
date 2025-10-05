import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

typedef OnSharedStateChangeListener = void Function(Map<String, dynamic>?);

const _sharedStateChannelName = 'flutter_multi_display/shared_state';

abstract class SharedState<T>
    with ChangeNotifier
    implements ValueListenable<T?> {
  T? _state;
  final String _type;

  T? get state => _state;

  @override
  T? get value => _state;

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

  /// Updates the shared state and notifies other engines.
  void sync(T? state) {
    if (_state == state) return; // Avoid unnecessary updates
    _state = state;
    debugPrint('[SharedState] Syncing state for $_type: $state');
    notifyListeners();
    SharedStateManager.instance.updateState(_type, toJson(state));
  }

  /// Clears the shared state and notifies other engines.
  void clear() {
    _state = null;
    debugPrint('[SharedState] Clearing state for $_type');
    notifyListeners();
    SharedStateManager.instance.clearState(_type);
  }

  Future<void> _syncState() async {
    final json = await SharedStateManager.instance.getState(_type);
    if (json != null) {
      _onStateChange(json);
    }
    debugPrint('[SharedState] Initial sync completed for $_type: $_state');
  }

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

  bool _isSameState(T? newState) {
    if (newState == null && _state == null) return true;
    if (newState == null || _state == null) return false;
    return newState == _state;
  }

  @override
  void dispose() {
    debugPrint('[SharedState] Disposing $_type');
    SharedStateManager.instance.removeStateChangeListener(
      _type,
      _onStateChange,
    );
    super.dispose();
  }

  T fromJson(Map<String, dynamic> json);

  Map<String, dynamic>? toJson(T? data);
}

class SharedStateManager {
  static SharedStateManager? _instance;

  static SharedStateManager get instance {
    _instance ??= SharedStateManager._();
    return _instance!;
  }

  final Map<String, Set<OnSharedStateChangeListener>> _listeners = {};
  late final MethodChannel methodChannel;
  Map<String, Map<String, dynamic>?> _cachedSharedState = {};
  bool _hasSyncData = false;

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

  Future<Map<String, dynamic>?> getState(String type) async {
    if (!_hasSyncData) {
      await _syncSharedState();
    }
    return _cachedSharedState[type];
  }

  Map<String, dynamic>? getCachedState(String type) {
    return _cachedSharedState[type];
  }

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
