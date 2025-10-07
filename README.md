# flutter_multi_display

[![pub package](https://img.shields.io/pub/v/flutter_multi_display.svg)](https://pub.dev/packages/flutter_multi_display)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)

A powerful Flutter plugin for building multi-display Android applications with seamless state management across multiple screens.

## Features

- **Multi-Display Support**: Run Flutter UI on up to 3 physical displays simultaneously (1 primary + 2 secondary displays)
- **Multiple Flutter Engines**: Each display runs its own independent Flutter engine for optimal performance
- **Shared State Management**: Synchronize state across all displays in real-time
- **Type-Safe State**: Build custom shared state classes with full type safety
- **Flexible Display Detection**: Automatic or port-based display sorting (VGA, HDMI)
- **State Persistence**: Built-in caching for instant state access
- **Reactive Updates**: Integration with Flutter's `ChangeNotifier` pattern

## Use Cases

Perfect for building:
- **Point of Sale (POS) Systems**: Cashier display + customer-facing display
- **Digital Signage**: Multiple screens showing synchronized content
- **Kiosk Applications**: Main interface + advertisement/information displays
- **Restaurant Systems**: Kitchen display + order display + customer display
- **Retail Solutions**: Product display + checkout display
- **Interactive Installations**: Multi-screen experiences

## Platform Support

| Platform | Supported |
|----------|-----------|
| Android  | ✅        |
| iOS      | ❌        |
| Web      | ❌        |
| Windows  | ❌        |
| MacOS    | ❌        |
| Linux    | ❌        |

**Note**: Currently supports Android only. iOS and other platform support may be added in future releases.

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_multi_display: ^0.0.3
```

Then run:

```bash
flutter pub get
```

## Setup


### 1. Minimum SDK Version

Ensure your `android/app/build.gradle` has minimum SDK 21:

```gradle
android {
    defaultConfig {
        minSdkVersion 21
        // ...
    }
}
```

### 2. MainActivity Override (REQUIRED)

**IMPORTANT**: You must override your `MainActivity.kt` to properly manage the Flutter engine lifecycle for secondary displays.

Replace your `android/app/src/main/kotlin/<your-package>/MainActivity.kt` with:

```kotlin
package com.your.package.name  // Update this to match your package

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import com.github.waqasshafi001.flutter_multi_display.FlutterMultiDisplayPlugin

class MainActivity : FlutterActivity() {
    private var multiDisplayPlugin: FlutterMultiDisplayPlugin? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Store reference to FlutterMultiDisplayPlugin
        multiDisplayPlugin = flutterEngine.plugins.get(
            FlutterMultiDisplayPlugin::class.java
        ) as? FlutterMultiDisplayPlugin
    }

    override fun onStart() {
        super.onStart()
        // Resume secondary engines when app starts
        multiDisplayPlugin?.onStart()
    }

    override fun onStop() {
        super.onStop()
        // Pause secondary engines when app stops
        multiDisplayPlugin?.onStop()
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        super.cleanUpFlutterEngine(flutterEngine)
        // Clear the plugin reference
        multiDisplayPlugin = null
    }
}
```

**Important Notes**:
- Update the package name at the top to match your app's package
- This setup ensures secondary displays properly pause/resume with your app's lifecycle
- Without this, secondary displays may not work correctly

## Quick Start

### Complete Example

Here's a complete example showing a multi-display Flutter app with synchronized state management using `SharedState` across multiple screens.

**main.dart:**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_multi_display/flutter_multi_display.dart';
import 'apps/main_app.dart';
import 'apps/ads_app.dart';
import 'apps/customer_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Setup multi-display BEFORE runApp
  await FlutterMultiDisplay().setupMultiDisplay(
    ['screen1Main', 'screen2Main'],
    portBased: true, // Sort displays by port type (VGA, HDMI)
  );

  runApp(const MainApp());
}

// Entrypoint for first secondary display (e.g., Ads Display)
@pragma('vm:entry-point')
Future<void> screen1Main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AdsApp());
}

// Entrypoint for second secondary display (e.g., Customer Display)
@pragma('vm:entry-point')
Future<void> screen2Main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CustomerApp());
}

```
> **Note**: The entrypoint names (`screen1Main`, `screen2Main`) above are exact and must match the `@pragma('vm:entry-point')` function names below. See [Important Notes](#important-notes) for details.

**apps/main_app.dart:**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_multi_display_example/pages/main_app_pages/login_page.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Main Display',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const LoginPage(),
    );
  }
}

