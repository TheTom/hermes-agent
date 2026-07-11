import 'package:flutter/material.dart';

import 'package:hermes_mobile/core/services/slash_commands.dart';
import 'package:hermes_mobile/l10n/l10n.dart';

/// Animated pill around the composer row: idle / slash match / listening glow.
///
/// The [pulse] animation value is the idle→listening blend (0..1). Layout is
/// stable — border and shadow paint without shifting the 40×40 icon midline.
class ComposerInputShell extends StatelessWidget {
  const ComposerInputShell({
    super.key,
    required this.pulse,
    required this.matchedSlash,
    required this.child,
  });

  final Animation<double> pulse;
  final String? matchedSlash;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: pulse,
      builder: (context, inner) {
        // t: 0 = idle/slash chrome, 1 = full listening glow.
        final t = Curves.easeInOut.transform(pulse.value);
        final primary = theme.colorScheme.primary;
        final idleBorderColor = matchedSlash != null
            ? primary.withValues(alpha: 0.75)
            : theme.colorScheme.outline.withValues(alpha: 0.4);
        final idleWidth = matchedSlash != null ? 1.5 : 1.0;
        final fill = theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.65,
        );
        return DecoratedBox(
          decoration: BoxDecoration(
            color: t == 0
                ? fill
                : Color.alphaBlend(primary.withValues(alpha: 0.06 * t), fill),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Color.lerp(idleBorderColor, primary, t)!,
              width: idleWidth + (2.0 - idleWidth) * t,
            ),
            boxShadow: t == 0
                ? null
                : [
                    BoxShadow(
                      color: primary.withValues(alpha: 0.28 * t),
                      blurRadius: 18 * t,
                      spreadRadius: 2.5 * t,
                    ),
                  ],
          ),
          child: inner,
        );
      },
      child: child,
    );
  }
}

/// Desktop-style chip shown when the field holds a recognized slash command.
class ComposerSlashChip extends StatelessWidget {
  const ComposerSlashChip({super.key, required this.matchedSlash});

  final String matchedSlash;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final skill = isSkillSlashName(matchedSlash);
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 2, 8, 4),
      child: Row(
        children: [
          Icon(
            skill ? Icons.extension : Icons.terminal,
            size: 14,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 6),
          Text(
            matchedSlash,
            style: theme.textTheme.labelLarge?.copyWith(
              fontFamily: 'monospace',
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            skill
                ? L10n.current.skillsSection.toLowerCase()
                : L10n.current.commandsSection.toLowerCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.primary.withValues(alpha: 0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Shimmering "Listening" label over an empty field during dictation.
class ComposerListeningHint extends StatelessWidget {
  const ComposerListeningHint({super.key, required this.pulse});

  final Animation<double> pulse;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return IgnorePointer(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: AnimatedBuilder(
          animation: pulse,
          builder: (context, _) {
            final t = Curves.easeInOut.transform(pulse.value);
            return Text(
              context.l10n.listening,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.25,
                color: theme.colorScheme.primary.withValues(
                  alpha: 0.45 + 0.4 * t,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
