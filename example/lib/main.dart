import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_multi_display/flutter_multi_display.dart';
import 'package:flutter_multi_display_example/ads_page.dart';
import 'package:flutter_multi_display_example/data_cubit.dart';
import 'package:flutter_multi_display_example/height_view_page.dart';
import 'package:flutter_multi_display_example/info_page.dart';
import 'package:flutter_multi_display_example/login_page.dart';
import 'package:flutter_multi_display_example/screen_cubit.dart';
import 'package:flutter_multi_display_example/viewer_cubit.dart';
import 'package:flutter_multi_display_example/weight_view_page.dart';
import 'package:flutter_multi_display_example/welcome_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterMultiDisplay().setupMultiDisplay([
    'screen1Main',
    'screen2Main',
  ], portBased: true);
  runApp(const MainApp());
}

@pragma('vm:entry-point')
void screen1Main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AdsApp());
}

@pragma('vm:entry-point')
void screen2Main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SecondaryApp());
}

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

class AdsApp extends StatelessWidget {
  const AdsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AdsPage(),
    );
  }
}
