import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hermes_mobile/features/sessions/session_chat_screen.dart';
import 'package:hermes_mobile/l10n/l10n.dart';

void main() {
  testWidgets('session title dialog edits and trims the current title', (
    tester,
  ) async {
    String? renamed;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: supportedAppLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                renamed = await showRenameSessionDialog(
                  context,
                  initialTitle: 'Old title',
                );
              },
              child: const Text('Rename'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Rename'));
    await tester.pumpAndSettle();
    expect(find.text('Old title'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '  Fitness review  ');
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(renamed, 'Fitness review');
  });
}
