import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multi_display_example/state/app_state.dart';

class HeightPage extends StatefulWidget {
  const HeightPage({super.key});

  @override
  State<HeightPage> createState() => _HeightPageState();
}

class _HeightPageState extends State<HeightPage> {
  final TextEditingController _heightController = TextEditingController();
  final UserState _userState = UserState();
  final HeightState _heightState = HeightState();

  @override
  void initState() {
    super.initState();
    // Update screen state to 'height'
    final currentUser = _userState.state;
    if (currentUser != null) {
      _userState.sync(currentUser.copyWith(currentScreen: 'height'));
    }
  }

  @override
  void dispose() {
    _heightController.dispose();
    _userState.dispose();
    _heightState.dispose();
    super.dispose();
  }

  void _confirmHeight() {
    final heightText = _heightController.text.trim();
    if (heightText.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter your height')));
      return;
    }

    final height = double.tryParse(heightText);
    if (height == null || height <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid height')),
      );
      return;
    }

    // Save height to shared state
    _heightState.sync(HeightData(height: height));

    // Update screen state to 'height_view'
    final currentUser = _userState.state;
    if (currentUser != null) {
      _userState.sync(currentUser.copyWith(currentScreen: 'height_view'));
    }
  }

  void _goBack() {
    // Update screen state back to 'home'
    final currentUser = _userState.state;
    if (currentUser != null) {
      _userState.sync(currentUser.copyWith(currentScreen: 'home'));
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Height - Main Display'),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _goBack,
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.height, size: 100, color: Colors.blue),
              const SizedBox(height: 40),
              TextField(
                controller: _heightController,
                decoration: const InputDecoration(
                  labelText: 'Height (cm)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.straighten),
                  hintText: 'e.g., 175',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                onSubmitted: (_) => _confirmHeight(),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _confirmHeight,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Confirm', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
