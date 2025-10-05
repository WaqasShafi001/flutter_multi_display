import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_multi_display_example/main_app/state/data_cubit.dart';
import 'package:flutter_multi_display_example/main_app/pages/login_page.dart';
import 'package:flutter_multi_display_example/main_app/state/screen_cubit.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ScreenCubit()),
        BlocProvider(create: (_) => DataCubit()),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: LoginPage(),
      ),
    );
  }
}
