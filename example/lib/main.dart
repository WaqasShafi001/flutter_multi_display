import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_multi_display/flutter_multi_display.dart';
import 'login_cubit.dart';
import 'login_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('=== Main Display Starting ===');
  await FlutterMultiDisplay().setupMultiDisplay(['screen1Main', 'screen2Main']);
  runApp(
    const ScreenApp(title: "Main Screen", color: Colors.blue, screenId: 1),
  );
}

@pragma('vm:entry-point')
Future<void> screen1Main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('=== External Screen 1 Starting ===');
  runApp(
    const ScreenApp(title: "External Screen 1", color: Colors.red, screenId: 2),
  );
}

@pragma('vm:entry-point')
Future<void> screen2Main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('=== External Screen 2 Starting ===');
  runApp(
    const ScreenApp(
      title: "External Screen 2",
      color: Colors.green,
      screenId: 3,
    ),
  );
}

class ScreenApp extends StatelessWidget {
  final String title;
  final Color color;
  final int screenId;

  const ScreenApp({
    super.key,
    required this.title,
    required this.color,
    required this.screenId,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: color,
        body: Stack(
          children: [
            ScreenContent(screenId: screenId),
            // Add screen identifier overlay
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Screen ID: $screenId',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ScreenContent extends StatelessWidget {
  final int screenId;
  const ScreenContent({super.key, required this.screenId});

  @override
  Widget build(BuildContext context) {
    if (screenId == 1) return const LoginScreen();
    if (screenId == 2) return const AdsScreen();
    return const LoginViewer();
  }
}

// LoginScreen and other classes remain the same, but use updated LoginCubit
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginCubit(),
      child: BlocBuilder<LoginCubit, LoginState>(
        builder: (context, state) {
          final cubit = context.read<LoginCubit>();
          if (state.isLoggedIn) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Home Page\nWelcome, ${state.username}!",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 20,
                    runSpacing: 10,
                    alignment: WrapAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () => _showFeatureDialog(context, 'Height'),
                        child: const Text("Height"),
                      ),
                      ElevatedButton(
                        onPressed: () => _showFeatureDialog(context, 'Weight'),
                        child: const Text("Weight"),
                      ),
                      ElevatedButton(
                        onPressed: () =>
                            _showFeatureDialog(context, 'Blood Pressure'),
                        child: const Text("Blood Pressure"),
                      ),
                      ElevatedButton(
                        onPressed: () =>
                            _showFeatureDialog(context, 'Body Composition'),
                        child: const Text("Body Composition"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: cubit.logout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Logout"),
                  ),
                ],
              ),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Login",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: cubit.usernameCtrl,
                    enabled: !state.isLoading,
                    decoration: const InputDecoration(
                      labelText: "Username",
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: cubit.passwordCtrl,
                    obscureText: true,
                    enabled: !state.isLoading,
                    decoration: const InputDecoration(
                      labelText: "Password",
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  state.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : ElevatedButton(
                          onPressed: () => cubit.login(),
                          child: const Text("Login"),
                        ),
                  if (state.isLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Text(
                        'Logging in...',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  void _showFeatureDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(feature),
        content: Text('$feature feature coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class LoginViewer extends StatelessWidget {
  const LoginViewer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginCubit()..syncState(), // Add syncState call,
      child: BlocBuilder<LoginCubit, LoginState>(
        builder: (context, state) {
          debugPrint(
            '[Display 3] BUILD METHOD CALLED: isLoggedIn=${state.isLoggedIn}, username=${state.username}',
          );

          final content = state.isLoggedIn
              ? _buildWelcomeScreen(state.username)
              : _buildLoginPrompt();

          return Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: state.isLoggedIn
                        ? Colors.greenAccent
                        : Colors.orangeAccent,
                    width: 5,
                  ),
                ),
                child: content,
              ),
              Positioned(
                bottom: 16,
                right: 16,
                child: ElevatedButton(
                  onPressed: () => context.read<LoginCubit>().syncState(),
                  child: const Text("Sync State"),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // _buildWelcomeScreen and _buildLoginPrompt remain the same
  Widget _buildWelcomeScreen(String username) {
    debugPrint('[Display 3] Building WELCOME screen for username=$username');
    return Container(
      color: Colors.green.withOpacity(0.3),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle,
              size: 120,
              color: Colors.greenAccent,
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text(
                    "✓ LOGGED IN ✓",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Welcome to the KIOSK system",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Hello, $username!",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 32,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.greenAccent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Status: LOGGED IN ✓',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginPrompt() {
    debugPrint('[Display 3] Building LOGIN PROMPT screen');
    return Container(
      color: Colors.orange.withOpacity(0.3),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.lock_outline,
              size: 120,
              color: Colors.orangeAccent,
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                children: [
                  Text(
                    "⚠ NOT LOGGED IN ⚠",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Please enter your login credentials\non Display 1",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, color: Colors.black87),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.orangeAccent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Status: Waiting for login...',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AdsScreen extends StatelessWidget {
  const AdsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.ad_units, size: 80, color: Colors.white),
          const SizedBox(height: 20),
          const Text(
            "Ads Screen",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Display 2 - Advertisement Content",
            style: TextStyle(fontSize: 18, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
