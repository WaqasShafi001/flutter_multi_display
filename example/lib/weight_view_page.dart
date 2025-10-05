import 'package:flutter/material.dart';

class WeightViewPage extends StatelessWidget {
  final double? weight;

  const WeightViewPage({super.key, this.weight});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: weight == null
            ? const Text('Please enter your weight on main display')
            : Text('Your weight: $weight'),
      ),
    );
  }
}