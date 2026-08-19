import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hermes_mobile/core/models/hermes_models.dart';
import 'package:hermes_mobile/features/sessions/chat_composer.dart';
import 'package:hermes_mobile/l10n/l10n.dart';

/// Regression coverage for the "composer locks up mid-stream" bug: the text
/// field must stay editable and must not lose/clobber a draft while
/// `sending` is true, and the draft must survive the flag flipping back to
/// false when the turn completes.
Future<void> _pump(
  WidgetTester tester, {
  required TextEditingController controller,
  required bool sending,
  VoidCallback? onStop,
  List<HermesBotProfile> botMentions = const [],
}) {
  return tester.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      supportedLocales: supportedAppLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(
        body: ChatComposerBar(
          controller: controller,
          onSend: () {},
          onStop: onStop,
          sending: sending,
          botMentions: botMentions,
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('text field stays enabled and editable while sending is true', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await _pump(tester, controller: controller, sending: true);

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(
      field.enabled,
      isTrue,
      reason: 'the composer must stay typeable through the whole agent turn',
    );

    await tester.enterText(find.byType(TextField), 'still typing mid-stream');
    await tester.pump();
    expect(controller.text, 'still typing mid-stream');
  });

  testWidgets(
    'a draft typed while sending survives the turn completing (sending '
    'flips back to false)',
    (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await _pump(tester, controller: controller, sending: true);
      await tester.enterText(find.byType(TextField), 'my next question');
      await tester.pump();
      expect(controller.text, 'my next question');

      // Turn completes — parent flips `sending` back to false. Rebuilding
      // the composer must not clear or alter the controller's text; only
      // an explicit send should ever do that.
      await _pump(tester, controller: controller, sending: false);
      expect(controller.text, 'my next question');

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.enabled, isTrue);
    },
  );

  testWidgets('send action is still gated while sending — stop replaces it', (
    tester,
  ) async {
    var stopped = false;
    final controller = TextEditingController(text: 'hello');
    addTearDown(controller.dispose);

    await _pump(
      tester,
      controller: controller,
      sending: true,
      onStop: () => stopped = true,
    );

    // No upward-arrow send button while sending — it's replaced by stop.
    expect(find.byIcon(Icons.arrow_upward), findsNothing);
    expect(find.byIcon(Icons.stop_rounded), findsOneWidget);

    await tester.tap(find.byIcon(Icons.stop_rounded));
    await tester.pump();
    expect(stopped, isTrue);
  });

  testWidgets('send button is enabled once not sending and there is text', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'hi');
    addTearDown(controller.dispose);

    await _pump(tester, controller: controller, sending: false);

    final sendButton = tester.widget<IconButton>(
      find.ancestor(
        of: find.byIcon(Icons.arrow_upward),
        matching: find.byType(IconButton),
      ),
    );
    expect(sendButton.onPressed, isNotNull);
  });

  testWidgets('a tap outside the composer dismisses the keyboard', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await _pump(tester, controller: controller, sending: false);
    await tester.tap(find.byType(TextField));
    await tester.pump();
    expect(
      tester.widget<EditableText>(find.byType(EditableText)).focusNode.hasFocus,
      isTrue,
    );

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.onTapOutside, isNotNull);
    field.onTapOutside!(const PointerDownEvent());
    await tester.pump();

    expect(
      tester.widget<EditableText>(find.byType(EditableText)).focusNode.hasFocus,
      isFalse,
    );
  });

  testWidgets('typing @ shows bot handles and inserts the selected mention', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    final techno = HermesBotProfile.fromJson({
      'name': 'techno',
      'ui_meta': {
        'hermes-bots': {'title': 'Senior cat wrangler'},
      },
    });

    await _pump(
      tester,
      controller: controller,
      sending: false,
      botMentions: [techno],
    );
    await tester.enterText(find.byType(TextField), 'Ask @te');
    await tester.pump();

    expect(find.text('Senior cat wrangler'), findsOneWidget);
    expect(find.text('@techno'), findsOneWidget);
    await tester.tap(find.text('@techno'));
    await tester.pump();
    expect(controller.text, 'Ask @techno ');
  });

  testWidgets('the composer can insert multiple bot mentions in one prompt', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    HermesBotProfile bot(String name, String title) =>
        HermesBotProfile.fromJson({
          'name': name,
          'ui_meta': {
            'hermes-bots': {'title': title},
          },
        });

    await _pump(
      tester,
      controller: controller,
      sending: false,
      botMentions: [
        bot('techno', 'Senior cat wrangler'),
        bot('coach', 'Fitness Coach'),
      ],
    );
    await tester.enterText(find.byType(TextField), '@te');
    await tester.pump();
    await tester.tap(find.text('@techno'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), '@techno ask @co');
    await tester.pump();
    await tester.tap(find.text('@coach'));
    await tester.pump();

    expect(controller.text, '@techno ask @coach ');
  });
}
