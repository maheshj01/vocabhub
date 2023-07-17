import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:vocabhub/main.dart' as app;
import 'package:vocabhub/navbar/navbar.dart';
import 'package:vocabhub/pages/login.dart';

extension FindText on String {
  Finder textX() => find.text(this);
}

extension FindKey on Key {
  Finder keyX() => find.byKey(this);
}

extension FindType on Type {
  Finder typeX() => find.byType(this);
}

extension FindWidget on Widget {
  Finder widgetX() => find.byWidget(this);
}

extension FindIcon on IconData {
  Finder iconX() => find.byIcon(this);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Test App should load', () {
    testWidgets('User should be able to login', (WidgetTester tester) async {
      // runZonedGuarded(app.main, (error, stack) {
      // });
      app.main();
      await Future.delayed(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect((app.VocabApp).typeX(), findsOneWidget);
      await tester.pumpAndSettle();
      expect((Dashboard).typeX(), findsOneWidget);
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      final dashboardIcon = Icons.dashboard.iconX();
      final usericon = Icons.person.iconX();

      expect(dashboardIcon, findsOneWidget);
      expect(usericon, findsNothing);
      final signIntextFinder = "Sign In".textX();
      expect(signIntextFinder, findsWidgets);
      await tester.pumpAndSettle();
      await tester.tap(signIntextFinder.first);
      await tester.pumpAndSettle();

      // Sign In flow

      expect((AppSignIn).typeX(), findsOneWidget);
      await tester.pumpAndSettle();
      expect((Dashboard).typeX(), findsNothing);
      await tester.pumpAndSettle();

      final signInTextFinder = "Sign In with Google".textX();
      expect(signInTextFinder, findsOneWidget);
      await tester.pumpAndSettle();
      await tester.tap(signInTextFinder);
      await tester.pumpAndSettle();
      expect((Dashboard).typeX(), findsOneWidget);
      await tester.pumpAndSettle();
      expect(signInTextFinder, findsNothing);
      Future.delayed(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect(dashboardIcon, findsOneWidget);
      expect(usericon, findsOneWidget);
    });

    // testWidgets("User stays loggedIn", (widgetTester) async {
    //   expect((Dashboard).typeX(), findsOneWidget);
    //   await widgetTester.pumpAndSettle();
    //   final dashboardIcon = Icons.dashboard.iconX();
    //   final usericon = Icons.person.iconX();
    //   expect(dashboardIcon, findsOneWidget);
    //   expect(usericon, findsOneWidget);
    // });
  });
}
