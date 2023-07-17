import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:navbar_router/navbar_router.dart';
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
      final notificationIcon = Icons.notifications_on.iconX();
      expect(notificationIcon, findsOneWidget);
      expect(signInTextFinder, findsNothing);
      await Future.delayed(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect(dashboardIcon, findsOneWidget);
      expect(usericon, findsOneWidget);
    });

    testWidgets("User stays loggedIn", (widgetTester) async {
      app.main();
      await Future.delayed(const Duration(seconds: 3));
      await widgetTester.pumpAndSettle();
      expect((Dashboard).typeX(), findsOneWidget);
      await widgetTester.pumpAndSettle();
      final dashboardIcon = Icons.dashboard.iconX();
      final usericon = Icons.person.iconX();
      final signIntextFinder = "Sign In".textX();
      final notificationIcon = Icons.notifications_on.iconX();

      expect(signIntextFinder, findsNothing);
      expect(notificationIcon, findsOneWidget);
      expect(dashboardIcon, findsOneWidget);
      expect(usericon, findsOneWidget);
    });

    testWidgets("Ensure all navbar widgets load", (widgetTester) async {
      app.main();
      final List<Widget> baseWidgets = [
        Dashboard(),
        Search(),
        ExploreWords(
          onScrollThresholdReached: () {},
        ),
        UserProfile(),
      ];
      final List<NavbarItem> items = [
        NavbarItem(Icons.dashboard, 'Dashboard'),
        NavbarItem(Icons.search, 'Search'),
        NavbarItem(Icons.explore, 'Explore'),
        NavbarItem(Icons.person, 'Me')
      ];

      await Future.delayed(const Duration(seconds: 3));
      await widgetTester.pumpAndSettle();
      for (int i = 0; i < items.length; i++) {
        final icon = items[i].iconData.iconX();
        expect(icon, findsOneWidget);
      }
      final dashBoard = baseWidgets[0].runtimeType.typeX();
      final search = baseWidgets[1].runtimeType.typeX();
      final explore = baseWidgets[2].runtimeType.typeX();
      final profile = baseWidgets[3].runtimeType.typeX();

      expect(dashBoard, findsOneWidget);

      await widgetTester.pumpAndSettle();
      await widgetTester.tap(items[1].iconData.iconX());
      await widgetTester.pumpAndSettle();
      expect(search, findsOneWidget);

      await widgetTester.pumpAndSettle();
      await widgetTester.tap(items[2].iconData.iconX());
      await widgetTester.pumpAndSettle();
      expect(explore, findsOneWidget);

      await widgetTester.pumpAndSettle();
      await widgetTester.tap(items[3].iconData.iconX());
      await widgetTester.pumpAndSettle();
      expect(profile, findsOneWidget);
    });
  });
}
