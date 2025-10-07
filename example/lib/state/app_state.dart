import 'package:flutter_multi_display/flutter_multi_display.dart';

// Shared state for user authentication
class UserState extends SharedState<UserData> {
  @override
  UserData fromJson(Map<String, dynamic> json) {
    return UserData.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(UserData? data) {
    return data?.toJson();
  }
}

// User data model
class UserData {
  final String username;
  final String currentScreen; // 'login', 'home', 'height'

  UserData({required this.username, this.currentScreen = 'login'});

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      username: json['username'] as String? ?? '',
      currentScreen: json['currentScreen'] as String? ?? 'login',
    );
  }

  Map<String, dynamic> toJson() {
    return {'username': username, 'currentScreen': currentScreen};
  }

  UserData copyWith({String? username, String? currentScreen}) {
    return UserData(
      username: username ?? this.username,
      currentScreen: currentScreen ?? this.currentScreen,
    );
  }
}

// Shared state for height data
class HeightState extends SharedState<HeightData> {
  @override
  HeightData fromJson(Map<String, dynamic> json) {
    return HeightData.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(HeightData? data) {
    return data?.toJson();
  }
}

// Height data model
class HeightData {
  final double height;

  HeightData({required this.height});

  factory HeightData.fromJson(Map<String, dynamic> json) {
    return HeightData(height: (json['height'] as num?)?.toDouble() ?? 0.0);
  }

  Map<String, dynamic> toJson() {
    return {'height': height};
  }
}
