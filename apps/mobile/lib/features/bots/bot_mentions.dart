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

({HermesBotProfile lead, HermesBotProfile target})? _directedMentionPair(
  String text,
  Iterable<HermesBotProfile> mentioned,
) {
  final match = RegExp(
    r'(?:^|\s)@([a-z0-9][a-z0-9_-]*)\s+(?:ask|asks|as|talk(?:s)?\s+(?:to|with)|speak(?:s)?\s+(?:to|with)|chat(?:s)?\s+with)\s+@([a-z0-9][a-z0-9_-]*)\b',
    caseSensitive: false,
  ).firstMatch(_proseWithoutCode(text));
  if (match == null) return null;
  final byHandle = {for (final bot in mentioned) bot.handle.toLowerCase(): bot};
  final lead = byHandle[(match.group(1) ?? '').toLowerCase()];
  final target = byHandle[(match.group(2) ?? '').toLowerCase()];
  if (lead == null || target == null || lead.name == target.name) return null;
  return (lead: lead, target: target);
}

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

  final directed = _directedMentionPair(text, mentioned);
  if (directed != null) {
    final lead = directed.lead;
    final target = directed.target;
    return '$text\n\n'
        '[@mention handoff — directed exchange: the user wants @${lead.handle} '
        'to ask @${target.handle}, not two independent answers. COMPOSE a '
        'focused question for ${target.displayName}, then a short follow-up '
        'for ${lead.displayName} asking for the final answer after considering '
        '${target.displayName}\'s response. Run exactly this two-stage shell '
        'pipeline in one terminal call with background=true AND '
        'notify_on_complete=true (avoid double quotes in your composed text):\n'
        '`bot_reply=\$(hermes -p ${_shellQuote(target.name)} chat --in ~ '
        '-c "Bot Chat" --create-if-missing -Q -q "Message from 🤖 '
        '${_shellDoubleQuote(senderName)} '
        '(@${_shellDoubleQuote(senderHandle)}), relaying a question from '
        '${_shellDoubleQuote(lead.displayName)} (@${lead.handle}): '
        '<your composed question>"); hermes -p ${_shellQuote(lead.name)} '
        'chat --in ~ -c "Bot Chat" --create-if-missing -Q -q "Message from '
        '🤖 ${_shellDoubleQuote(target.displayName)} (@${target.handle}), '
        'relayed by ${_shellDoubleQuote(senderName)}: \$bot_reply. '
        '<your composed follow-up requesting the final answer>"`\n'
        'After dispatching, tell the user the exchange started and END YOUR '
        'TURN. Do not wait or poll. When the background completion arrives, '
        'relay only the final answer, attributed to ${lead.displayName}.]';
  }

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
