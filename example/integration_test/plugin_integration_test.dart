import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_multi_display/flutter_multi_display.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Shared state test', (WidgetTester tester) async {
    final plugin = FlutterMultiDisplay();

    // Set a test state
    const testType = 'TestState';
    const testState = {'key': 'value'};
    await plugin.updateState(testType, testState);

    // Retrieve and verify
    final retrievedState = await plugin.getState(testType);
    expect(retrievedState, testState);

    // Clear state and verify
    await plugin.clearState(testType);
    expect(await plugin.getState(testType), null);
  });
}
