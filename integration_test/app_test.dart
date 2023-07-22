import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:navbar_router/navbar_router.dart';
import 'package:vocabhub/exports.dart';
import 'package:vocabhub/main.dart' as app;
import 'package:vocabhub/navbar/navbar.dart';
import 'package:vocabhub/onboarding/onboarding.dart';
import 'package:vocabhub/pages/addword.dart';
import 'package:vocabhub/pages/login.dart';
import 'package:vocabhub/pages/notifications/notifications.dart';

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

  bool skip = false;
  group('Test App should load:', () {
    testWidgets('Skip Onboarding', skip: skip, (WidgetTester tester) async {
      await app.main();
      // await binding.convertFlutterSurfaceToImage();
      await Future.delayed(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect((app.VocabApp).typeX(), findsOneWidget);
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 1));
      expect((WelcomePage).typeX(), findsOneWidget);
      await tester.pumpAndSettle();
      final skipForNow = "Skip for now".textX();
      expect(skipForNow, findsOneWidget);
      await tester.pumpAndSettle();
      await tester.tap(skipForNow);
      await tester.pumpAndSettle();
      expect((AppSignIn).typeX(), findsOneWidget);
    });

    testWidgets('New User should be onboarded', skip: skip, (WidgetTester tester) async {
      await app.main();
      // await binding.convertFlutterSurfaceToImage();
      await Future.delayed(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect((app.VocabApp).typeX(), findsOneWidget);
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 1));
      expect((WelcomePage).typeX(), findsOneWidget);
      await tester.pumpAndSettle();
      final takeATour = "Take a tour".textX();
      expect(takeATour, findsOneWidget);
      await tester.pumpAndSettle();
      await tester.tap(takeATour);
      await tester.pumpAndSettle();
      expect((OnboardingPage).typeX(), findsOneWidget);
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 2));
      final title0 = (onBoardingTitles[0]).textX();
      expect(title0, findsOneWidget);
      await tester.dragFrom(Offset(400, 0), const Offset(-400, 0));
      await Future.delayed(const Duration(seconds: 1));
      await tester.pump(Duration(seconds: 2));
      final title1 = (onBoardingTitles[1]).textX();
      expect(title1, findsOneWidget);
      await Future.delayed(const Duration(seconds: 1));
      await tester.dragFrom(Offset(400, 0), const Offset(-400, 0));
      await Future.delayed(const Duration(seconds: 1));
      await tester.pump(Duration(seconds: 2));
      final title2 = (onBoardingTitles[2]).textX();
      expect(title2, findsOneWidget);
      await Future.delayed(const Duration(seconds: 2));
      await tester.pump(Duration(seconds: 2));
      await tester.dragFrom(Offset(400, 0), const Offset(-400, 0));
      await Future.delayed(const Duration(seconds: 1));
      await tester.pump(Duration(seconds: 2));
      final title3 = (onBoardingTitles[3]).textX();
      expect(title3, findsOneWidget);
      await Future.delayed(const Duration(seconds: 1));
      await tester.dragFrom(Offset(400, 0), const Offset(-400, 0));
      await Future.delayed(const Duration(seconds: 1));
      await tester.pump(Duration(seconds: 2));
      final title4 = (onBoardingTitles[4]).textX();
      expect(title4, findsOneWidget);
      await Future.delayed(const Duration(seconds: 1));
      final getStartedText = "Get Started".textX();
      expect(getStartedText, findsOneWidget);
      await tester.tap(getStartedText);
      await tester.pumpAndSettle();
      expect((AppSignIn).typeX(), findsOneWidget);
    });

    testWidgets('User should be able to login', skip: skip, (WidgetTester tester) async {
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
      final closeIcon = (Icons.close).iconX();
      expect(closeIcon, findsOneWidget);
      await tester.tap(closeIcon);
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

    testWidgets("User stays loggedIn", skip: skip, (widgetTester) async {
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

    testWidgets("Ensure all navbar widgets load", skip: skip, (widgetTester) async {
      await app.main();
      // await binding.convertFlutterSurfaceToImage();
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
      await Future.delayed(const Duration(seconds: 1));
      await widgetTester.pumpAndSettle();
      await widgetTester.tap(items[1].iconData.iconX());
      await widgetTester.pumpAndSettle();
      expect(search, findsOneWidget);
      await Future.delayed(const Duration(seconds: 1));

      await widgetTester.pumpAndSettle();
      await widgetTester.tap(items[2].iconData.iconX());
      await widgetTester.pumpAndSettle();
      expect(explore, findsOneWidget);
      await Future.delayed(const Duration(seconds: 1));

      await widgetTester.pumpAndSettle();
      await widgetTester.tap(items[3].iconData.iconX());
      await widgetTester.pumpAndSettle();
      expect(profile, findsOneWidget);
      await Future.delayed(const Duration(seconds: 1));
      // final bytes = await binding.takeScreenshot('test-3');
      // final File image = File('screenshots/test-3.png');
      // image.writeAsBytesSync(bytes);
    });

    testWidgets('Users should be able to add a new word', (widgetTester) async {
      await app.main();
      // await binding.convertFlutterSurfaceToImage();
      await Future.delayed(const Duration(seconds: 3));
      await widgetTester.pumpAndSettle();
      expect((Dashboard).typeX(), findsOneWidget);
      await widgetTester.pumpAndSettle();
      final floatingIcon = Icons.add.iconX();
      expect(floatingIcon, findsOneWidget);
      await widgetTester.tap(floatingIcon);
      await widgetTester.pumpAndSettle();
      expect((AddWordForm).typeX(), findsOneWidget);
      await widgetTester.pumpAndSettle();

      final addWordTitle = "Add word".textX();
      expect(addWordTitle, findsOneWidget);

      final inputFields = (VocabField).typeX();
      expect(inputFields.evaluate().length, 5);

      await widgetTester.enterText(inputFields.at(0), "testWord");
      await widgetTester.pumpAndSettle();
      await widgetTester.enterText(inputFields.at(1), "this is a meaning of testWord");
      await widgetTester.tap(addWordTitle);
      await widgetTester.pumpAndSettle();
      await widgetTester.drag(find.byType(AddWordForm), const Offset(0, -100));

      await widgetTester.pumpAndSettle();
      await widgetTester.enterText(inputFields.at(2), "synoymOne");
      await widgetTester.pumpAndSettle();
      final doneIcon = Icons.done.iconX();
      expect(doneIcon, findsOneWidget);
      await widgetTester.tap(doneIcon);
      await widgetTester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 1));

      await widgetTester.enterText(inputFields.at(2), "synoymTwo");
      await widgetTester.pumpAndSettle();
      expect(doneIcon, findsOneWidget);
      await widgetTester.tap(doneIcon);
      await widgetTester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 1));
      await widgetTester.pumpAndSettle();
      await widgetTester.enterText(inputFields.at(2), "synoymThree");
      await widgetTester.pumpAndSettle();
      expect(doneIcon, findsOneWidget);
      await widgetTester.tap(doneIcon);
      await widgetTester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 1));
      await widgetTester.tap(addWordTitle);
      await widgetTester.pumpAndSettle();
      await widgetTester.dragFrom(Offset(0, 100), const Offset(0, -100));

      await widgetTester.enterText(
          inputFields.at(3), "This is an example sentence using testWord as an example");
      await widgetTester.pumpAndSettle();
      expect(doneIcon, findsOneWidget);
      await widgetTester.tap(doneIcon);
      await widgetTester.pumpAndSettle();
      await widgetTester.tap(addWordTitle);
      await widgetTester.pumpAndSettle();
      await widgetTester.dragFrom(Offset(0, 100), const Offset(0, -100));

      await Future.delayed(const Duration(seconds: 3));

      await widgetTester.enterText(inputFields.at(4), "This is a mnemonic for testWord");
      await widgetTester.pumpAndSettle();

      expect(doneIcon, findsOneWidget);
      await widgetTester.tap(doneIcon);
      await widgetTester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 3));
      // remove focus from the textfield
      await widgetTester.tap(addWordTitle);
      await widgetTester.pumpAndSettle();
      await widgetTester.dragFrom(Offset(0, 100), const Offset(0, -200));

      final submitButton = "Submit".textX();
      expect(submitButton, findsOneWidget);
      await widgetTester.tap(submitButton);
      await widgetTester.tap(addWordTitle);
      await widgetTester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 3));
      // final snackBar = (SnackBar).typeX();
      // expect(snackBar, findsOneWidget);
      // await Future.delayed(const Duration(seconds: 3));
      expect((Dashboard).typeX(), findsOneWidget);
    });

    testWidgets('Reject the added test word', (widgetTester) async {
      await app.main();
      // await binding.convertFlutterSurfaceToImage();
      await Future.delayed(const Duration(seconds: 3));
      await widgetTester.pumpAndSettle();
      expect((Dashboard).typeX(), findsOneWidget);
      final notificationIcon = (Icons.notifications_on).iconX();
      expect(notificationIcon, findsOneWidget);
      await widgetTester.tap(notificationIcon);
      await widgetTester.pumpAndSettle();
      expect((Notifications).typeX(), findsOneWidget);
      await widgetTester.pumpAndSettle();
      final notificationTitle = "Notifications".textX();
      expect(notificationTitle, findsOneWidget);
      await widgetTester.pumpAndSettle();
      "You requested to add a new word".textX();
      await widgetTester.pumpAndSettle();
      final rejectIcon = Icons.close.iconX();
      expect(rejectIcon, findsOneWidget);
      await widgetTester.tap(rejectIcon);
      await widgetTester.pumpAndSettle();
    });
  });
}
