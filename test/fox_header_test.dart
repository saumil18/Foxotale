// The signed-in header only appears once a property is published, which the
// seeded repository never is, so the entry-sequence test cannot reach it.
// These pump it directly.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:foxotale/theme/fox_theme.dart';
import 'package:foxotale/widgets/fox_header.dart';

Widget _host({required ThemeData theme}) => MaterialApp(
      theme: theme,
      home: Scaffold(
        appBar: FoxHeader(
          title: 'Good morning',
          subtitle: 'FoxOtale Jaipur · Jaipur',
          trailing: const FoxHeaderBadge(label: 'GM / HM'),
          actions: [
            FoxHeaderAction(
              icon: Icons.logout_outlined,
              tooltip: 'Switch role',
              onPressed: () {},
            ),
          ],
        ),
        body: const SizedBox(),
      ),
    );

void main() {
  for (final (name, theme) in [
    ('light', FoxTheme.light()),
    ('dark', FoxTheme.dark()),
  ]) {
    testWidgets('header renders its lines and chrome in $name', (tester) async {
      await tester.pumpWidget(_host(theme: theme));
      await tester.pumpAndSettle();

      expect(find.text('Good morning'), findsOneWidget);
      expect(find.text('FoxOtale Jaipur · Jaipur'), findsOneWidget);
      expect(find.text('GM / HM'), findsOneWidget);
      expect(find.byTooltip('Switch role'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('header ink stays white on both gradients', (tester) async {
    // The gradient tokens were picked so white clears 5:1 at either end. If
    // someone re-themes the ink to a surface colour, that record stops
    // applying — so the ink is pinned here.
    await tester.pumpWidget(_host(theme: FoxTheme.light()));
    await tester.pumpAndSettle();

    final title = tester.widget<Text>(find.text('Good morning'));
    expect(title.style?.color, const Color(0xFFFFFFFF));
  });
}
