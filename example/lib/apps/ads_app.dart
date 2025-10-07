import 'package:flutter/material.dart';
import 'package:flutter_multi_display_example/pages/ads_app_pages/ads_page.dart';

class AdsApp extends StatelessWidget {
  const AdsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ads Display',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.orange, useMaterial3: true),
      home: const AdsPage(),
    );
  }
}
