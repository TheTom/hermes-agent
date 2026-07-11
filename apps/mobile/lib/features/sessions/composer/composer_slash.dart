import 'dart:async';

import 'package:flutter/material.dart';

import 'package:hermes_mobile/core/services/feedback.dart';
import 'package:hermes_mobile/core/services/slash_commands.dart';
import 'package:hermes_mobile/l10n/l10n.dart';

/// Live gateway slash completer injected by the parent screen.
typedef SlashCompleter = Future<List<SlashCompletion>> Function(String text);

/// Debounced slash completion + matched-command badge for the composer.
class ComposerSlashController {
  ComposerSlashController({required this.onChanged});

  /// Called when the panel or matched slash chip should rebuild.
  final VoidCallback onChanged;

  List<SlashCompletion> items = const [];
  var loading = false;
  String? matchedSlash;

  Timer? _debounce;
  var _gen = 0;
  final Set<String> _knownSlashNames = {...kKnownBuiltinSlashNames};

  bool get hasPanel => items.isNotEmpty || loading;

  void dispose() {
    _debounce?.cancel();
  }

  void rememberNames(Iterable<SlashCompletion> list) {
    for (final item in list) {
      final n = parseSlashCommand(item.text).name.toLowerCase();
      if (n.isNotEmpty) _knownSlashNames.add(n);
    }
  }

  bool isKnownCommand(String name) {
    final n = name.toLowerCase().trim();
    if (n.isEmpty) return false;
    return _knownSlashNames.contains(n) || kKnownBuiltinSlashNames.contains(n);
  }

  void syncMatchedSlash(String text) {
    String? next;
    if (looksLikeSlashCommand(text)) {
      final parsed = parseSlashCommand(text.trim());
      if (parsed.name.isNotEmpty && isKnownCommand(parsed.name)) {
        next = '/${parsed.name}';
      }
    }
    if (next != matchedSlash) {
      matchedSlash = next;
    }
  }

  void dismiss({bool clearMatch = false, required bool Function() mounted}) {
    _debounce?.cancel();
    _debounce = null;
    _gen++; // invalidate any in-flight fetch
    if (clearMatch) matchedSlash = null;
    if (items.isEmpty && !loading && !clearMatch) {
      if (clearMatch) onChanged();
      return;
    }
    items = const [];
    loading = false;
    onChanged();
  }

  /// React to composer text changes. [setText] is unused (controller-owned).
  void onComposerTextChanged({
    required String text,
    required SlashCompleter? completer,
    required bool Function() mounted,
    required bool Function() stillStartsWithSlash,
  }) {
    syncMatchedSlash(text);

    if (completer == null || !text.startsWith('/') || text.contains('\n')) {
      dismiss(mounted: mounted);
      if (mounted()) onChanged();
      return;
    }

    final trimmed = text.trimLeft();
    final parsed = parseSlashCommand(trimmed);
    final cmd = parsed.name.toLowerCase();
    final inArgs = RegExp(r'^/\S+\s').hasMatch(trimmed);

    if (!inArgs) {
      _debounce?.cancel();
      final gen = ++_gen;
      _debounce = Timer(const Duration(milliseconds: 180), () {
        unawaited(
          _fetch(
            text: text,
            gen: gen,
            completer: completer,
            soft: items.isNotEmpty,
            mounted: mounted,
            stillStartsWithSlash: stillStartsWithSlash,
          ),
        );
      });
      if (mounted()) onChanged();
      return;
    }

    if (isKnownCommand(cmd)) {
      _debounce?.cancel();
      final gen = ++_gen;
      _debounce = Timer(const Duration(milliseconds: 220), () {
        unawaited(
          _fetch(
            text: text,
            gen: gen,
            completer: completer,
            soft: true,
            argsOnly: true,
            mounted: mounted,
            stillStartsWithSlash: stillStartsWithSlash,
          ),
        );
      });
      if (items.isNotEmpty || loading) {
        items = const [];
        loading = false;
        onChanged();
      } else if (mounted()) {
        onChanged();
      }
      return;
    }

    _debounce?.cancel();
    final gen = ++_gen;
    _debounce = Timer(const Duration(milliseconds: 200), () {
      unawaited(
        _fetch(
          text: text,
          gen: gen,
          completer: completer,
          soft: items.isNotEmpty,
          mounted: mounted,
          stillStartsWithSlash: stillStartsWithSlash,
        ),
      );
    });
    if (mounted()) onChanged();
  }

