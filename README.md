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

| Android | iOS | Web | Windows | MacOS | Linux |
|---------|-----|-----|---------|-------|-------|
| ✅      | ❌  | ❌  | ❌      | ❌    | ❌    |

**Note**: Currently supports Android only. iOS and other platform support may be added in future releases.

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_multi_display: ^0.0.1
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

Here's a complete example showing a multi-display app with state synchronization:

**main.dart:**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_multi_display/flutter_multi_display.dart';

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
void screen1Main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AdsApp());
}

// Entrypoint for second secondary display (e.g., Customer Display)
@pragma('vm:entry-point')
void screen2Main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SecondaryApp());
}

// Main App - Primary Display
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

// Ads App - First Secondary Display
class AdsApp extends StatelessWidget {
  const AdsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Text(
            'Advertisements Here',
            style: TextStyle(fontSize: 48),
          ),
        ),
      ),
    );
  }
}

// Secondary App - Second Secondary Display
class SecondaryApp extends StatelessWidget {
  const SecondaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CustomerDisplay(),
    );
  }
}
```

### Shared State Management

**1. Create Shared State Classes:**

```dart
// shared_states.dart
import 'package:flutter_multi_display/flutter_multi_display.dart';

// Screen navigation state
class CurrentScreenState extends SharedState<String> {
  @override
  String fromJson(Map<String, dynamic> json) {
    return json['screen'] as String;
  }

  @override
  Map<String, dynamic>? toJson(String? data) {
    return data == null ? null : {'screen': data};
  }
}

// Username state
class UsernameState extends SharedState<String> {
  @override
  String fromJson(Map<String, dynamic> json) {
    return json['username'] as String;
  }

  @override
  Map<String, dynamic>? toJson(String? data) {
    return data == null ? null : {'username': data};
  }
}

// Height state
class HeightState extends SharedState<double> {
  @override
  double fromJson(Map<String, dynamic> json) {
    return (json['height'] as num).toDouble();
  }

  @override
  Map<String, dynamic>? toJson(double? data) {
    return data == null ? null : {'height': data};
  }
}

// Weight state
class WeightState extends SharedState<double> {
  @override
  double fromJson(Map<String, dynamic> json) {
    return (json['weight'] as num).toDouble();
  }

  @override
  Map<String, dynamic>? toJson(double? data) {
    return data == null ? null : {'weight': data};
  }
}
```

**2. Use State in Main Display:**

```dart
// home_page.dart
import 'package:flutter/material.dart';
import 'shared_states.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _screenState = CurrentScreenState();
  final _usernameState = UsernameState();
  final _heightState = HeightState();
  final _weightState = WeightState();
  
  final _usernameController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Listen to state changes
    _screenState.addListener(() => setState(() {}));
    _usernameState.addListener(() => setState(() {}));
    _heightState.addListener(() => setState(() {}));
    _weightState.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Main Display')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Username Input
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            ElevatedButton(
              onPressed: () {
                final username = _usernameController.text.trim();
                if (username.isNotEmpty) {
                  _usernameState.sync(username);
                  _screenState.sync('home');
                }
              },
              child: const Text('Login'),
            ),
            const SizedBox(height: 20),
            
            // Height Input
            TextField(
              controller: _heightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Height (cm)'),
            ),
            ElevatedButton(
              onPressed: () {
                final height = double.tryParse(_heightController.text.trim());
                if (height != null) {
                  _heightState.sync(height);
                  _screenState.sync('height');
                }
              },
              child: const Text('Submit Height'),
            ),
            const SizedBox(height: 20),
            
            // Weight Input
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Weight (kg)'),
            ),
            ElevatedButton(
              onPressed: () {
                final weight = double.tryParse(_weightController.text.trim());
                if (weight != null) {
                  _weightState.sync(weight);
                  _screenState.sync('weight');
                }
              },
              child: const Text('Submit Weight'),
            ),
            const SizedBox(height: 20),
            
            // Logout
            ElevatedButton(
              onPressed: () {
                _usernameState.clear();
                _heightState.clear();
                _weightState.clear();
                _screenState.sync('login');
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _screenState.dispose();
    _usernameState.dispose();
    _heightState.dispose();
    _weightState.dispose();
    _usernameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }
}
```

**3. Use State in Secondary Display:**

```dart
// customer_display.dart
import 'package:flutter/material.dart';
import 'shared_states.dart';

class CustomerDisplay extends StatefulWidget {
  const CustomerDisplay({super.key});

  @override
  State<CustomerDisplay> createState() => _CustomerDisplayState();
}

class _CustomerDisplayState extends State<CustomerDisplay> {
  final _screenState = CurrentScreenState();
  final _usernameState = UsernameState();
  final _heightState = HeightState();
  final _weightState = WeightState();

  @override
  void initState() {
    super.initState();
    // Listen to state changes from main display
    _screenState.addListener(() => setState(() {}));
    _usernameState.addListener(() => setState(() {}));
    _heightState.addListener(() => setState(() {}));
    _weightState.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final screen = _screenState.value ?? 'login';
    
    return Scaffold(
      body: Center(
        child: _buildScreen(screen),
      ),
    );
  }

  Widget _buildScreen(String screen) {
    switch (screen) {
      case 'login':
        return const Text(
          'Please login on main display',
          style: TextStyle(fontSize: 32),
        );
      case 'home':
        return Text(
          'Welcome, ${_usernameState.value ?? "Guest"}!',
          style: const TextStyle(fontSize: 48),
        );
      case 'height':
        return Text(
          'Height: ${_heightState.value ?? "Not set"} cm',
          style: const TextStyle(fontSize: 48),
        );
      case 'weight':
        return Text(
          'Weight: ${_weightState.value ?? "Not set"} kg',
          style: const TextStyle(fontSize: 48),
        );
      default:
        return const Text('Unknown screen');
    }
  }

  @override
  void dispose() {
    _screenState.dispose();
    _usernameState.dispose();
    _heightState.dispose();
    _weightState.dispose();
    super.dispose();
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
  runApp(const SecondaryApp());
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