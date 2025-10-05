import 'package:flutter_multi_display/shared_state_manager.dart';

class CurrentScreenState extends SharedState<String> {
  @override
  String fromJson(Map<String, dynamic> json) {
    return json['screen'] as String;
  }

  @override
  Map<String, dynamic>? toJson(String? data) {
    return data == null ? null : {'screen': data};
  }
}

class UsernameState extends SharedState<String> {
  @override
  String fromJson(Map<String, dynamic> json) {
    return json['username'] as String;
  }

  @override
  Map<String, dynamic>? toJson(String? data) {
    return data == null ? null : {'username': data};
  }
}

class HeightState extends SharedState<double> {
  @override
  double fromJson(Map<String, dynamic> json) {
    return (json['height'] as num).toDouble();
  }

  @override
  Map<String, dynamic>? toJson(double? data) {
    return data == null ? null : {'height': data};
  }
}

class WeightState extends SharedState<double> {
  @override
  double fromJson(Map<String, dynamic> json) {
    return (json['weight'] as num).toDouble();
  }

  @override
  Map<String, dynamic>? toJson(double? data) {
    return data == null ? null : {'weight': data};
  }
}