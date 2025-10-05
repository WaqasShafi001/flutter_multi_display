import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class LoginState extends Equatable {
  final bool isLoggedIn;
  final String username;
  final bool isLoading;
  final String? error;

  const LoginState({
    this.isLoggedIn = false,
    this.username = '',
    this.isLoading = false,
    this.error,
  });

  LoginState copyWith({
    bool? isLoggedIn,
    String? username,
    bool? isLoading,
    String? error,
  }) {
    return LoginState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      username: username ?? this.username,
      isLoading: isLoading ?? this.isLoading,
      error: error, // Allow null to clear error
    );
  }

  @override
  List<Object?> get props {
    debugPrint(
      '[LoginState] Comparing props: isLoggedIn=$isLoggedIn, username=$username, isLoading=$isLoading, error=$error',
    );
    return [isLoggedIn, username, isLoading, error];
  }

  Map<String, dynamic> toJson() {
    return {
      'isLoggedIn': isLoggedIn,
      'username': username,
      'isLoading': isLoading,
      'error': error,
    };
  }

  factory LoginState.fromJson(Map<String, dynamic> json) {
    return LoginState(
      isLoggedIn: json['isLoggedIn'] as bool? ?? false,
      username: json['username'] as String? ?? '',
      isLoading: json['isLoading'] as bool? ?? false,
      error: json['error'] as String?,
    );
  }
}
