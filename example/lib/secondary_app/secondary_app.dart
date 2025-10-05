import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_multi_display_example/secondary_app/pages/height_view_page.dart';
import 'package:flutter_multi_display_example/secondary_app/pages/info_page.dart';
import 'package:flutter_multi_display_example/secondary_app/state/viewer_cubit.dart';
import 'package:flutter_multi_display_example/secondary_app/pages/weight_view_page.dart';
import 'package:flutter_multi_display_example/secondary_app/pages/welcome_page.dart';

class SecondaryApp extends StatelessWidget {
  const SecondaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ViewerCubit(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: BlocBuilder<ViewerCubit, ViewerState>(
          builder: (context, state) {
            switch (state.currentScreen) {
              case 'login':
                return const InfoPage();
              case 'home':
                return const WelcomePage();
              case 'height':
                return HeightViewPage(height: state.height);
              case 'weight':
                return WeightViewPage(weight: state.weight);
              default:
                return const InfoPage();
            }
          },
        ),
      ),
    );
  }
}
