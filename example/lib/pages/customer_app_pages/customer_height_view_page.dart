import 'package:flutter/material.dart';

class CustomerHeightViewPage extends StatelessWidget {
  final String username;
  final double height;

  const CustomerHeightViewPage({
    super.key,
    required this.username,
    required this.height,
  });

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
              Icon(
                Icons.accessibility_new,
                size: 100,
                color: Colors.green.shade600,
              ),
              const SizedBox(height: 32),
              Text(
                username,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade800,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Your Height',
                style: TextStyle(fontSize: 24, color: Colors.green.shade600),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  '${height.toStringAsFixed(1)} cm',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade900,
                  ),
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
