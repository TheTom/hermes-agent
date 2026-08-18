import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hermes_mobile/core/models/hermes_models.dart';
import 'package:hermes_mobile/core/providers.dart';

Future<void> showBotGroupChatSheet(
  BuildContext context, {
  required String group,
  required List<HermesBotProfile> members,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _BotGroupChatSheet(group: group, members: members),
  );
}

class _BotGroupChatSheet extends ConsumerWidget {
  const _BotGroupChatSheet({required this.group, required this.members});

  final String group;
  final List<HermesBotProfile> members;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final room = ref.watch(botsProvider).value?.groupRooms[group];
    final messages = room?.messages ?? const <HermesBotGroupMessage>[];
    final memberNames = members.map((member) => member.displayName).join(', ');

    return SafeArea(
      child: FractionallySizedBox(
        heightFactor: 0.86,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(group, style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 4),
                  Text(
                    memberNames,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => ref.read(botsProvider.notifier).refresh(),
                child: messages.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(28),
                        children: [
                          const SizedBox(height: 80),
                          Icon(
                            Icons.forum_outlined,
                            size: 42,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.4,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'No synced group messages yet',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Open this group in Hermes Desktop once to migrate its existing room history to the gateway.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                        itemCount: messages.length,
                        itemBuilder: (context, index) =>
                            _GroupMessageBubble(message: messages[index]),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
              child: Text(
                'Group history is synced through your authenticated Hermes gateway.',
                textAlign: TextAlign.center,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupMessageBubble extends StatelessWidget {
  const _GroupMessageBubble({required this.message});

  final HermesBotGroupMessage message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUser = message.isUser;
    final source = message.source?.trim();
    final sender = source?.isNotEmpty == true
        ? '${message.name} · $source'
        : message.name;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: isUser
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              sender,
              style: theme.textTheme.labelMedium?.copyWith(
                color: isUser
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message.text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isUser
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
