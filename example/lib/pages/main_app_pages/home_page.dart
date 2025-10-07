import 'package:flutter/material.dart';
import 'package:flutter_multi_display_example/state/app_state.dart';
import 'height_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final UserState _userState = UserState();

  @override
  void initState() {
    super.initState();
    // Ensure we're on home screen
    final currentUser = _userState.state;
    if (currentUser != null) {
      _userState.sync(currentUser.copyWith(currentScreen: 'home'));
    }
  }

  @override
  void dispose() {
    _userState.dispose();
    super.dispose();
  }

  void _logout() {
    // Clear all state
    _userState.clear();
    final heightState = HeightState();
    heightState.clear();
    heightState.dispose();

    // Pop to login page
    Navigator.of(context).pop();
  }

  void _navigateToHeight() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const HeightPage()));
  }

  @override
  Widget build(BuildContext context) {
    final username = _userState.state?.username ?? 'User';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home - Main Display'),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _logout,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.home, size: 100, color: Colors.blue),
              const SizedBox(height: 24),
              Text(
                'Welcome, $username!',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 48),
              ElevatedButton.icon(
                onPressed: _navigateToHeight,
                icon: const Icon(Icons.height),
                label: const Text('Height'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 60),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
