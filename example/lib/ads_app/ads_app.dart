import 'package:flutter/material.dart';
import 'package:flutter_multi_display_example/ads_app/pages/ads_page.dart';

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
