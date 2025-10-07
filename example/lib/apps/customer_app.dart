import 'package:flutter/material.dart';
import 'package:flutter_multi_display_example/pages/customer_app_pages/customer_height_prompt_page.dart';
import 'package:flutter_multi_display_example/pages/customer_app_pages/customer_height_view_page.dart';
import 'package:flutter_multi_display_example/pages/customer_app_pages/customer_login_prompt_page.dart';
import 'package:flutter_multi_display_example/pages/customer_app_pages/customer_welcome_page.dart';
import 'package:flutter_multi_display_example/state/app_state.dart';

class CustomerApp extends StatefulWidget {
  const CustomerApp({super.key});

  @override
  State<CustomerApp> createState() => _CustomerAppState();
}

class _CustomerAppState extends State<CustomerApp> {
  final UserState _userState = UserState();
  final HeightState _heightState = HeightState();

  @override
  void initState() {
    super.initState();
    _userState.addListener(_onStateChanged);
    _heightState.addListener(_onStateChanged);
  }

  void _onStateChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _userState.removeListener(_onStateChanged);
    _heightState.removeListener(_onStateChanged);
    _userState.dispose();
    _heightState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Customer Display',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green, useMaterial3: true),
      home: _buildCurrentPage(),
    );
  }

  Widget _buildCurrentPage() {
    final userData = _userState.state;
    final heightData = _heightState.state;

    if (userData == null || userData.currentScreen == 'login') {
      return const CustomerLoginPromptPage();
    }

    switch (userData.currentScreen) {
      case 'home':
        return CustomerWelcomePage(username: userData.username);
      case 'height':
        return const CustomerHeightPromptPage();
      case 'height_view':
        return CustomerHeightViewPage(
          username: userData.username,
          height: heightData?.height ?? 0.0,
        );
      default:
        return const CustomerLoginPromptPage();
    }
  }
}
