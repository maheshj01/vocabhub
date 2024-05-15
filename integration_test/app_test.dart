import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:navbar_router/navbar_router.dart';
import 'package:vocabhub/exports.dart';
import 'package:vocabhub/main.dart' as app;
import 'package:vocabhub/main.dart';
import 'package:vocabhub/navbar/navbar.dart';
import 'package:vocabhub/navbar/profile/edit.dart';
import 'package:vocabhub/onboarding/onboarding.dart';
import 'package:vocabhub/pages/addword.dart';
import 'package:vocabhub/pages/drafts.dart';
import 'package:vocabhub/pages/login.dart';
import 'package:vocabhub/pages/notifications/notifications.dart';
import 'package:vocabhub/widgets/button.dart';

extension FindText on String {
  Finder textX() => find.text(this);
}

extension FindKey on Key {
  Finder keyX() => find.byKey(this);
}

extension FindType on Type {
  Finder typeX() => find.byType(this);
}

extension DelayInSeconds on int {
  Future<void> delay() => Future.delayed(Duration(seconds: this));
}

extension FindWidget on Widget {
  Finder widgetX() => find.byWidget(this);
}

extension FindIcon on IconData {
  Finder iconX() => find.byIcon(this);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  bool skip = false;

  group('User should be onboarded', () {
    testWidgets('Skip Onboarding', skip: skip, (WidgetTester tester) async {
      await app.main();
      // await binding.convertFlutterSurfaceToImage();
      await 3.delay();
      await tester.pumpAndSettle();
      expect((app.VocabApp).typeX(), findsOneWidget);
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 1));
      print("WelcomePage");
      expect((WelcomePage).typeX(), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
      print("WelcomePage1");
      final skipForNow = "Skip for now".textX();
      expect(skipForNow, findsOneWidget);
      await tester.pumpAndSettle();
      await tester.tap(skipForNow);
      await tester.pump(const Duration(seconds: 1)); // wait for animation to complete
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
      await tester.pump(Duration(seconds: 2));
      expect((OnboardingPage).typeX(), findsOneWidget);
      await tester.pump(Duration(seconds: 2));
      final title0 = (onBoardingTitles[0]).textX();
      expect(title0, findsOneWidget);
      await tester.dragFrom(Offset(400, 0), const Offset(-400, 0));
      await tester.pump(Duration(seconds: 2));
      final title1 = (onBoardingTitles[1]).textX();
      expect(title1, findsOneWidget);
      await tester.pump(Duration(seconds: 1));
      await tester.dragFrom(Offset(400, 0), const Offset(-400, 0));
      await tester.pump(Duration(seconds: 2));
      final title2 = (onBoardingTitles[2]).textX();
      expect(title2, findsOneWidget);
      await tester.pump(Duration(seconds: 2));
      await tester.dragFrom(Offset(400, 0), const Offset(-400, 0));
      await tester.pump(Duration(seconds: 2));
      final title3 = (onBoardingTitles[3]).textX();
      expect(title3, findsOneWidget);
      await tester.pump(Duration(seconds: 1));
      await tester.dragFrom(Offset(400, 0), const Offset(-400, 0));
      await tester.pump(Duration(seconds: 2));
      final title4 = (onBoardingTitles[4]).textX();
      expect(title4, findsOneWidget);
      await tester.pump(Duration(seconds: 2));
      final getStartedText = "Get Started".textX();
      expect(getStartedText, findsOneWidget);
      await tester.tap(getStartedText);
      await tester.pump(Duration(seconds: 2));
      expect((AppSignIn).typeX(), findsOneWidget);
    });
  });

  group('Test App should load:', () {
    testWidgets('User should be able to login', skip: skip, (WidgetTester tester) async {
      // runZonedGuarded(app.main, (error, stack) {
      // });
      await app.main();
      // await binding.convertFlutterSurfaceToImage();
      await Future.delayed(const Duration(seconds: 3));
      await tester.pump(Duration(seconds: 2));
      expect((app.VocabApp).typeX(), findsOneWidget);
      await tester.pump(Duration(seconds: 2));
      print("App loaded");
      // expect((Dashboard).typeX(), findsOneWidget);

      // await tester.pump(Duration(seconds: 2));

      final dashboardIcon = Icons.dashboard.iconX();
      final usericon = Icons.person.iconX();

      expect(dashboardIcon, findsOneWidget);
      expect(usericon, findsNothing);
      final signIntextFinder = "Sign In".textX();
      expect(signIntextFinder, findsWidgets);
      await tester.pump(Duration(seconds: 2));
      await tester.tap(signIntextFinder.first);
      await tester.pump(Duration(seconds: 2));

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

    testWidgets('Unpublished Word should be saved to drafts', skip: skip, (widgetTester) async {
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

      await Future.delayed(const Duration(seconds: 1));

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

      final backButton = Icons.arrow_back.iconX();
      expect(backButton, findsOneWidget);
      await widgetTester.tap(backButton);
      await widgetTester.tap(addWordTitle);
      await widgetTester.pumpAndSettle();
      final drafts = addWordController.drafts;
      expect(drafts.length, 0);
      await widgetTester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 3));
      final dialog = (VocabAlert).typeX();
      expect(dialog, findsOneWidget);
      await widgetTester.pumpAndSettle();
      final title = 'Save word to drafts?';
      expect(title.textX(), findsOneWidget);
      await widgetTester.pumpAndSettle();
      final save = 'Save'.textX();
      expect(save, findsOneWidget);
      await widgetTester.tap(save);
      await widgetTester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 3));
      expect((Dashboard).typeX(), findsOneWidget);
      await widgetTester.pumpAndSettle();
      expect(drafts.length, 1);
    });

    testWidgets('load Unpublished word from drafts', skip: skip, (widgetTester) async {
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
      expect(addWordController.drafts.length, 1);

      final draftIcon = Icons.drafts.iconX();
      expect(draftIcon, findsOneWidget);
      await widgetTester.tap(draftIcon);
      await widgetTester.pumpAndSettle();
      expect((Drafts).typeX(), findsOneWidget);
      await widgetTester.pumpAndSettle();
      final draftWord = addWordController.drafts[0];
      final wordText = draftWord.word.textX();
      expect(wordText, findsOneWidget);
      await widgetTester.tap(wordText);
      await widgetTester.pumpAndSettle();
      expect(addWordController.drafts.length, 0);
      expect((AddWordForm).typeX(), findsOneWidget);
      await widgetTester.tap(addWordTitle);
      await widgetTester.pumpAndSettle(Duration(seconds: 3));
      await Future.delayed(const Duration(seconds: 3));

      /// scroll to the bottom of the page
      final inputFields = (VocabField).typeX();
      expect(inputFields.evaluate().length, 5);
      await widgetTester.drag(inputFields.at(3), const Offset(0, -200));
      await widgetTester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 1));
      final submitButton = "Submit".textX();
      expect(submitButton, findsOneWidget);
      await widgetTester.tap(submitButton);
      await widgetTester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 3));
      // final snackBar = (SnackBar).typeX();
      // expect(snackBar, findsOneWidget);
      // await Future.delayed(const Duration(seconds: 3));
      expect((Dashboard).typeX(), findsOneWidget);
    });

    testWidgets('Users should be able to add a new word', skip: skip, (widgetTester) async {
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

      await Future.delayed(const Duration(seconds: 1));

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

    testWidgets('Reject the added test word', skip: skip, (widgetTester) async {
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
      expect(rejectIcon, findsWidgets);
      await widgetTester.tap(rejectIcon.at(0));
      await widgetTester.tap(rejectIcon.at(1));
      await widgetTester.pumpAndSettle();
    });

    testWidgets('Word can be added to custom Collections', skip: skip, (widgetTester) async {
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
      await 1.delay();
      await widgetTester.pumpAndSettle();
      final wodCards = (WoDCard).typeX();
      expect(wodCards, findsWidgets);
      await widgetTester.pumpAndSettle();
      await widgetTester.tap(wodCards.at(0));
      await widgetTester.pumpAndSettle();
      final collectionIcon = Icons.bookmark_add.iconX();
      expect(collectionIcon, findsOneWidget);
      await widgetTester.tap(collectionIcon);
      await widgetTester.pumpAndSettle();
      await 1.delay();
      final collectionTitle = "Collections".textX();
      expect(collectionTitle, findsWidgets);
      await widgetTester.pumpAndSettle();
      final demoTitle = "How collections work".textX();
      await 1.delay();
      expect(demoTitle, findsOneWidget);
      await widgetTester.pumpAndSettle();
      List<String> collectionTitles = ['Easy', 'Medium', 'Hard', 'Test Collection'];
      for (int i = 0; i < collectionTitles.length; i++) {
        final createCollection = "Create Collection".textX();
        expect(createCollection, findsOneWidget);
        await widgetTester.tap(createCollection);
        await widgetTester.pumpAndSettle();
        await 1.delay();
        final newCollectionTitle = "New Collection".textX();
        expect(newCollectionTitle, findsOneWidget);
        await widgetTester.pumpAndSettle();
        final inputField = (VHTextfield).typeX();
        expect(inputField, findsOneWidget);
        await widgetTester.enterText(inputField, collectionTitles[i]);
        await widgetTester.pumpAndSettle();
        await 1.delay();
        final button = (VHButton).typeX();
        expect(button, findsOneWidget);
        await widgetTester.tap(button);
        await widgetTester.pumpAndSettle();
        await 1.delay();
        expect(collectionTitle, findsWidgets);
        await widgetTester.pumpAndSettle();
        final testCollection = "${collectionTitles[i]} (0)".textX();
        expect(testCollection, findsOneWidget);
        await 1.delay();
        final addIcon = Icons.add_circle_outline_outlined.iconX();
        expect(addIcon, i > 0 ? findsWidgets : findsOneWidget);
        if (i > 0) {
          await widgetTester.tap(addIcon.at(i));
          await widgetTester.pumpAndSettle();
          await 1.delay();
          final checkIcon = Icons.check.iconX();
          expect(checkIcon, findsOneWidget);
          await widgetTester.tap(checkIcon);
          final testCollection1 = "${collectionTitles[i]} (1)".textX();
          expect(testCollection1, findsOneWidget);
          await widgetTester.pumpAndSettle();
        } else {
          await widgetTester.tap(addIcon);
          await widgetTester.pumpAndSettle();
          await 1.delay();
          final checkIcon = Icons.check.iconX();
          expect(checkIcon, findsOneWidget);
          await widgetTester.tap(checkIcon);
          final testCollection1 = "${collectionTitles[i]} (1)".textX();
          expect(testCollection1, findsOneWidget);
          await widgetTester.pumpAndSettle();
        }
      }

      /// hide the collection bottom sheet
      await widgetTester.tapAt(Offset(100, 100));
      await widgetTester.pumpAndSettle();
    });
    testWidgets('Word can be added to new collection', skip: skip, (widgetTester) async {});
  });

  // group('Collections Should work as Intended', () {
  //   testWidgets('Skip User Onboarding', skip: skip, (WidgetTester tester) async {
  //     await app.main();
  //     // await binding.convertFlutterSurfaceToImage();
  //     await Future.delayed(const Duration(seconds: 3));
  //     await tester.pumpAndSettle();
  //     expect((app.VocabApp).typeX(), findsOneWidget);
  //     await tester.pumpAndSettle();
  //     await Future.delayed(const Duration(seconds: 1));
  //     expect((WelcomePage).typeX(), findsOneWidget);
  //     await tester.pumpAndSettle();
  //     final skipForNow = "Skip for now".textX();
  //     expect(skipForNow, findsOneWidget);
  //     await tester.pumpAndSettle();
  //     await tester.tap(skipForNow);
  //     await tester.pumpAndSettle();
  //     expect((AppSignIn).typeX(), findsOneWidget);
  //   });
  // });
}
