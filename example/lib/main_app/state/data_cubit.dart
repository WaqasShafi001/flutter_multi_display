import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_multi_display_example/shared/shared_states.dart';

class DataState {
  final String? username;
  final double? height;
  final double? weight;

  DataState({this.username, this.height, this.weight});

  DataState copyWith({String? username, double? height, double? weight}) {
    return DataState(
      username: username ?? this.username,
      height: height ?? this.height,
      weight: weight ?? this.weight,
    );
  }
}

class DataCubit extends Cubit<DataState> {
  final UsernameState _username = UsernameState();
  final HeightState _height = HeightState();
  final WeightState _weight = WeightState();

  DataCubit()
    : super(
        DataState(
          username: UsernameState().value,
          height: HeightState().value,
          weight: WeightState().value,
        ),
      );

  void setUsername(String username) {
    _username.sync(username);
    emit(state.copyWith(username: username));
  }

  void clearUsername() {
    _username.clear();
    emit(state.copyWith(username: null));
  }

  void setHeight(double height) {
    _height.sync(height);
    emit(state.copyWith(height: height));
  }

  void setWeight(double weight) {
    _weight.sync(weight);
    emit(state.copyWith(weight: weight));
  }
}
