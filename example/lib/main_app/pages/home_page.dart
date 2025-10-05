import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_multi_display_example/main_app/state/data_cubit.dart';
import 'package:flutter_multi_display_example/main_app/pages/height_page.dart';
import 'package:flutter_multi_display_example/main_app/pages/login_page.dart';
import 'package:flutter_multi_display_example/main_app/state/screen_cubit.dart';
import 'package:flutter_multi_display_example/main_app/pages/weight_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home'), actions: [
         IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<DataCubit>().clearUsername();
              context.read<ScreenCubit>().setScreen('login');
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false, // Clear navigation stack
              );
            },
            tooltip: 'Logout',
          ),
      ],),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                context.read<ScreenCubit>().setScreen('height');
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HeightPage()),
                );
              },
              child: const Text('Height Page'),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<ScreenCubit>().setScreen('weight');
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WeightPage()),
                );
              },
              child: const Text('Weight Page'),
            ),
          ],
        ),
      ),
    );
  }
}