  Future<void> _fetch({
    required String text,
    required int gen,
    required SlashCompleter completer,
    required bool Function() mounted,
    required bool Function() stillStartsWithSlash,
    bool soft = false,
    bool argsOnly = false,
  }) async {
    if (!mounted() || gen != _gen) return;
    if (!soft) {
      loading = true;
      onChanged();
    }
    try {
      final result = await completer(text);
      if (!mounted() || gen != _gen) return;
      if (!stillStartsWithSlash()) {
        items = const [];
        loading = false;
        onChanged();
        return;
      }
      rememberNames(result);
      if (argsOnly && result.isEmpty) {
        items = const [];
        loading = false;
        onChanged();
        return;
      }
      final limit = text.trim() == '/' ? 40 : 24;
      items = result.take(limit).toList();
      loading = false;
      onChanged();
    } catch (e) {
      debugPrint('slash completer error: $e');
      if (!mounted() || gen != _gen) return;
      if (!soft) items = const [];
      loading = false;
      onChanged();
    }
  }

  /// Apply a completion into [controller]. Returns the committed text.
  String apply(SlashCompletion item, TextEditingController controller) {
    hermesHaptic(HapticIntent.selection);
    final t = item.text.startsWith('/') ? item.text : '/${item.text}';
    final name = parseSlashCommand(t).name.toLowerCase();
    if (name.isNotEmpty) _knownSlashNames.add(name);
    final withSpace = t.endsWith(' ') ? t : '$t ';
    matchedSlash = name.isEmpty ? null : '/$name';
    _gen++;
    _debounce?.cancel();
    controller.value = TextEditingValue(
      text: withSpace,
      selection: TextSelection.collapsed(offset: withSpace.length),
    );
    items = const [];
    loading = false;
    onChanged();
    return withSpace;
  }

  List<ComposerSlashRow> get rows {
    final out = <ComposerSlashRow>[];
    String? lastGroup;
    for (final item in items) {
      final g = item.group?.trim().isNotEmpty == true
          ? item.group!
          : (item.isSkill
                ? L10n.current.skillsSection
                : L10n.current.commandsSection);
      if (g != lastGroup) {
        out.add(ComposerSlashRow.header(g));
        lastGroup = g;
      }
      out.add(ComposerSlashRow.item(item));
    }
    return out;
  }
}

class ComposerSlashRow {
  const ComposerSlashRow.header(this.header) : item = null, isHeader = true;
  const ComposerSlashRow.item(this.item) : header = null, isHeader = false;

  final bool isHeader;
  final String? header;
  final SlashCompletion? item;
}

/// Floating completion list above the composer pill.
class ComposerSlashPanel extends StatelessWidget {
  const ComposerSlashPanel({
    super.key,
    required this.rows,
    required this.loading,
    required this.emptyItems,
    required this.onSelect,
  });

  final List<ComposerSlashRow> rows;
  final bool loading;
  final bool emptyItems;
  final ValueChanged<SlashCompletion> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      elevation: 3,
      borderRadius: BorderRadius.circular(14),
      color: theme.colorScheme.surfaceContainerHigh,
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: emptyItems ? 48 : 280),
        child: loading && emptyItems
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 4),
                itemCount: rows.length,
                itemBuilder: (context, i) {
                  final row = rows[i];
                  if (row.isHeader) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(14, 10, 14, 2),
                      child: Text(
                        row.header!,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.45,
                          ),
                        ),
                      ),
                    );
                  }
                  final item = row.item!;
                  final label = item.display?.isNotEmpty == true
                      ? item.display!
                      : item.text;
                  final skill = item.isSkill;
                  return InkWell(
                    onTap: () => onSelect(item),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            skill ? Icons.extension : Icons.chevron_right,
                            size: 16,
                            color: skill
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface.withValues(
                                    alpha: 0.35,
                                  ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontFamily: 'monospace',
                                    fontWeight: skill
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                    color: skill
                                        ? theme.colorScheme.primary
                                        : null,
                                  ),
                                ),
                                if (item.meta?.trim().isNotEmpty == true)
                                  Text(
                                    item.meta!.trim(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.5),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
