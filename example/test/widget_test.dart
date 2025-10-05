import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_multi_display_example/data_cubit.dart';
import 'package:flutter_multi_display_example/home_page.dart';
import 'package:flutter_multi_display_example/login_page.dart';
import 'package:flutter_multi_display_example/main.dart';
import 'package:flutter_multi_display_example/screen_cubit.dart';
import 'package:flutter_multi_display_example/viewer_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('LoginPage displays login UI when app starts', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => ScreenCubit()),
          BlocProvider(create: (_) => DataCubit()),
        ],
        child: const MaterialApp(home: LoginPage()),
      ),
    );

    expect(find.text('Login'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Login'), findsWidgets);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('LoginPage navigates to HomePage after successful login', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => ScreenCubit()),
          BlocProvider(create: (_) => DataCubit()),
        ],
        child: const MaterialApp(home: LoginPage()),
      ),
    );

    await tester.enterText(find.byType(TextField), 'testuser');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Height Page'), findsOneWidget);
    expect(find.text('Weight Page'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsNWidgets(2));
    expect(find.text('Login'), findsNothing);
  });

  testWidgets('HomePage logout navigates back to LoginPage', (
    WidgetTester tester,
  ) async {
    final screenCubit = ScreenCubit();
    final dataCubit = DataCubit();
    screenCubit.setScreen('home');
    dataCubit.setUsername('testuser');

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => screenCubit),
          BlocProvider(create: (_) => dataCubit),
        ],
        child: const MaterialApp(home: HomePage()),
      ),
    );

    expect(find.text('Home'), findsOneWidget);
    expect(find.byIcon(Icons.logout), findsOneWidget);

    await tester.tap(find.byIcon(Icons.logout));
    await tester.pumpAndSettle();

    expect(find.text('Login'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Home'), findsNothing);
  });

  testWidgets('SecondaryApp displays InfoPage initially', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      BlocProvider(create: (_) => ViewerCubit(), child: const SecondaryApp()),
    );

    expect(find.text('Please enter username on main display'), findsOneWidget);
  });

  testWidgets('SecondaryApp displays WelcomePage after login', (
    WidgetTester tester,
  ) async {
    final screenCubit = ScreenCubit();
    final dataCubit = DataCubit();
    screenCubit.setScreen('home');
    dataCubit.setUsername('testuser');

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => screenCubit),
          BlocProvider(create: (_) => dataCubit),
          BlocProvider(create: (_) => ViewerCubit()),
        ],
        child: const SecondaryApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Welcome to the system'), findsOneWidget);
    expect(find.text('Please enter username on main display'), findsNothing);
  });

  testWidgets('AdsApp displays AdsPage', (WidgetTester tester) async {
    await tester.pumpWidget(const AdsApp());

    expect(find.text('Ads Here'), findsOneWidget);
  });
}
