import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_multi_display_example/data_cubit.dart';
import 'package:flutter_multi_display_example/screen_cubit.dart';

class HeightPage extends StatefulWidget {
  const HeightPage({super.key});

  @override
  State<HeightPage> createState() => _HeightPageState();
}

class _HeightPageState extends State<HeightPage> {
  final TextEditingController _heightController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.read<ScreenCubit>().setScreen('home');
            Navigator.pop(context);
          },
        ),
        title: const Text('Height'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _heightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Enter Height'),
            ),
            ElevatedButton(
              onPressed: () {
                final height = double.tryParse(_heightController.text.trim());
                if (height != null) {
                  context.read<DataCubit>().setHeight(height);
                }
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _heightController.dispose();
    super.dispose();
  }
}
