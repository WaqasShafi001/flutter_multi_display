import 'package:flutter/material.dart';

class HeightViewPage extends StatelessWidget {
  final double? height;

  const HeightViewPage({super.key, this.height});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: height == null
            ? const Text('Please enter your height on main display')
            : Text('Your height: $height'),
      ),
    );
  }
}