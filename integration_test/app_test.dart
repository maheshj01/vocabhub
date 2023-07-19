import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:navbar_router/navbar_router.dart';
import 'package:vocabhub/main.dart' as app;
import 'package:vocabhub/navbar/navbar.dart';
import 'package:vocabhub/onboarding/onboarding.dart';
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
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized()
      as IntegrationTestWidgetsFlutterBinding;
  group('Test App should load:', () {
    testWidgets('New User should be onboarded', (WidgetTester tester) async {
      await app.main();
      // await binding.convertFlutterSurfaceToImage();
      await Future.delayed(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect((app.VocabApp).typeX(), findsOneWidget);
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 1));
      expect((WelcomePage).typeX(), findsOneWidget);
      // final title = "Welcome\nto\nVocabhub".textX();
      // expect(title, findsOneWidget);
      await tester.pumpAndSettle();
      final takeATour = "Take a tour".textX();
      expect(takeATour, findsOneWidget);
      await tester.pumpAndSettle();
      await tester.tap(takeATour);
      await tester.pumpAndSettle();
      expect((OnboardingPage).typeX(), findsOneWidget);
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 3));
      final title1 = 'A Crowd Sourced platform'.textX();
      expect(title1, findsOneWidget);
      final list = List.generate(3, (index) => index).toList();
      double offset = 400;
      await for (final item in Stream.fromIterable(list)) {
        await tester.timedDragFrom(
            Offset(offset, 800), Offset(-offset, 800), Duration(milliseconds: 500));
        await tester.pumpAndSettle();
        offset += 400;
      }
      // await Future.delayed(const Duration(seconds: 1));
      // final title2 = 'Word of the Day'.textX();
      // expect(title2, findsOneWidget);
      // await Future.delayed(const Duration(seconds: 1));
      // await tester.dragFrom(Offset(400, 800), const Offset(-400, 800));
      // // await tester.drag(pageView, const Offset(-400, 400));
      // await tester.pumpAndSettle();
      // final title3 = 'Explore curated words'.textX();
      // expect(title3, findsOneWidget);
      // await tester.dragFrom(Offset(400, 800), const Offset(-400, 800));
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 1));
      final getStartedText = "Get Started".textX();
      expect(getStartedText, findsOneWidget);
      await tester.pumpAndSettle();
      await tester.tap(getStartedText);
      await tester.pumpAndSettle();
      expect((AppSignIn).typeX(), findsOneWidget);
    });

    testWidgets('User should be able to login', (WidgetTester tester) async {
      // runZonedGuarded(app.main, (error, stack) {
      // });
      await app.main();
      // await binding.convertFlutterSurfaceToImage();
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
      // final bytes = await binding.takeScreenshot('test-1');
      // final File image = File('./screenshots/test-1.png');
      // image.writeAsBytesSync(bytes);
    });

    testWidgets("User stays loggedIn", (widgetTester) async {
      await app.main();
      // await binding.convertFlutterSurfaceToImage();
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
      // final bytes = await binding.takeScreenshot('test-2');
      // final File image = File('./screenshots/test-2.png');
      // image.writeAsBytesSync(bytes);
    });

    testWidgets("Ensure all navbar widgets load", (widgetTester) async {
      await app.main();
      await binding.convertFlutterSurfaceToImage();
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
      // final bytes = await binding.takeScreenshot('test-3');
      // final File image = File('screenshots/test-3.png');
      // image.writeAsBytesSync(bytes);
    });
  });
}
