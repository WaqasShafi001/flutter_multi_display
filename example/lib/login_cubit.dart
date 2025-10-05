import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_multi_display/shared_state_manager.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final usernameCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  final LoginSharedState _sharedState;

  LoginCubit() : _sharedState = LoginSharedState(), super(const LoginState()) {
    // Initialize with shared state if available
    if (_sharedState.state != null) {
      emit(_sharedState.state!);
    }
    // Listen to shared state changes
    _sharedState.addListener(_onSharedStateChanged);
  }

  void _onSharedStateChanged() {
    final sharedState = _sharedState.state;
    debugPrint('[LoginCubit] Shared state changed: $sharedState');
    if (sharedState != null && sharedState != state) {
      emit(sharedState);
    }
  }

  @override
  void emit(LoginState state) {
    debugPrint('[LoginCubit] Emitting state: $state');
    // Sync shared state before emitting
    _sharedState.sync(state);
    super.emit(state);
  }

  @override
  Future<void> close() {
    debugPrint('[LoginCubit] Closing cubit');
    _sharedState.removeListener(_onSharedStateChanged);
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
      // Update state (emit will sync)
      debugPrint('[Display 1] Setting isLoggedIn=true');
      emit(
        state.copyWith(isLoggedIn: true, username: username, error: null),
      ); // Clear error on success
      debugPrint('[Display 1] Login successful');
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
      emit(state.copyWith(isLoggedIn: false, username: '', error: null));
      debugPrint('[Display 1] Logout successful');
      usernameCtrl.clear();
      passwordCtrl.clear();
    } catch (e) {
      debugPrint('[Display 1] Logout error: $e');
      emit(state.copyWith(error: 'Logout failed: $e'));
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
