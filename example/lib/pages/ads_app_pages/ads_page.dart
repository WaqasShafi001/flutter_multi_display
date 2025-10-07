import 'package:flutter/material.dart';

class AdsPage extends StatefulWidget {
  const AdsPage({super.key});

  @override
  State<AdsPage> createState() => _AdsPageState();
}

class _AdsPageState extends State<AdsPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<String> _ads = [
    '🎉 Special Offer! Get 50% Off',
    '🌟 New Products Available',
    '🚀 Limited Time Deal',
    '💎 Premium Quality Items',
    '🎁 Buy 2 Get 1 Free',
  ];
  int _currentAdIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat();

    _controller.addListener(() {
      if (_controller.value > 0.99) {
        setState(() {
          _currentAdIndex = (_currentAdIndex + 1) % _ads.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.campaign, size: 120, color: Colors.orange),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(32),
              margin: const EdgeInsets.symmetric(horizontal: 40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'ADVERTISEMENT',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 24),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: Text(
                      _ads[_currentAdIndex],
                      key: ValueKey<int>(_currentAdIndex),
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                  LinearProgressIndicator(
                    value: _controller.value,
                    backgroundColor: Colors.orange.shade100,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Text(
              'Ads Display Screen',
              style: TextStyle(
                fontSize: 18,
                color: Colors.orange.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