```

**apps/ads_app.dart:**
> The Ads app is included as an entrypoint. The detailed ad page content is optional and omitted for brevity.

```dart
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


```

**apps/customer_app.dart:**

```dart
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

  void _onStateChanged() => setState(() {});

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

```

### Shared State Management

This example organizes SharedState usage into three clear steps so it's easy to replicate:

**1. Create Shared State Classes:**

**state/app_state.dart:**

```dart
import 'package:flutter_multi_display/flutter_multi_display.dart';

// Shared state for user authentication
class UserState extends SharedState<UserData> {
  @override
  UserData fromJson(Map<String, dynamic> json) => UserData.fromJson(json);

  @override
  Map<String, dynamic>? toJson(UserData? data) => data?.toJson();
}

class UserData {
  final String username;
  final String currentScreen; // 'login', 'home', 'height', 'height_view'

  UserData({required this.username, this.currentScreen = 'login'});

  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
        username: json['username'] as String? ?? '',
        currentScreen: json['currentScreen'] as String? ?? 'login',
      );

  Map<String, dynamic> toJson() => {
        'username': username,
        'currentScreen': currentScreen,
      };

  UserData copyWith({String? username, String? currentScreen}) => UserData(
        username: username ?? this.username,
        currentScreen: currentScreen ?? this.currentScreen,
      );
}

// Shared state for height data
class HeightState extends SharedState<HeightData> {
  @override
  HeightData fromJson(Map<String, dynamic> json) => HeightData.fromJson(json);

  @override
  Map<String, dynamic>? toJson(HeightData? data) => data?.toJson();
}

class HeightData {
  final double height;
  HeightData({required this.height});

  factory HeightData.fromJson(Map<String, dynamic> json) =>
      HeightData(height: (json['height'] as num?)?.toDouble() ?? 0.0);

  Map<String, dynamic> toJson() => {'height': height};
}

```

**2. Use shared state in the Main Display (login, home, height pages)**

**pages/main_app_pages/login_page.dart:**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_multi_display_example/state/app_state.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final UserState _userState = UserState();

  @override
  void initState() {
    super.initState();
    // Clear state when on login page
    _userState.clear();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _userState.dispose();
    super.dispose();
  }

  void _login() {
    final username = _usernameController.text.trim();
    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a username')));
      return;
    }

    // Update shared state with user info
    _userState.sync(UserData(username: username, currentScreen: 'home'));

    // Navigate to home page
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const HomePage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login - Main Display'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person, size: 100, color: Colors.blue),
              const SizedBox(height: 40),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.account_circle),
                ),
                onSubmitted: (_) => _login(),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Login', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

```

**pages/main_app_pages/home_page.dart:**

```dart
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
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const HeightPage()));
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

```

**3. Use shared state in the Customer Display (customer-facing UI)**

**pages/customer_app_pages/customer_login_prompt_page.dart**

```dart
import 'package:flutter/material.dart';

class CustomerLoginPromptPage extends StatelessWidget {
  const CustomerLoginPromptPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(40),
          margin: const EdgeInsets.symmetric(horizontal: 60),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.login, size: 100, color: Colors.green.shade600),
              const SizedBox(height: 32),
              Text(
                'Please enter username\non main display',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Customer Display',
                style: TextStyle(fontSize: 18, color: Colors.green.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

```
**pages/customer_app_pages/customer_welcome_page.dart**

