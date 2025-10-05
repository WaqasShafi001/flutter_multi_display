import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_multi_display_example/shared/shared_states.dart';

class ScreenCubit extends Cubit<String> {
  final CurrentScreenState _shared = CurrentScreenState();

  ScreenCubit() : super(CurrentScreenState().value ?? 'login');

  void setScreen(String screen) {
    _shared.sync(screen);
    emit(screen);
  }
}
