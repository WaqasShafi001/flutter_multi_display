import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

typedef OnSharedStateChangeListener = void Function(Map<String, dynamic>?);

const _sharedStateChannelName =
    'flutter_multi_display/shared_state'; // Updated channel for package

abstract class SharedState<T>
    with ChangeNotifier
    implements ValueListenable<T?> {
  T? _state;

  T? get state => _state;

  @override
  T? get value => _state;

  late final Future initialSync;
  bool _isSyncComplete = false;

  SharedState() : super() {
    SharedStateManager.instance.addStateChangeListener(
      runtimeType.toString(),
      _onStateChange,
    );

    final cachedState = SharedStateManager.instance.getCachedState(
      runtimeType.toString(),
    );
    if (cachedState != null) {
      _isSyncComplete = true;
      _state = fromJson(cachedState);
      debugPrint(
        '[SharedState] Initial cached state for $runtimeType: $_state',
      );
      return;
    }
    initialSync = _syncState();
  }

  void setState(T? state) async {
    _state = state;
    if (!_isSyncComplete) {
      await initialSync;
    }

    debugPrint('[SharedState] Setting state for $runtimeType: $state');

    notifyListeners();
    SharedStateManager.instance.updateState(
      runtimeType.toString(),
      toJson(state),
    );
  }

  void clearState() async {
    if (!_isSyncComplete) {
      await initialSync;
    }
    _state = null;
    debugPrint('[SharedState] Clearing state for $runtimeType');
    notifyListeners();
    SharedStateManager.instance.clearState(runtimeType.toString());
  }

  Future _syncState() async {
    final json = await SharedStateManager.instance.getState(
      runtimeType.toString(),
    );
    _isSyncComplete = true;

    if (json != null) {
      _onStateChange(json);
    }
    debugPrint('[SharedState] Sync completed for $runtimeType: $_state');
  }

  void _onStateChange(Map<String, dynamic>? newState) {
    debugPrint(
      '[SharedState] Received state change for $runtimeType: $newState',
    );
    if (_isSameState(newState)) {
      return;
    }

    try {
      if (newState == null) {
        _state = null;
      } else {
        _state = fromJson(newState);
      }
      debugPrint('[SharedState] Updated state for $runtimeType: $_state');
      notifyListeners();
    } catch (e) {
      debugPrint(
        "SharedState failed to parse for $runtimeType from: $newState, $e",
      );
    }
  }

  bool _isSameState(Map<String, dynamic>? newState) {
    // return newState?.toString() == toJson(state)?.toString();
    return false; // temporary
  }

  @override
  void dispose() {
    debugPrint('[SharedState] Disposing $runtimeType');
    SharedStateManager.instance.removeStateChangeListener(
      runtimeType.toString(),
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

  late final Future _syncSharedState;
  Map<String, Map<String, dynamic>?> _cachedSharedState = {};
  bool _hasSyncData = false;

  SharedStateManager._() {
    methodChannel = const MethodChannel(_sharedStateChannelName);
    methodChannel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onStateChanged':
          if (!_hasSyncData) {
            await _syncSharedState;
          }

          final type = call.arguments['type'] as String;
          final rawData = call.arguments['data'];
          final newState = rawData != null
              ? Map<String, dynamic>.from(rawData)
              : null;
          _cachedSharedState[type] = newState;
          _notifyListeners(type, newState);
          break;
        default:
          debugPrint("SharedStateManager: Unknown method ${call.method}");
      }
      return null;
    });
    _syncSharedState = _initSharedState();
  }

  Future _initSharedState() async {
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
  }

  Future<Map<String, dynamic>?> getState(String type) async {
    if (!_hasSyncData) {
      await _syncSharedState;
    }
    return _cachedSharedState[type];
  }

  Map<String, dynamic>? getCachedState(String type) {
    return _cachedSharedState[type];
  }

  Future<void> updateState(String type, Map<String, dynamic>? data) async {
    try {
      if (!_hasSyncData) {
        await _syncSharedState;
      }

      _cachedSharedState[type] = data;
      _notifyListeners(type, data);

      await methodChannel.invokeMethod('updateState', {
        'type': type,
        'state': data,
      });
    } on PlatformException catch (e) {
      debugPrint('Error updating shared state: ${e.message}');
    }
  }

  Future<void> clearState(String type) async {
    try {
      if (!_hasSyncData) {
        await _syncSharedState;
      }

      _cachedSharedState[type] = null;
      _notifyListeners(type, null);
      await methodChannel.invokeMethod('clearState', {'type': type});
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
    if (stateListeners == null || stateListeners.isEmpty) {
      return;
    }
    stateListeners.remove(listener);
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
