import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_multi_display/shared_state_manager.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final usernameCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  late final LoginSharedState _sharedState;
  late final VoidCallback _sharedListener;

  LoginCubit() : super(const LoginState()) {
    // Initialize shared state
    _sharedState = LoginSharedState();

    // Listen to shared state changes and emit if different
    _sharedListener = () {
      final sharedValue = _sharedState.value;
      debugPrint('[LoginCubit] Shared state changed: $sharedValue');
      if (sharedValue != null && sharedValue != state) {
        emit(sharedValue);
      }
    };
    _sharedState.addListener(_sharedListener);

    // Force initial sync
    syncState();

    // Sync initial state immediately
    _sharedState.initialSync.then((_) {
      final initialShared = _sharedState.value;
      debugPrint('[LoginCubit] Initial sync completed: $initialShared');
      if (initialShared != null && initialShared != state) {
        emit(initialShared);
      }
    });
  }

  @override
  void emit(LoginState state) {
    debugPrint('[LoginCubit] Emitting state: $state');
    // Update shared state if different (prevents loops)
    if (state != _sharedState.value) {
      _sharedState.setState(state);
    }
    super.emit(state);
  }

  @override
  Future<void> close() {
    debugPrint('[LoginCubit] Closing cubit');
    _sharedState.removeListener(_sharedListener);
    _sharedState.dispose();
    usernameCtrl.dispose();
    passwordCtrl.dispose();
    return super.close();
  }

  Future<void> login() async {
    final username = usernameCtrl.text.trim();
    final password = passwordCtrl.text.trim();

    if (username.isEmpty || password.isEmpty) {
      debugPrint('[Display 1] Login attempted with empty credentials');
      emit(state.copyWith(error: 'Please enter username and password'));
      return;
    }

    debugPrint('[Display 1] Login button pressed: username=$username');

    emit(state.copyWith(isLoading: true, error: null));

    try {
      // Update state (emit will sync to shared)
      debugPrint('[Display 1] Setting isLoggedIn=true');
      var newState = state.copyWith(isLoggedIn: true, username: username);
      emit(newState);

      debugPrint('[Display 1] Login successful');

      final allState = await SharedStateManager.instance.methodChannel
          .invokeMapMethod<String, dynamic>('getAllState');
      debugPrint('[Display 1] Current state after login: $allState');
    } catch (e) {
      debugPrint('[Display 1] Login error: $e');
      emit(state.copyWith(error: 'Login failed: $e'));
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> logout() async {
    debugPrint('[Display 1] Logout button pressed');

    try {
      // Update state (emit syncs)
      emit(state.copyWith(isLoggedIn: false, username: ''));
      debugPrint('[Display 1] Logout successful');

      usernameCtrl.clear();
      passwordCtrl.clear();
    } catch (e) {
      debugPrint('[Display 1] Logout error: $e');
      emit(state.copyWith(error: 'Logout failed: $e'));
    }
  }

  Future<void> syncState() async {
    final sharedValue = await _sharedState.initialSync.then(
      (_) => _sharedState.value,
    );
    debugPrint('[LoginCubit] Forcing sync: $sharedValue');
    if (sharedValue != null && sharedValue != state) {
      emit(sharedValue);
    }
  }
}

class LoginSharedState extends SharedState<LoginState> {
  @override
  LoginState fromJson(Map<String, dynamic> json) {
    debugPrint('[LoginSharedState] Parsing JSON: $json');
    return LoginState.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(LoginState? data) {
    final json = data?.toJson();
    debugPrint('[LoginSharedState] Converting to JSON: $json');
    return json;
  }
}
