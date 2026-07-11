import 'package:flutter/material.dart';

import 'package:hermes_mobile/core/services/feedback.dart';
import 'package:hermes_mobile/core/services/slash_commands.dart';
import 'package:hermes_mobile/features/sessions/composer/composer_attachments.dart';
import 'package:hermes_mobile/features/sessions/composer/composer_input_shell.dart';
import 'package:hermes_mobile/features/sessions/composer/composer_mic_controller.dart';
import 'package:hermes_mobile/features/sessions/composer/composer_slash.dart';
import 'package:hermes_mobile/features/sessions/composer/mic_waveform.dart';
import 'package:hermes_mobile/features/sessions/composer/pending_image.dart';
import 'package:hermes_mobile/l10n/l10n.dart';

/// Desktop-parity composer: + attach, mic dictation, send/stop.
///
/// TTS "read replies aloud" is owned by the chat screen (toggle + speaker);
/// this bar only exposes the mic and attachment UX.
class ChatComposerBar extends StatefulWidget {
  const ChatComposerBar({
    super.key,
    required this.controller,
    required this.onSend,
    this.onStop,
    this.sending = false,
    this.hint = '',
    this.enabled = true,
    this.attachments = const [],
    this.onAttachmentsChanged,
    this.readAloud = false,
    this.onReadAloudChanged,
    this.slashCompleter,
    this.onPickSkill,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback? onStop;
  final bool sending;
  final String hint;
  final bool enabled;
  final List<PendingImage> attachments;
  final ValueChanged<List<PendingImage>>? onAttachmentsChanged;
  final bool readAloud;
  final ValueChanged<bool>? onReadAloudChanged;

  /// Live gateway `complete.slash` (+ skills merge) when typing `/…`.
  final Future<List<SlashCompletion>> Function(String text)? slashCompleter;

  /// Opens the skills catalog (parent shows sheet + runs `/{skill}`).
  final VoidCallback? onPickSkill;

  @override
  State<ChatComposerBar> createState() => _ChatComposerBarState();
}

class _ChatComposerBarState extends State<ChatComposerBar>
    with TickerProviderStateMixin {
  late final ComposerMicSession _mic;
  late final ComposerSlashController _slash;
  late final ComposerAttachmentActions _attach;

  @override
  void initState() {
    super.initState();
    _mic = ComposerMicSession(
      vsync: this,
      onChanged: () {
        if (mounted) setState(() {});
      },
      mounted: () => mounted,
      context: () => context,
    );
    _slash = ComposerSlashController(
      onChanged: () {
        if (mounted) setState(() {});
      },
    );
    _attach = ComposerAttachmentActions(
      mounted: () => mounted,
      context: () => context,
    );
    widget.controller.addListener(_onComposerChanged);
  }

  @override
  void didUpdateWidget(covariant ChatComposerBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onComposerChanged);
      widget.controller.addListener(_onComposerChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onComposerChanged);
    _slash.dispose();
    _mic.dispose();
    super.dispose();
  }

  void _onComposerChanged() {
    _slash.onComposerTextChanged(
      text: widget.controller.text,
      completer: widget.slashCompleter,
      mounted: () => mounted,
      stillStartsWithSlash: () => widget.controller.text.startsWith('/'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canSend =
        widget.enabled &&
        !widget.sending &&
        (widget.controller.text.trim().isNotEmpty ||
            widget.attachments.isNotEmpty);
    final listening = _mic.listening;
    final matchedSlash = _slash.matchedSlash;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_slash.hasPanel)
              ComposerSlashPanel(
                rows: _slash.rows,
                loading: _slash.loading,
                emptyItems: _slash.items.isEmpty,
                onSelect: (item) => _slash.apply(item, widget.controller),
              ),
            if (_slash.hasPanel) const SizedBox(height: 8),
            if (widget.attachments.isNotEmpty)
              ComposerAttachmentStrip(
                attachments: widget.attachments,
                sending: widget.sending,
                onRemove: (id) {
                  widget.onAttachmentsChanged?.call(
                    ComposerAttachmentActions.remove(widget.attachments, id),
                  );
                },
              ),
            if (widget.attachments.isNotEmpty) const SizedBox(height: 8),
            ComposerInputShell(
              pulse: _mic.pulseCtrl,
              matchedSlash: matchedSlash,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 6, 6, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (matchedSlash != null)
                      ComposerSlashChip(matchedSlash: matchedSlash),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconButton(
                          tooltip: context.l10n.addContext,
                          style: IconButton.styleFrom(
                            fixedSize: const Size(40, 40),
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: widget.enabled && !widget.sending
                              ? () => _attach.showSheet(
                                  enabled: widget.enabled,
                                  sending: widget.sending,
                                  attachments: widget.attachments,
                                  onChanged: widget.onAttachmentsChanged,
                                  onPickSkill: widget.onPickSkill,
                                )
                              : null,
                          icon: const Icon(Icons.add_circle_outline, size: 24),
                        ),
                        Expanded(
                          child: Stack(
                            alignment: Alignment.centerLeft,
                            children: [
                              TextField(
                                controller: widget.controller,
                                enabled: widget.enabled && !widget.sending,
                                minLines: 1,
                                maxLines: 6,
                                textInputAction: TextInputAction.newline,
                                textAlignVertical: TextAlignVertical.center,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  height: 1.25,
                                  fontWeight: matchedSlash != null
                                      ? FontWeight.w600
                                      : null,
                                  color: matchedSlash != null
                                      ? theme.colorScheme.onSurface
                                      : null,
                                ),
                                decoration: InputDecoration(
                                  hintText: listening ? '' : widget.hint,
                                  hintMaxLines: 1,
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  filled: false,
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 10,
                                  ),
                                ),
                                onChanged: (_) => setState(() {}),
                                onSubmitted: canSend
                                    ? (_) {
                                        _slash.dismiss(mounted: () => mounted);
                                        widget.onSend();
                                      }
                                    : null,
                              ),
                              if (listening && widget.controller.text.isEmpty)
                                ComposerListeningHint(pulse: _mic.pulseCtrl),
                            ],
                          ),
                        ),
                        if (!widget.sending) ...[
                          IconButton(
                            tooltip: listening
                                ? context.l10n.stopDictation
                                : context.l10n.dictate,
                            style: IconButton.styleFrom(
                              fixedSize: const Size(40, 40),
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: widget.enabled
                                ? () => _mic.toggle(
                                    enabled: widget.enabled,
                                    sending: widget.sending,
                                    textController: widget.controller,
                                  )
                                : null,
                            icon: listening
                                ? MicWaveform(
                                    wave: _mic.waveCtrl,
                                    level: _mic.soundLevel,
                                    color: theme.colorScheme.primary,
                                  )
                                : AnimatedBuilder(
                                    animation: _mic.pulseCtrl,
                                    builder: (context, _) {
                                      final t = Curves.easeInOut.transform(
                                        _mic.pulseCtrl.value,
                                      );
                                      return Icon(
                                        Icons.mic_none,
                                        size: 24,
                                        color: t == 0
                                            ? null
                                            : Color.lerp(
                                                theme.colorScheme.onSurface
                                                    .withValues(alpha: 0.8),
                                                theme.colorScheme.primary,
                                                t,
                                              ),
                                      );
                                    },
                                  ),
                          ),
                          if (widget.onReadAloudChanged != null)
                            IconButton(
                              tooltip: widget.readAloud
                                  ? context.l10n.readAloudOn
                                  : context.l10n.readAloudOff,
                              style: IconButton.styleFrom(
                                fixedSize: const Size(40, 40),
                                padding: EdgeInsets.zero,
                                visualDensity: VisualDensity.compact,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              onPressed: () {
                                hermesHaptic(HapticIntent.selection);
                                widget.onReadAloudChanged!(!widget.readAloud);
                              },
                              icon: Icon(
                                widget.readAloud
                                    ? Icons.volume_up
                                    : Icons.volume_off_outlined,
                                size: 22,
                                color: widget.readAloud
                                    ? theme.colorScheme.primary
                                    : null,
                              ),
                            ),
                        ],
                        widget.sending
                            ? IconButton.filled(
                                tooltip: context.l10n.stop,
                                style: IconButton.styleFrom(
                                  fixedSize: const Size(40, 40),
                                  padding: EdgeInsets.zero,
                                  visualDensity: VisualDensity.compact,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  backgroundColor: theme.colorScheme.error,
                                  foregroundColor: theme.colorScheme.onError,
                                ),
                                onPressed: widget.onStop,
                                icon: const Icon(Icons.stop_rounded, size: 22),
                              )
                            : IconButton.filled(
                                style: IconButton.styleFrom(
                                  fixedSize: const Size(40, 40),
                                  padding: EdgeInsets.zero,
                                  visualDensity: VisualDensity.compact,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  backgroundColor: theme.colorScheme.onSurface
                                      .withValues(alpha: canSend ? 0.92 : 0.3),
                                  foregroundColor:
                                      theme.scaffoldBackgroundColor,
                                  disabledBackgroundColor: theme
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.2),
                                ),
                                onPressed: canSend ? widget.onSend : null,
                                icon: const Icon(Icons.arrow_upward, size: 20),
                              ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
