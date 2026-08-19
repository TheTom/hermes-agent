import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hermes_mobile/core/models/hermes_models.dart';
import 'package:hermes_mobile/features/bots/bot_mentions.dart';

HermesBotProfile _bot(String name, {String? title}) {
  return HermesBotProfile.fromJson({
    'name': name,
    'ui_meta': {
      'hermes-bots': {'title': title ?? name},
    },
  });
}

void main() {
  final roster = [
    _bot('default', title: 'Hermes'),
    _bot('techno', title: 'Senior cat wrangler'),
    _bot('coach-helper', title: 'Fitness Coach'),
  ];

  test('suggestions follow the @ token at the caret and omit active bot', () {
    const value = TextEditingValue(
      text: 'ask @te',
      selection: TextSelection.collapsed(offset: 7),
    );
    final results = botMentionSuggestions(value, roster);
    expect(results.map((bot) => bot.handle), ['techno']);
  });

  test('resolver ignores code, unknown handles, email, and active profile', () {
    final results = resolveBotMentions(
      'ask @techno, not `@coach` or me @default or a@b.com\n```@techno```',
      roster,
    );
    expect(results.map((bot) => bot.name), ['techno']);
  });

  test(
    'handoff matches Desktop async dispatch contract and quotes profile',
    () {
      final result = appendBotMentionHandoff(
        text: 'Please ask @coach-helper for today\'s plan',
        roster: roster,
        activeProfile: 'default',
        senderName: 'Hermes',
        senderHandle: 'hermes',
      );

      expect(result, contains('background=true AND notify_on_complete=true'));
      expect(result, contains("-p 'coach-helper'"));
      expect(result, contains('Message from 🤖 Hermes (@hermes)'));
      expect(
        stripBotMentionHandoff(result),
        'Please ask @coach-helper for today\'s plan',
      );
    },
  );

  test('multiple bot mentions produce one independent async route each', () {
    final result = appendBotMentionHandoff(
      text: 'Have @techno and @coach-helper compare approaches',
      roster: roster,
      activeProfile: 'default',
      senderName: 'Hermes',
      senderHandle: 'hermes',
    );

    expect(RegExp(r'`hermes -p ').allMatches(result), hasLength(2));
    expect(result, contains("-p 'techno'"));
    expect(result, contains("-p 'coach-helper'"));
    expect(result, contains('each mentioned agent (techno, coach-helper)'));
  });

  test('unknown mentions leave the prompt byte-identical', () {
    const text = 'email tom@example.com and ask @unknown';
    expect(
      appendBotMentionHandoff(
        text: text,
        roster: roster,
        activeProfile: 'default',
        senderName: 'Hermes',
        senderHandle: 'hermes',
      ),
      text,
    );
  });
}
