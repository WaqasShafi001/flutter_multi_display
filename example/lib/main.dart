import 'package:flutter/material.dart';
import 'package:flutter_multi_display/flutter_multi_display.dart';
import 'apps/main_app.dart';
import 'apps/ads_app.dart';
import 'apps/customer_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterMultiDisplay().setupMultiDisplay([
    'screen1Main',
    'screen2Main',
  ], portBased: true);
  runApp(const MainApp());
}

@pragma('vm:entry-point')
Future<void> screen1Main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AdsApp());
}

@pragma('vm:entry-point')
Future<void> screen2Main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CustomerApp());
}
