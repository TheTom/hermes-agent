import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hermes_mobile/core/models/hermes_models.dart';
import 'package:hermes_mobile/core/providers.dart';

Future<void> showBotGroupSheet(
  BuildContext context, {
  required HermesBotProfile bot,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => _BotGroupSheet(bot: bot),
  );
}

class _BotGroupSheet extends ConsumerStatefulWidget {
  const _BotGroupSheet({required this.bot});

  final HermesBotProfile bot;

  @override
  ConsumerState<_BotGroupSheet> createState() => _BotGroupSheetState();
}

class _BotGroupSheetState extends ConsumerState<_BotGroupSheet> {
  final _name = TextEditingController();
  late final Set<String> _current = {...widget.bot.groups};
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _toggle(String group, bool enabled) async {
    if (_busy) return;
    final sync = ref.read(sessionSyncProvider);
    if (sync == null) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await sync.updateBotGroupMembership(
        widget.bot,
        group,
        enabled,
        currentGroups: _current,
      );
      if (enabled) {
        _current.add(group);
      } else {
        _current.remove(group);
      }
      await ref.read(botsProvider.notifier).refresh();
      if (mounted) {
        _name.clear();
        setState(() => _busy = false);
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = '$error';
      });
    }
  }

  Future<void> _clearAll() async {
    if (_busy) return;
    final sync = ref.read(sessionSyncProvider);
    if (sync == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await sync.updateBotGroup(widget.bot, null);
      _current.clear();
      await ref.read(botsProvider.notifier).refresh();
      if (mounted) setState(() => _busy = false);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = '$error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    final roster = ref.watch(botsProvider).value;
    final profiles = roster?.profiles ?? const [];
    final groups = {
      for (final bot in profiles) ...bot.groups,
      ...?roster?.groupRooms.keys,
    }.toList()..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + bottom),
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Groups', style: theme.textTheme.headlineSmall),
                ),
                TextButton(
                  onPressed: _busy ? null : () => Navigator.pop(context),
                  child: const Text('Done'),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'A bot can join multiple group chats. Toggle each membership independently.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.62),
              ),
            ),
            if (groups.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final group in groups)
                    FilterChip(
                      label: Text(group),
                      selected: _current.contains(group),
                      onSelected: _busy
                          ? null
                          : (selected) => _toggle(group, selected),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _name,
                    enabled: !_busy,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      labelText: groups.isEmpty ? 'Group name' : 'New group',
                      hintText: groups.isEmpty ? 'e.g. Research' : null,
                    ),
                    onSubmitted: (value) {
                      final group = value.trim();
                      if (group.isNotEmpty) _toggle(group, true);
                    },
                    onTapOutside: (_) =>
                        FocusManager.instance.primaryFocus?.unfocus(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _busy
                      ? null
                      : () {
                          final value = _name.text.trim();
                          if (value.isNotEmpty) _toggle(value, true);
                        },
                  child: const Text('Create'),
                ),
              ],
            ),
            if (_current.isNotEmpty) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _busy ? null : _clearAll,
                  icon: const Icon(Icons.folder_off_outlined),
                  label: const Text('Remove from all groups'),
                ),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(
                _error!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
            if (_busy) ...[
              const SizedBox(height: 12),
              const LinearProgressIndicator(),
            ],
          ],
        ),
      ),
    );
  }
}
