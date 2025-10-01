import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_multi_display_example/login_cubit.dart';
import 'package:flutter_multi_display_example/login_state.dart';
import 'package:flutter_multi_display_example/main.dart';

void main() {
  testWidgets('LoginScreen displays login UI when not logged in', (WidgetTester tester) async {
    // Build ScreenApp with screenId=1 (LoginScreen)
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create: (context) => LoginCubit(),
          child: const ScreenApp(
            title: "Main Screen",
            color: Colors.blue,
            screenId: 1,
          ),
        ),
      ),
    );

    // Verify login UI elements
    expect(find.text('Login'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2)); // Username and Password
    expect(find.text('Logging in...'), findsNothing);
  });

  testWidgets('LoginScreen displays home UI when logged in', (WidgetTester tester) async {
    // Create a logged-in state
    final cubit = LoginCubit();
    cubit.emit(const LoginState(isLoggedIn: true, username: 'testuser'));

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create: (context) => cubit,
          child: const ScreenApp(
            title: "Main Screen",
            color: Colors.blue,
            screenId: 1,
          ),
        ),
      ),
    );

    // Verify home UI elements
    expect(find.text('Home Page\nWelcome, testuser!'), findsOneWidget);
    expect(find.text('Logout'), findsOneWidget);
    expect(find.text('Login'), findsNothing);
  });
}