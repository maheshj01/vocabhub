import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:vocabhub/main.dart' as app;
import 'package:vocabhub/pages/splashscreen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Test App', () {
    testWidgets('Test SplashScreen should load', (WidgetTester tester) async {
      runZonedGuarded(app.main, (error, stack) {
        print('runZonedGuarded: Caught error in my root zone.$error $stack');
      });

      expect(find.byType(app.VocabApp), findsOneWidget, skip: true);
      await tester.pumpAndSettle();
      expect(find.byType(SplashScreen), findsOneWidget, skip: true);
      await tester.pumpAndSettle();
    });
  });
}
