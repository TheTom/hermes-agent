import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hermes_mobile/core/models/hermes_models.dart';
import 'package:hermes_mobile/core/providers.dart';
import 'package:hermes_mobile/features/bots/bot_avatar.dart';
import 'package:hermes_mobile/features/bots/bot_cronjobs_sheet.dart';
import 'package:hermes_mobile/features/bots/bot_group_sheet.dart';
import 'package:hermes_mobile/features/bots/bot_sessions_sheet.dart';
import 'package:hermes_mobile/features/bots/create_bot_sheet.dart';
import 'package:hermes_mobile/features/bots/edit_bot_sheet.dart';
import 'package:hermes_mobile/features/sessions/session_chat_screen.dart';
import 'package:hermes_mobile/l10n/l10n.dart';

/// Server-backed Bot Mode roster.
///
/// The shell only mounts this screen after the gateway advertises Bot Mode.
/// Polling is scoped to the visible tab so hidden navigation does no work.
class BotsScreen extends ConsumerStatefulWidget {
  const BotsScreen({super.key});

  @override
  ConsumerState<BotsScreen> createState() => _BotsScreenState();
}

class _BotsScreenState extends ConsumerState<BotsScreen> {
  Timer? _refreshTimer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (TickerMode.valuesOf(context).enabled) {
      _refreshTimer ??= Timer.periodic(const Duration(seconds: 15), (_) {
        unawaited(ref.read(botsProvider.notifier).refresh());
      });
    } else {
      _refreshTimer?.cancel();
      _refreshTimer = null;
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bots = ref.watch(botsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.botsTitle),
        actions: [
          IconButton(
            tooltip: context.l10n.createBotAction,
            onPressed: _createBot,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: bots.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _BotsError(error: error),
        data: (view) {
          return Column(
            children: [
              if (view.syncError != null)
                Material(
                  color: theme.colorScheme.errorContainer.withValues(
                    alpha: 0.55,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.cloud_off_outlined,
                          size: 18,
                          color: theme.colorScheme.onErrorContainer,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            context.l10n.botsCachedRoster,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onErrorContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => ref.read(botsProvider.notifier).refresh(),
                  child: view.profiles.isEmpty
                      ? CustomScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          slivers: [
                            SliverFillRemaining(
                              hasScrollBody: false,
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(32),
                                  child: Text(
                                    context.l10n.botsEmpty,
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.65),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : _BotRosterList(profiles: view.profiles),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _createBot() async {
    final existing = ref.read(botsProvider).value?.profiles ?? const [];
    final created = await showCreateBotSheet(
      context,
      existingNames: {for (final bot in existing) bot.name},
    );
    if (!mounted || created == null) return;
    await ref.read(botsProvider.notifier).refresh();
    if (!mounted) return;
    await _openBotChat(context, ref, created);
  }
}

class BotRosterSection {
  const BotRosterSection({required this.group, required this.bots});

  final String? group;
  final List<HermesBotProfile> bots;
}

List<BotRosterSection> botRosterSections(List<HermesBotProfile> bots) {
  final ungrouped = <HermesBotProfile>[];
  final grouped = <String, List<HermesBotProfile>>{};
  for (final bot in bots) {
    final group = bot.group?.trim() ?? '';
    if (group.isEmpty) {
      ungrouped.add(bot);
    } else {
      grouped.putIfAbsent(group, () => []).add(bot);
    }
  }
  final names = grouped.keys.toList()
    ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  return [
    if (ungrouped.isNotEmpty) BotRosterSection(group: null, bots: ungrouped),
    for (final name in names)
      BotRosterSection(group: name, bots: grouped[name]!),
  ];
}

class _BotRosterList extends StatelessWidget {
  const _BotRosterList({required this.profiles});

  final List<HermesBotProfile> profiles;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final children = <Widget>[];
    for (final section in botRosterSections(profiles)) {
      if (section.group != null) {
        children.add(
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 4),
            child: Row(
              children: [
                Text(
                  section.group!.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Divider(
                    color: theme.colorScheme.primary.withValues(alpha: 0.35),
                  ),
                ),
              ],
            ),
          ),
        );
      }
      for (var index = 0; index < section.bots.length; index++) {
        children.add(_BotTile(bot: section.bots[index]));
        if (index < section.bots.length - 1) {
          children.add(const Divider(height: 1, indent: 76));
        }
      }
    }
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: children,
    );
  }
}

class _BotsError extends ConsumerWidget {
  const _BotsError({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$error', textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => ref.read(botsProvider.notifier).refresh(),
              child: Text(context.l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}

class _BotTile extends ConsumerWidget {
  const _BotTile({required this.bot});

  final HermesBotProfile bot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final last = bot.lastSession;
    final relative = formatSessionRelative(last?.lastActive);
    final preview = last?.preview?.trim();
    final workingSessionIds =
        ref.watch(botWorkingSessionsProvider).value ?? const <String>{};
    final sync = ref.watch(sessionSyncProvider);
    final botSessionIds = <String>{
      if (bot.chatSessionId?.trim().isNotEmpty == true)
        bot.chatSessionId!.trim(),
      if (last?.id.trim().isNotEmpty == true) last!.id.trim(),
    };
    final working = botSessionIds.any((sessionId) {
      final family = sync?.sessionIdFamily(sessionId) ?? {sessionId};
      return family.any(workingSessionIds.contains);
    });
    final subtitle = preview?.isNotEmpty == true
        ? preview!
        : (bot.description?.trim().isNotEmpty == true
              ? bot.description!.trim()
              : context.l10n.botsNoConversation);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      onTap: () => _openBotChat(context, ref, bot),
      onLongPress: () => _editBot(context, ref, bot),
      leading: BotAvatar(bot: bot, working: working),
      title: Row(
        children: [
          Flexible(
            child: Text(
              bot.displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          if (bot.showsHandle) ...[
            const SizedBox(width: 7),
            Text(
              '@${bot.handle}',
              maxLines: 1,
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
          if (bot.pinned) ...[
            const SizedBox(width: 6),
            Icon(Icons.push_pin, size: 15, color: theme.colorScheme.primary),
          ],
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 3),
          Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
          if (relative != null) ...[
            const SizedBox(height: 3),
            Text(
              relative,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
              ),
            ),
          ],
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Sessions',
            onPressed: () => showBotSessionsSheet(context, bot: bot),
            icon: const Icon(Icons.forum_outlined),
          ),
          PopupMenuButton<String>(
            tooltip: 'Bot actions',
            onSelected: (action) {
              switch (action) {
                case 'pin':
                  unawaited(_toggleBotPin(context, ref, bot));
                case 'cronjobs':
                  unawaited(showBotCronjobsSheet(context, bot: bot));
                case 'edit':
                  unawaited(_editBot(context, ref, bot));
                case 'group':
                  unawaited(showBotGroupSheet(context, bot: bot));
                case 'delete':
                  unawaited(_confirmDeleteBot(context, ref, bot));
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'pin',
                child: ListTile(
                  leading: Icon(
                    bot.pinned ? Icons.push_pin : Icons.push_pin_outlined,
                  ),
                  title: Text(bot.pinned ? 'Unpin' : 'Pin to top'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'cronjobs',
                child: ListTile(
                  leading: Icon(Icons.event_repeat_outlined),
                  title: Text('Cronjobs'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem(
                value: 'group',
                child: ListTile(
                  leading: const Icon(Icons.folder_outlined),
                  title: Text(
                    bot.group?.trim().isNotEmpty == true
                        ? 'Group: ${bot.group}'
                        : 'Move to group',
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem(
                value: 'edit',
                child: ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: Text(context.l10n.editBotAction),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              if (!bot.isDefault && bot.name.toLowerCase() != 'default') ...[
                const PopupMenuDivider(),
                PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(
                      Icons.delete_outline,
                      color: theme.colorScheme.error,
                    ),
                    title: Text(
                      'Delete',
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ],
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}

Future<void> _toggleBotPin(
  BuildContext context,
  WidgetRef ref,
  HermesBotProfile bot,
) async {
  try {
    final sync = ref.read(sessionSyncProvider);
    if (sync == null) throw StateError('Gateway is not connected');
    await sync.updateBotPinned(bot, !bot.pinned);
    await ref.read(botsProvider.notifier).refresh();
  } catch (error) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$error')));
  }
}

Future<void> _confirmDeleteBot(
  BuildContext context,
  WidgetRef ref,
  HermesBotProfile bot,
) async {
  final confirmed =
      await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Delete bot and profile?'),
          content: Text(
            'This will permanently delete “${bot.displayName}”, its Hermes profile @${bot.handle}, sessions, memory, and skills. This cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(dialogContext).colorScheme.error,
                foregroundColor: Theme.of(dialogContext).colorScheme.onError,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete'),
            ),
          ],
        ),
      ) ??
      false;
  if (!confirmed || !context.mounted) return;
  try {
    final sync = ref.read(sessionSyncProvider);
    if (sync == null) throw StateError('Gateway is not connected');
    await sync.deleteBot(bot);
    await ref.read(botsProvider.notifier).refresh();
  } catch (error) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$error')));
  }
}

Future<void> _editBot(
  BuildContext context,
  WidgetRef ref,
  HermesBotProfile bot,
) async {
  final saved = await showEditBotSheet(context, bot: bot);
  if (!saved || !context.mounted) return;
  await ref.read(botsProvider.notifier).refresh();
}

Future<void> _openBotChat(
  BuildContext context,
  WidgetRef ref,
  HermesBotProfile bot,
) async {
  final sync = ref.read(sessionSyncProvider);
  if (sync == null) return;
  try {
    final target = await sync.openBotChat(bot);
    if (!context.mounted) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) =>
            buildBotChatScreen(session: target.session, profileName: bot.name),
      ),
    );
    if (context.mounted) {
      unawaited(ref.read(botsProvider.notifier).refresh());
    }
  } catch (error) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$error')));
  }
}

SessionChatScreen buildBotChatScreen({
  required HermesSession session,
  required String profileName,
}) {
  return SessionChatScreen(session: session, profileName: profileName);
}
