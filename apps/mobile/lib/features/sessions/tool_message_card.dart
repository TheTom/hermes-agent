import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:hermes_mobile/core/models/hermes_models.dart';

class ToolMessagePresentation {
  const ToolMessagePresentation({
    required this.title,
    required this.summary,
    this.details,
  });

  final String title;
  final String summary;
  final String? details;
}

Map<String, dynamic> _toolArguments(dynamic toolCalls) {
  if (toolCalls is! Map) return const {};
  final map = toolCalls.cast<dynamic, dynamic>();
  final nested = map['args'];
  final source = nested is Map ? nested : map;
  return {
    for (final entry in source.entries)
      if (entry.key != null) '${entry.key}': entry.value,
  };
}

String _textArg(Map<String, dynamic> args, String key) {
  final value = args[key];
  return value == null ? '' : '$value'.trim();
}

String _quoted(String value) => value.isEmpty ? '' : '“$value”';

String _friendlyToolName(String raw) {
  if (raw.trim().isEmpty) return 'Tool';
  final words = raw.trim().replaceAll(RegExp(r'[_-]+'), ' ').split(' ');
  final label = words.where((word) => word.isNotEmpty).join(' ');
  if (label.isEmpty) return 'Tool';
  return '${label[0].toUpperCase()}${label.substring(1)}';
}

ToolMessagePresentation presentToolMessage(HermesMessage message) {
  final name = (message.toolName ?? 'tool').trim();
  final args = _toolArguments(message.toolCalls);
  final context = (message.content ?? '').trim();
  late final String title;
  late final String summary;

  switch (name) {
    case 'skill_view':
      title = 'Skill';
      final skill = _textArg(args, 'name');
      summary = skill.isNotEmpty
          ? 'Opened the ${_quoted(skill)} skill'
          : (context.isNotEmpty ? 'Opened $context' : 'Opened a skill');
    case 'tool_search':
      title = 'Tool search';
      final query = _textArg(args, 'query');
      summary = query.isNotEmpty
          ? 'Searched tools for ${_quoted(query)}'
          : (context.isNotEmpty
                ? 'Searched tools for $context'
                : 'Searched available tools');
    case 'terminal':
      title = 'Terminal';
      final command = _textArg(args, 'command').isNotEmpty
          ? _textArg(args, 'command')
          : _textArg(args, 'cmd');
      summary = command.isNotEmpty
          ? 'Ran ${_quoted(command)}'
          : (context.isNotEmpty ? 'Ran $context' : 'Ran a terminal command');
    case 'apple_health_status':
      title = 'Apple Health';
      summary = 'Checked Apple Health availability';
    case 'apple_health_summary':
      title = 'Apple Health';
      final metrics = _textArg(args, 'metrics');
      summary = metrics.isNotEmpty
          ? 'Read $metrics health data'
          : (context.isNotEmpty
                ? 'Read $context'
                : 'Read an Apple Health summary');
    default:
      title = _friendlyToolName(name);
      summary = context.isNotEmpty ? context : 'Completed tool call';
  }

  String? details;
  if (args.isNotEmpty) {
    const encoder = JsonEncoder.withIndent('  ');
    try {
      details = encoder.convert(args);
    } catch (_) {
      details = '$args';
    }
  }
  return ToolMessagePresentation(
    title: title,
    summary: summary,
    details: details,
  );
}

class ToolMessageContent extends StatefulWidget {
  const ToolMessageContent({super.key, required this.message});

  final HermesMessage message;

  @override
  State<ToolMessageContent> createState() => _ToolMessageContentState();
}

class _ToolMessageContentState extends State<ToolMessageContent> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final presentation = presentToolMessage(widget.message);
    final hasDetails = presentation.details?.isNotEmpty ?? false;
    final hasLongSummary =
        presentation.summary.length > 120 ||
        presentation.summary.contains('\n');
    final canExpand = hasDetails || hasLongSummary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: canExpand
              ? () => setState(() => _expanded = !_expanded)
              : null,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.build_circle_outlined,
                  size: 16,
                  color: theme.colorScheme.secondary,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    presentation.title,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.secondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (canExpand) ...[
                  const SizedBox(width: 4),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 160),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      size: 18,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          presentation.summary,
          maxLines: _expanded ? null : 2,
          overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: SelectableText(
              presentation.details ?? '',
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          crossFadeState: _expanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 160),
          sizeCurve: Curves.easeOut,
        ),
      ],
    );
  }
}
