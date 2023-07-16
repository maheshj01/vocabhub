import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:vocabhub/main.dart' as app;
import 'package:vocabhub/navbar/navbar.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Test App', () {
    testWidgets('Test SplashScreen should load', (WidgetTester tester) async {
      // runZonedGuarded(app.main, (error, stack) {
      //   print('runZonedGuarded: Caught error in my root zone.$error $stack');
      // });
      app.main();
      await Future.delayed(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      expect(find.byType(app.VocabApp), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.byType(Dashboard), findsOneWidget);
      await tester.pumpAndSettle();
    });
  });
}
