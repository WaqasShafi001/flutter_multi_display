import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_multi_display_example/data_cubit.dart';
import 'package:flutter_multi_display_example/shared_states.dart';

class ViewerState extends DataState {
  final String currentScreen;

  ViewerState({
    required this.currentScreen,
    super.username,
    super.height,
    super.weight,
  });

  @override
  ViewerState copyWith({
    String? currentScreen,
    String? username,
    double? height,
    double? weight,
  }) {
    return ViewerState(
      currentScreen: currentScreen ?? this.currentScreen,
      username: username ?? this.username,
      height: height ?? this.height,
      weight: weight ?? this.weight,
    );
  }
}

class ViewerCubit extends Cubit<ViewerState> {
  final CurrentScreenState _screen = CurrentScreenState();
  final UsernameState _username = UsernameState();
  final HeightState _height = HeightState();
  final WeightState _weight = WeightState();

  ViewerCubit()
    : super(
        ViewerState(
          currentScreen: CurrentScreenState().value ?? 'login',
          username: UsernameState().value,
          height: HeightState().value,
          weight: WeightState().value,
        ),
      ) {
    _screen.addListener(_updateFromShared);
    _username.addListener(_updateFromShared);
    _height.addListener(_updateFromShared);
    _weight.addListener(_updateFromShared);
  }

  void _updateFromShared() {
    emit(
      state.copyWith(
        currentScreen: _screen.value ?? 'login',
        username: _username.value,
        height: _height.value,
        weight: _weight.value,
      ),
    );
  }

  @override
  Future<void> close() {
    _screen.removeListener(_updateFromShared);
    _username.removeListener(_updateFromShared);
    _height.removeListener(_updateFromShared);
    _weight.removeListener(_updateFromShared);
    return super.close();
  }
}
