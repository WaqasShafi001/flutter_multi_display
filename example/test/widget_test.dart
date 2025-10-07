import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_multi_display_example/apps/main_app.dart';
import 'package:flutter_multi_display_example/apps/customer_app.dart';
import 'package:flutter_multi_display_example/apps/ads_app.dart';
import 'package:flutter_multi_display_example/state/app_state.dart';
import 'package:flutter_multi_display_example/pages/main_app_pages/login_page.dart';
import 'package:flutter_multi_display_example/pages/main_app_pages/home_page.dart';
import 'package:flutter_multi_display_example/pages/main_app_pages/height_page.dart';
import 'package:flutter_multi_display_example/pages/customer_app_pages/customer_login_prompt_page.dart';
import 'package:flutter_multi_display_example/pages/customer_app_pages/customer_welcome_page.dart';
import 'package:flutter_multi_display_example/pages/customer_app_pages/customer_height_prompt_page.dart';
import 'package:flutter_multi_display_example/pages/customer_app_pages/customer_height_view_page.dart';
import 'package:flutter_multi_display_example/pages/ads_app_pages/ads_page.dart';

void main() {
  // Basic UI tests for main app flow
  testWidgets('MainApp starts with LoginPage', (WidgetTester tester) async {
    await tester.pumpWidget(const MainApp());
    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.text('Login - Main Display'), findsOneWidget);
  });

  testWidgets('LoginPage navigates to HomePage after valid username', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    await tester.enterText(find.byType(TextField), 'Waqas');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    expect(find.byType(HomePage), findsOneWidget);
    expect(find.textContaining('Welcome, Waqas'), findsOneWidget);
  });

  testWidgets('HomePage navigates to HeightPage', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomePage()));
    expect(find.byType(HomePage), findsOneWidget);

    await tester.tap(find.byIcon(Icons.height));
    await tester.pumpAndSettle();

    expect(find.byType(HeightPage), findsOneWidget);
    expect(find.text('Enter Height - Main Display'), findsOneWidget);
  });

  testWidgets('HeightPage shows error when height is invalid', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HeightPage()));

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(find.text('Please enter your height'), findsOneWidget);
  });

  testWidgets('HeightPage accepts valid height input', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HeightPage()));

    await tester.enterText(find.byType(TextField), '180');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    // Confirm no invalid height message
    expect(find.text('Please enter a valid height'), findsNothing);
  });

  // -------- CustomerApp Tests --------
  testWidgets('CustomerApp shows login prompt when no user state', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const CustomerApp());
    await tester.pumpAndSettle();

    expect(find.byType(CustomerLoginPromptPage), findsOneWidget);
    expect(find.textContaining('Please enter username'), findsOneWidget);
  });

  testWidgets('CustomerApp shows welcome screen when user is home', (
    WidgetTester tester,
  ) async {
    final userState = UserState();
    userState.sync(UserData(username: 'Waqas', currentScreen: 'home'));

    await tester.pumpWidget(const CustomerApp());
    await tester.pumpAndSettle();

    expect(find.byType(CustomerWelcomePage), findsOneWidget);
    expect(find.text('Waqas'), findsOneWidget);
  });

  testWidgets('CustomerApp shows height prompt when user is on height screen', (
    WidgetTester tester,
  ) async {
    final userState = UserState();
    userState.sync(UserData(username: 'Waqas', currentScreen: 'height'));

    await tester.pumpWidget(const CustomerApp());
    await tester.pumpAndSettle();

    expect(find.byType(CustomerHeightPromptPage), findsOneWidget);
  });

  testWidgets(
    'CustomerApp shows height view when user is on height_view screen',
    (WidgetTester tester) async {
      final userState = UserState();
      final heightState = HeightState();

      userState.sync(UserData(username: 'Waqas', currentScreen: 'height_view'));
      heightState.sync(HeightData(height: 175.0));

      await tester.pumpWidget(const CustomerApp());
      await tester.pumpAndSettle();

      expect(find.byType(CustomerHeightViewPage), findsOneWidget);
      expect(find.textContaining('175.0 cm'), findsOneWidget);
    },
  );

  // -------- AdsApp Tests --------
  testWidgets('AdsApp displays AdsPage', (WidgetTester tester) async {
    await tester.pumpWidget(const AdsApp());
    expect(find.byType(AdsPage), findsOneWidget);
    expect(find.text('ADVERTISEMENT'), findsOneWidget);
  });
}
