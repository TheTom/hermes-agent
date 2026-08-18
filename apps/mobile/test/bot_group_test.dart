import 'package:flutter_test/flutter_test.dart';

import 'package:hermes_mobile/core/models/hermes_models.dart';
import 'package:hermes_mobile/features/bots/bots_screen.dart';
import 'package:hermes_mobile/core/providers.dart';

HermesBotProfile _bot(String name, {String? group}) {
  return HermesBotProfile.fromJson({
    'name': name,
    'ui_meta': {
      'hermes-bots': {'title': name, 'group': ?group},
    },
  });
}

void main() {
  test('group chats are additive and do not remove bots from the roster', () {
    final bots = [
      for (var index = 1; index <= 5; index++) _bot('bot-$index'),
      for (var index = 6; index <= 9; index++)
        _bot('bot-$index', group: 'Review team'),
    ];

    final groups = botGroupEntries(bots, const {});

    expect(bots, hasLength(9));
    expect(groups, hasLength(1));
    expect(groups.single.group, 'Review team');
    expect(groups.single.bots.map((bot) => bot.name), [
      'bot-6',
      'bot-7',
      'bot-8',
      'bot-9',
    ]);
  });

  test('synced group rooms remain visible while membership is catching up', () {
    final room = HermesBotGroupRoom.fromJson('Remote room', {
      'messages': const [],
    });

    final groups = botGroupEntries(const [], {'Remote room': room});

    expect(groups, hasLength(1));
    expect(groups.single.group, 'Remote room');
    expect(groups.single.bots, isEmpty);
    expect(groups.single.room, same(room));
  });

  test('session pins keep the requested session at the top', () {
    final recent = HermesSession(id: 'recent', title: 'Recent');
    final older = HermesSession(id: 'older', title: 'Older');

    expect(orderSessionsWithPins([recent, older], ['older']).map((s) => s.id), [
      'older',
      'recent',
    ]);
  });

  test('new bot chats open without an injected starter message', () {
    final screen = buildBotChatScreen(
      session: HermesSession(id: 'new-bot-chat'),
      profileName: 'fitness-coach',
    );

    expect(screen.initialMessage, isNull);
  });
}