```dart
import 'package:flutter/material.dart';

class CustomerWelcomePage extends StatelessWidget {
  final String username;

  const CustomerWelcomePage({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(40),
          margin: const EdgeInsets.symmetric(horizontal: 60),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.waving_hand, size: 100, color: Colors.green.shade600),
              const SizedBox(height: 32),
              Text(
                'Welcome!',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade800,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                username,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w500,
                  color: Colors.green.shade700,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Customer Display',
                style: TextStyle(fontSize: 18, color: Colors.green.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

```

## Important Notes

### Entrypoint Naming

**CRITICAL**: Entrypoint function names must match exactly in both places:

1. **In `main()` function**:
```dart
await FlutterMultiDisplay().setupMultiDisplay([
  'screen1Main',  // Must match exactly
  'screen2Main',  // Must match exactly
], portBased: true);
```

2. **In entrypoint function definitions**:
```dart
@pragma('vm:entry-point')
void screen1Main() {  // Must match exactly
  runApp(const AdsApp());
}

@pragma('vm:entry-point')
void screen2Main() {  // Must match exactly
  runApp(const CustomerApp());
}
```

**Name Mismatch = Display Won't Work!**

### Port-Based Display Sorting

When `portBased: true`:
1. Primary display (built-in screen) - runs `main()`
2. VGA display - runs first entrypoint (`screen1Main`)
3. HDMI displays - runs second entrypoint (`screen2Main`)

When `portBased: false`:
- Displays are assigned in detection order

### State Management Best Practices

1. **Always call `dispose()`** on SharedState objects:
```dart
@override
void dispose() {
  myState.dispose();
  super.dispose();
}
```

2. **Use `addListener()` for reactive updates**:
```dart
myState.addListener(() {
  setState(() {}); // Rebuild widget
});
```

3. **Sync state across displays**:
```dart
myState.sync(newValue); // Updates ALL displays
```

4. **Clear state when needed**:
```dart
myState.clear(); // Removes state from ALL displays
```

## API Reference

### FlutterMultiDisplay

| Method | Description |
|--------|-------------|
| `setupMultiDisplay(List<String> entrypoints, {bool portBased = false})` | Initialize multi-display with Dart entrypoints |
| `updateState(String type, Map<String, dynamic>? state)` | Update shared state |
| `getState(String type)` | Retrieve shared state |
| `getAllState()` | Get all shared states |
| `clearState(String type)` | Clear specific shared state |
| `getPlatformVersion()` | Get Android version |

### SharedState<T>

| Property/Method | Description |
|-----------------|-------------|
| `state` | Current state value |
| `value` | Implements ValueListenable |
| `sync(T? state)` | Update state across all displays |
| `clear()` | Clear state |
| `fromJson(Map<String, dynamic> json)` | Deserialize state (override required) |
| `toJson(T? data)` | Serialize state (override required) |

## Troubleshooting

### Displays not showing

- Ensure physical displays are properly connected
- Check Android display settings (Developer Options → Simulate secondary displays)
- Verify entrypoint function names match exactly in both `setupMultiDisplay()` and function definitions
- Confirm `@pragma('vm:entry-point')` annotation is present on all entrypoint functions
- Verify `MainActivity.kt` has been properly overridden

### State not syncing

- Verify state type identifiers match across all instances
- Check that `fromJson` and `toJson` are implemented correctly
- Ensure listeners are properly registered with `addListener()`
- Confirm `dispose()` is called to prevent memory leaks

### Build errors

- Verify minimum SDK version is 21 or higher
- Check that all dependencies are properly added
- Ensure `MainActivity.kt` package name matches your app
- Run `flutter clean` and rebuild

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Support

- **Repository**: [GitHub](https://github.com/WaqasShafi001/flutter_multi_display)
- **Issues**: [GitHub Issues](https://github.com/WaqasShafi001/flutter_multi_display/issues)
- **Discussions**: [GitHub Discussions](https://github.com/WaqasShafi001/flutter_multi_display/discussions)

---

Made with ❤️ for the Flutter community