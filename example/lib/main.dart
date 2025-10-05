import 'package:flutter/material.dart';
import 'package:flutter_multi_display/flutter_multi_display.dart';
import 'package:flutter_multi_display_example/ads_app/ads_app.dart';
import 'package:flutter_multi_display_example/main_app/main_app.dart';
import 'package:flutter_multi_display_example/secondary_app/secondary_app.dart';

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
