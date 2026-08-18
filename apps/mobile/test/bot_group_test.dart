import 'package:flutter_test/flutter_test.dart';

import 'package:hermes_mobile/core/models/hermes_models.dart';
import 'package:hermes_mobile/features/bots/bots_screen.dart';
import 'package:hermes_mobile/core/providers.dart';

HermesBotProfile _bot(String name, {String? group, List<String>? groups}) {
  return HermesBotProfile.fromJson({
    'name': name,
    'ui_meta': {
      'hermes-bots': {'title': name, 'group': ?group, 'groups': ?groups},
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

  test('one bot can be seated in multiple independent group chats', () {
    final shared = _bot('shared', groups: ['First', 'Second']);
    final firstOnly = _bot('first-only', groups: ['First']);
    final secondOnly = _bot('second-only');
    final secondRoom = HermesBotGroupRoom.fromJson('Second', {
      'members': [
        {'name': 'shared'},
        {'name': 'second-only'},
      ],
    });

    final groups = botGroupEntries(
      [shared, firstOnly, secondOnly],
      {'Second': secondRoom},
    );

    expect(groups.map((entry) => entry.group), ['First', 'Second']);
    expect(groups[0].bots.map((bot) => bot.name), ['shared', 'first-only']);
    expect(groups[1].bots.map((bot) => bot.name), ['shared', 'second-only']);
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
    var sessionsOpened = false;
    final screen = buildBotChatScreen(
      session: HermesSession(id: 'new-bot-chat'),
      profileName: 'fitness-coach',
      onOpenSessions: () => sessionsOpened = true,
    );

    expect(screen.initialMessage, isNull);
    expect(screen.onOpenBotSessions, isNotNull);
    screen.onOpenBotSessions!();
    expect(sessionsOpened, isTrue);
  });
}
