import 'package:flutter/services.dart';

import 'package:hermes_mobile/core/models/hermes_models.dart';

/// The @token currently being edited at [TextEditingValue.selection].
class BotMentionToken {
  const BotMentionToken({
    required this.start,
    required this.end,
    required this.query,
  });

  final int start;
  final int end;
  final String query;
}

BotMentionToken? botMentionTokenAt(TextEditingValue value) {
  final caret = value.selection.baseOffset;
  if (!value.selection.isCollapsed || caret < 0 || caret > value.text.length) {
    return null;
  }
  final prefix = value.text.substring(0, caret);
  final match = RegExp(
    r'(^|\s)@([a-z0-9_-]*)$',
    caseSensitive: false,
  ).firstMatch(prefix);
  if (match == null) return null;
  final at = prefix.lastIndexOf('@');
  if (at < 0) return null;
  return BotMentionToken(start: at, end: caret, query: match.group(2) ?? '');
}

List<HermesBotProfile> botMentionSuggestions(
  TextEditingValue value,
  Iterable<HermesBotProfile> roster, {
  String activeProfile = 'default',
}) {
  final token = botMentionTokenAt(value);
  if (token == null) return const [];
  final query = token.query.toLowerCase();
  final active = activeProfile.trim().toLowerCase();
  final matches = roster.where((bot) {
    if (!bot.belongsInBotRoster || bot.name.trim().toLowerCase() == active) {
      return false;
    }
    final handle = bot.handle.toLowerCase();
    final title = bot.displayName.toLowerCase();
    return query.isEmpty || handle.startsWith(query) || title.contains(query);
  }).toList();
  matches.sort((a, b) {
    final handle = a.handle.toLowerCase().compareTo(b.handle.toLowerCase());
    return handle != 0 ? handle : a.displayName.compareTo(b.displayName);
  });
  return matches;
}

String _proseWithoutCode(String text) => text
    .replaceAll(RegExp(r'```[\s\S]*?```'), ' ')
    .replaceAll(RegExp(r'`[^`\n]*`'), ' ');

List<HermesBotProfile> resolveBotMentions(
  String text,
  Iterable<HermesBotProfile> roster, {
  String activeProfile = 'default',
}) {
  final byHandle = <String, HermesBotProfile>{};
  final active = activeProfile.trim().toLowerCase();
  for (final bot in roster) {
    if (!bot.belongsInBotRoster || bot.name.trim().toLowerCase() == active) {
      continue;
    }
    byHandle.putIfAbsent(bot.handle.toLowerCase(), () => bot);
  }

  final found = <HermesBotProfile>[];
  final seen = <String>{};
  for (final match in RegExp(
    r'(^|\s)@([a-z0-9][a-z0-9_-]*)',
    caseSensitive: false,
    multiLine: true,
  ).allMatches(_proseWithoutCode(text))) {
    final handle = (match.group(2) ?? '').toLowerCase();
    final bot = byHandle[handle];
    if (bot != null && seen.add(bot.name.toLowerCase())) found.add(bot);
  }
  return found;
}

String _shellQuote(String value) => "'${value.replaceAll("'", "'\"'\"'")}'";

String _shellDoubleQuote(String value) => value
    .replaceAll(r'\', r'\\')
    .replaceAll('"', r'\"')
    .replaceAll(r'$', r'\$')
    .replaceAll('`', r'\`');

/// Mirrors Desktop Bot Mode's mention middleware.
///
/// The active agent receives one asynchronous handoff recipe per mentioned
/// local profile. Unknown handles, email addresses, code spans, and the active
/// profile itself remain ordinary text.
String appendBotMentionHandoff({
  required String text,
  required Iterable<HermesBotProfile> roster,
  required String activeProfile,
  required String senderName,
  required String senderHandle,
}) {
  final mentioned = resolveBotMentions(
    text,
    roster,
    activeProfile: activeProfile,
  );
  if (mentioned.isEmpty) return text;

  final handles = mentioned.map((bot) => bot.handle).join(', ');
  final commands = mentioned.map(
    (bot) =>
        '`hermes -p ${_shellQuote(bot.name)} chat --in ~ -c "Bot Chat" '
        '--create-if-missing -Q -q "Message from 🤖 '
        '${_shellDoubleQuote(senderName)} '
        '(@${_shellDoubleQuote(senderHandle)}): <your composed message>"`',
  );
  return '$text\n\n'
      '[@mention handoff — for each mentioned agent ($handles): COMPOSE a '
      'message from you ($senderName) to that agent conveying what the user '
      'wants — do not forward this text verbatim (avoid double quotes in your '
      'composed message). Send it with exactly one terminal call, run with '
      'background=true AND notify_on_complete=true (the recipient may take '
      'minutes; the user must not be blocked):\n'
      '${commands.join('\n')}\n'
      'After dispatching, tell the user the message was sent and END YOUR TURN '
      '— do not wait or poll; when the background process completes, its '
      'notification carries the reply — relay it then, attributed to that '
      'agent. Relay the reply back to the user, attributed to that agent.]';
}

/// Hide Bot Mode's model-facing routing suffix from mobile bubbles/actions.
String stripBotMentionHandoff(String text) {
  final marker = text.indexOf('\n\n[@mention handoff —');
  return marker < 0 ? text : text.substring(0, marker).trimRight();
}

/// Gateway background completions are model-facing continuation turns, not
/// messages authored by the user. Keep their command output/session IDs out
/// of the transcript while retaining the assistant's attributed summary.
bool isInternalBackgroundCompletion(HermesMessage message) =>
    message.role == 'user' &&
    (message.content ?? '').trimLeft().startsWith(
      '[IMPORTANT: Background process proc_',
    );
