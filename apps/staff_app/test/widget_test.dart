// Smoke test for the app's entry sequence: the splash screen hands off to
// sign-in on its own timer. Nothing below asserts on authentication — there
// is none yet (see login_screen.dart).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:foxotale_ui/foxotale_ui.dart';
import 'package:staff_app/features/auth/login_screen.dart';
import 'package:staff_app/main.dart';

void main() {
  testWidgets('splash boots and hands off to sign-in', (tester) async {
    await tester.pumpWidget(const FoxOtaleApp());

    // Splash: the tagline is the only plain-text string on it, because the
    // wordmark is split into spans to colour the capital O.
    expect(find.text('Stay Original, Live the Tale'), findsOneWidget);
    expect(find.text('SIGN IN AS'), findsNothing);

    // The handoff is a 1500ms delay, not an animation, so pump past it.
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pumpAndSettle();

    expect(find.text('SIGN IN AS'), findsOneWidget);

    // The sign-up options are below the fold at test viewport size, and a
    // ListView does not build children it has not scrolled to.
    await tester.dragUntilVisible(
      find.text('Sign up with Google'),
      find.byType(ListView),
      const Offset(0, -200),
    );
    expect(find.text('Sign up with Apple'), findsOneWidget);
    expect(find.text('Sign up with Google'), findsOneWidget);
  });

  testWidgets('sign-in offers email and mobile OTP methods', (tester) async {
    await tester.pumpWidget(const FoxOtaleApp());
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pumpAndSettle();

    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Mobile OTP'), findsOneWidget);
  });

  testWidgets('themes build in both modes', (tester) async {
    for (final mode in [Brightness.light, Brightness.dark]) {
      await tester.pumpWidget(MediaQuery(
        data: MediaQueryData(platformBrightness: mode),
        child: const FoxOtaleApp(),
      ));
      await tester.pumpAndSettle(const Duration(milliseconds: 1600));
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('email sign-in lands a GM/HM in property setup', (tester) async {
    // The default 800x600 test viewport puts the sign-in button off screen,
    // so taps miss it. Use a phone-shaped surface instead.
    tester.view.physicalSize = const Size(1206, 2622);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const FoxOtaleApp());
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pumpAndSettle();

    await tester.enterText(
        find.byType(TextField).first, 'gm@foxotalehotels.com');
    await tester.enterText(find.byType(TextField).at(1), 'correct-horse');
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();

    // The default role is GM/HM, which holds propertySetup, and the seeded
    // draft is unpublished — so sign-in goes to the wizard, not the shell.
    expect(find.text('Set up property'), findsOneWidget);
  });

  testWidgets('a real build shows neither the role picker nor social sign-up',
      (tester) async {
    // Debug builds carry both as review affordances. This is the shape a
    // release build produces: FR-S001 resolves one role from the session, and
    // social sign-up belongs to the Guest App.
    tester.view.physicalSize = const Size(1206, 2622);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MaterialApp(
      theme: FoxTheme.light(),
      home: LoginScreen(onSignedIn: (_) {}, reviewAffordances: false),
    ));
    await tester.pumpAndSettle();

    expect(find.text('SIGN IN AS'), findsNothing);
    expect(find.text('Sign up with Apple'), findsNothing);
    expect(find.text('Sign up with Google'), findsNothing);
    expect(find.text('Sign up manually'), findsNothing);

    // The ways in stay: email/password and mobile OTP.
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Mobile OTP'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Sign in'), findsOneWidget);
  });
}
