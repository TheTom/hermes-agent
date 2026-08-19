import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'package:hermes_mobile/core/services/feedback.dart';
import 'package:hermes_mobile/core/services/slash_commands.dart';
import 'package:hermes_mobile/core/models/hermes_models.dart';
import 'package:hermes_mobile/features/bots/bot_mentions.dart';
import 'package:hermes_mobile/l10n/l10n.dart';

/// Local pending image chip before `image.attach_bytes` on send.
class PendingImage {
  PendingImage({required this.id, required this.bytes, required this.filename});

  final String id;
  final Uint8List bytes;
  final String filename;
}

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
    this.botMentions = const [],
    this.activeProfile = 'default',
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

  /// Live Bot Mode roster used for Desktop-parity @handle completion.
  final List<HermesBotProfile> botMentions;

  /// The profile receiving this prompt; it cannot mention itself.
  final String activeProfile;

  @override
  State<ChatComposerBar> createState() => _ChatComposerBarState();
}

class _ChatComposerBarState extends State<ChatComposerBar> {
  final _picker = ImagePicker();
  final _speech = stt.SpeechToText();
  final _focusNode = FocusNode();
  var _speechReady = false;
  var _listening = false;
  String _dictationBase = '';
  List<SlashCompletion> _slashItems = const [];
  Timer? _slashDebounce;
  var _slashLoading = false;

  /// Bumps on every composer change so in-flight complete.slash can't resurrect
  /// the panel after the user deletes `/`.
  var _slashGen = 0;

  /// Command names (no leading `/`) we've seen from catalog/complete — for
  /// "recognized slash" chrome after the user commits a command.
  final Set<String> _knownSlashNames = {...kKnownBuiltinSlashNames};

  /// Last matched command token for the badge (e.g. `/model`).
  String? _matchedSlash;

  @override
  void initState() {
    super.initState();
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
    _slashDebounce?.cancel();
    unawaited(_speech.stop());
    _focusNode.dispose();
    super.dispose();
  }

  List<HermesBotProfile> get _mentionItems {
    if (_slashItems.isNotEmpty || _slashLoading) return const [];
    return botMentionSuggestions(
      widget.controller.value,
      widget.botMentions,
      activeProfile: widget.activeProfile,
    ).take(8).toList();
  }

  void _applyMention(HermesBotProfile bot) {
    final token = botMentionTokenAt(widget.controller.value);
    if (token == null) return;
    hermesHaptic(HapticIntent.selection);
    final before = widget.controller.text.substring(0, token.start);
    final after = widget.controller.text.substring(token.end);
    final insertion = '@${bot.handle} ';
    final next = '$before$insertion$after';
    widget.controller.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(
        offset: before.length + insertion.length,
      ),
    );
    _focusNode.requestFocus();
  }

  void _rememberNames(Iterable<SlashCompletion> items) {
    for (final item in items) {
      final n = parseSlashCommand(item.text).name.toLowerCase();
      if (n.isNotEmpty) _knownSlashNames.add(n);
    }
  }

  bool _isKnownCommand(String name) {
    final n = name.toLowerCase().trim();
    if (n.isEmpty) return false;
    return _knownSlashNames.contains(n) || kKnownBuiltinSlashNames.contains(n);
  }

  /// Update recognized-slash badge from current text (no setState if unchanged).
  void _syncMatchedSlash(String text) {
    String? next;
    if (looksLikeSlashCommand(text)) {
      final parsed = parseSlashCommand(text.trim());
      if (parsed.name.isNotEmpty && _isKnownCommand(parsed.name)) {
        next = '/${parsed.name}';
      }
    }
    if (next != _matchedSlash) {
      _matchedSlash = next;
    }
  }

  void _dismissSlashPanel({bool clearMatch = false}) {
    _slashDebounce?.cancel();
    _slashDebounce = null;
    _slashGen++; // invalidate any in-flight fetch
    if (clearMatch) _matchedSlash = null;
    if (_slashItems.isEmpty && !_slashLoading && !clearMatch) {
      // Still need setState if match changed via clearMatch path above.
      if (clearMatch) setState(() {});
      return;
    }
    setState(() {
      _slashItems = const [];
      _slashLoading = false;
    });
  }

  void _onComposerChanged() {
    final text = widget.controller.text;
    _syncMatchedSlash(text);

    // Only while the field still starts with `/` (Desktop trigger behavior).
    if (widget.slashCompleter == null ||
        !text.startsWith('/') ||
        text.contains('\n')) {
      _dismissSlashPanel();
      if (mounted) setState(() {});
      return;
    }

    final trimmed = text.trimLeft();
    final parsed = parseSlashCommand(trimmed);
    final cmd = parsed.name.toLowerCase();
    // Args stage = whitespace after the command token (e.g. `/model gpt`).
    final inArgs = RegExp(r'^/\S+\s').hasMatch(trimmed);

    // ── Command-name stage (`/`, `/he`, `/help`) ─────────────────────
    // Always show the picker here — including a 2nd/3rd slash after a prior
    // send or after backspacing out of args.
    if (!inArgs) {
      _slashDebounce?.cancel();
      final gen = ++_slashGen;
      _slashDebounce = Timer(const Duration(milliseconds: 180), () {
        unawaited(_fetchSlash(text, gen, soft: _slashItems.isNotEmpty));
      });
      if (mounted) setState(() {});
      return;
    }

    // ── Args stage (`/help me`, `/model gpt`) ────────────────────────
    // Hide name list (no flicker). Soft-fetch arg options only when known.
    if (_isKnownCommand(cmd)) {
      _slashDebounce?.cancel();
      final gen = ++_slashGen;
      _slashDebounce = Timer(const Duration(milliseconds: 220), () {
        unawaited(_fetchSlash(text, gen, soft: true, argsOnly: true));
      });
      if (_slashItems.isNotEmpty || _slashLoading) {
        setState(() {
          _slashItems = const [];
          _slashLoading = false;
        });
      } else if (mounted) {
        setState(() {});
      }
      return;
    }

    // Unknown `/foo bar` — still try complete.slash (plugins/skills).
    _slashDebounce?.cancel();
    final gen = ++_slashGen;
    _slashDebounce = Timer(const Duration(milliseconds: 200), () {
      unawaited(_fetchSlash(text, gen, soft: _slashItems.isNotEmpty));
    });
    if (mounted) setState(() {});
  }

  Future<void> _fetchSlash(
    String text,
    int gen, {
    bool soft = false,
    bool argsOnly = false,
  }) async {
    final completer = widget.slashCompleter;
    if (completer == null) return;
    if (!mounted || gen != _slashGen) return;
    // Soft = keep previous rows, never show the empty loading shell.
    if (!soft) {
      setState(() => _slashLoading = true);
    }
    try {
      final items = await completer(text);
      if (!mounted || gen != _slashGen) return;
      // User may have deleted `/` while we awaited.
      if (!widget.controller.text.startsWith('/')) {
        setState(() {
          _slashItems = const [];
          _slashLoading = false;
        });
        return;
      }
      _rememberNames(items);
      // Arg stage with nothing useful → keep panel closed (no flash).
      if (argsOnly && items.isEmpty) {
        setState(() {
          _slashItems = const [];
          _slashLoading = false;
        });
        return;
      }
      final limit = text.trim() == '/' ? 40 : 24;
      setState(() {
        _slashItems = items.take(limit).toList();
        _slashLoading = false;
      });
    } catch (e) {
      debugPrint('slash completer error: $e');
      if (!mounted || gen != _slashGen) return;
      setState(() {
        if (!soft) _slashItems = const [];
        _slashLoading = false;
      });
    }
  }

  void _applySlash(SlashCompletion item) {
    hermesHaptic(HapticIntent.selection);
    final t = item.text.startsWith('/') ? item.text : '/${item.text}';
    final name = parseSlashCommand(t).name.toLowerCase();
    if (name.isNotEmpty) _knownSlashNames.add(name);
    // Commands / skills get a trailing space so the user can type args.
    final withSpace = t.endsWith(' ') ? t : '$t ';
    _matchedSlash = name.isEmpty ? null : '/$name';
    // Invalidate pending fetches so the list doesn't pop back open mid-apply.
    _slashGen++;
    _slashDebounce?.cancel();
    widget.controller.value = TextEditingValue(
      text: withSpace,
      selection: TextSelection.collapsed(offset: withSpace.length),
    );
    setState(() {
      _slashItems = const [];
      _slashLoading = false;
    });
  }

  /// Flat list with section headers for group changes (Commands / Skills).
  List<_SlashRow> get _slashRows {
    final rows = <_SlashRow>[];
    String? lastGroup;
    for (final item in _slashItems) {
      final g = item.group?.trim().isNotEmpty == true
          ? item.group!
          : (item.isSkill
                ? L10n.current.skillsSection
                : L10n.current.commandsSection);
      if (g != lastGroup) {
        rows.add(_SlashRow.header(g));
        lastGroup = g;
      }
      rows.add(_SlashRow.item(item));
    }
    return rows;
  }

  Future<void> _ensureSpeech() async {
    if (_speechReady && _speech.isAvailable) return;
    try {
      _speechReady = await _speech.initialize(
        onError: (e) {
          debugPrint('Speech error: ${e.errorMsg} permanent=${e.permanent}');
          if (!mounted) return;
          setState(() => _listening = false);
          // Ignore ephemeral no-match / timeout while dictating — only surface
          // permanent failures (permission, network, etc.).
          final msg = e.errorMsg.toLowerCase();
          final soft =
              msg.contains('no_match') ||
              msg.contains('speech_timeout') ||
              msg.contains('error_no_match') ||
              msg.contains('error_speech_timeout');
          if (!soft) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(context.l10n.dictationFailed(e.errorMsg))),
            );
          }
        },
        onStatus: (status) {
          debugPrint('Speech status: $status');
          if (!mounted) return;
          // Keep UI in sync with the plugin (iOS ends sessions on pause).
          final active = status == 'listening' || _speech.isListening;
          if (_listening != active) {
            setState(() => _listening = active);
          }
        },
      );
    } catch (e) {
      debugPrint('Speech initialize threw: $e');
      _speechReady = false;
    }
    if (!_speechReady && mounted) {
      final perm = await _speech.hasPermission;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            perm
                ? L10n.current.speechUnavailable
                : L10n.current.micPermissionDenied,
          ),
        ),
      );
    }
  }

  Future<void> _toggleMic() async {
    // Dictation writes into the same controller the user can otherwise type
    // into mid-stream — no reason to block it while a turn is in flight.
    if (!widget.enabled) return;

    // Stop if already listening (UI flag or plugin still hot).
    if (_listening || _speech.isListening) {
      hermesHaptic(HapticIntent.crisp);
      try {
        await _speech.stop();
      } catch (_) {}
      if (mounted) setState(() => _listening = false);
      return;
    }

    await _ensureSpeech();
    if (!_speechReady || !_speech.isAvailable) return;

    hermesHaptic(HapticIntent.open);
    _dictationBase = widget.controller.text;

    // Optimistic UI — listen() is Future<void> and does NOT return success.
    if (mounted) setState(() => _listening = true);

    try {
      // Prefer system locale when the plugin lists one.
      String? localeId;
      try {
        final sys = await _speech.systemLocale();
        localeId = sys?.localeId;
      } catch (_) {}

      await _speech.listen(
        onResult: (result) {
          if (!mounted) return;
          final spoken = result.recognizedWords;
          final base = _dictationBase.trimRight();
          final joined = base.isEmpty
              ? spoken
              : (spoken.isEmpty ? base : '$base $spoken');
          widget.controller.value = TextEditingValue(
            text: joined,
            selection: TextSelection.collapsed(offset: joined.length),
          );
          // After a final chunk, fold into base so the next phrase appends.
          if (result.finalResult && spoken.trim().isNotEmpty) {
            _dictationBase = joined;
          }
        },
        listenOptions: stt.SpeechListenOptions(
          partialResults: true,
          // Don't kill the session on a brief silence / no_match.
          cancelOnError: false,
          listenMode: stt.ListenMode.dictation,
          listenFor: const Duration(minutes: 2),
          pauseFor: const Duration(seconds: 5),
          localeId: localeId,
          autoPunctuation: true,
          enableHapticFeedback: true,
        ),
      );

      // Plugin reports actual state after listen() returns.
      if (mounted) {
        final live = _speech.isListening;
        setState(() => _listening = live);
        if (!live) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(L10n.current.couldNotStartDictation)),
          );
        }
      }
    } catch (e) {
      debugPrint(L10n.current.dictationFailed('$e'));
      if (!mounted) return;
      setState(() => _listening = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(L10n.current.dictationFailed('$e'))),
      );
    }
  }

  Future<void> _showAttachSheet() async {
    // Attachments picked mid-stream just wait in `widget.attachments` for
    // the *next* send (mirrors the text draft) — no need to block them.
    if (!widget.enabled) return;
    final choice = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(context.l10n.photoLibrary),
              onTap: () => Navigator.pop(ctx, 'gallery'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(context.l10n.camera),
              onTap: () => Navigator.pop(ctx, 'camera'),
            ),
            ListTile(
              leading: const Icon(Icons.content_paste_go_outlined),
              title: Text(context.l10n.pasteImageFromClipboard),
              onTap: () => Navigator.pop(ctx, 'paste'),
            ),
            if (widget.onPickSkill != null)
              ListTile(
                leading: const Icon(Icons.extension_outlined),
                title: Text(context.l10n.skillsSection),
                subtitle: Text(context.l10n.skillsTitle),
                onTap: () => Navigator.pop(ctx, 'skills'),
              ),
          ],
        ),
      ),
    );
    if (!mounted || choice == null) return;
    hermesHaptic(HapticIntent.selection);
    switch (choice) {
      case 'gallery':
        await _pickImages(ImageSource.gallery);
      case 'camera':
        await _pickImages(ImageSource.camera);
      case 'paste':
        await _pasteImage();
      case 'skills':
        widget.onPickSkill?.call();
    }
  }

  Future<void> _pickImages(ImageSource source) async {
    try {
      if (source == ImageSource.gallery) {
        final files = await _picker.pickMultiImage(
          imageQuality: 85,
          maxWidth: 2048,
          maxHeight: 2048,
        );
        if (files.isEmpty) return;
        final next = [...widget.attachments];
        for (final f in files) {
          final bytes = await f.readAsBytes();
          next.add(
            PendingImage(
              id: 'img_${DateTime.now().microsecondsSinceEpoch}_${next.length}',
              bytes: bytes,
              filename: f.name.isNotEmpty
                  ? f.name
                  : 'image_${next.length + 1}.jpg',
            ),
          );
        }
        hermesHaptic(HapticIntent.success);
        widget.onAttachmentsChanged?.call(next);
      } else {
        final file = await _picker.pickImage(
          source: source,
          imageQuality: 85,
          maxWidth: 2048,
          maxHeight: 2048,
        );
        if (file == null) return;
        final bytes = await file.readAsBytes();
        final next = [
          ...widget.attachments,
          PendingImage(
            id: 'img_${DateTime.now().microsecondsSinceEpoch}',
            bytes: bytes,
            filename: file.name.isNotEmpty ? file.name : 'camera.jpg',
          ),
        ];
        hermesHaptic(HapticIntent.success);
        widget.onAttachmentsChanged?.call(next);
      }
    } catch (e) {
      if (!mounted) return;
      FeedbackService.instance.error();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.couldNotPickImage('$e'))),
      );
    }
  }

  Future<void> _pasteImage() async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      // Flutter clipboard image paste is limited; accept data-URL text.
      final text = data?.text;
      if (text != null && text.startsWith('data:image')) {
        final comma = text.indexOf(',');
        if (comma > 0) {
          final bytes = base64Decode(text.substring(comma + 1));
          final next = [
            ...widget.attachments,
            PendingImage(
              id: 'img_${DateTime.now().microsecondsSinceEpoch}',
              bytes: Uint8List.fromList(bytes),
              filename: 'pasted.png',
            ),
          ];
          widget.onAttachmentsChanged?.call(next);
          return;
        }
      }
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.noImageOnClipboard)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.pasteFailed('$e'))));
    }
  }

  void _removeAttachment(String id) {
    final next = widget.attachments.where((a) => a.id != id).toList();
    widget.onAttachmentsChanged?.call(next);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canSend =
        widget.enabled &&
        !widget.sending &&
        (widget.controller.text.trim().isNotEmpty ||
            widget.attachments.isNotEmpty);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_mentionItems.isNotEmpty)
              Material(
                elevation: 3,
                borderRadius: BorderRadius.circular(14),
                color: theme.colorScheme.surfaceContainerHigh,
                clipBehavior: Clip.antiAlias,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 260),
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: _mentionItems.length,
                    itemBuilder: (context, index) {
                      final bot = _mentionItems[index];
                      final label = bot.displayName.trim();
                      final initial = label.isEmpty
                          ? '?'
                          : label.characters.first.toUpperCase();
                      return InkWell(
                        onTap: () => _applyMention(bot),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 9,
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 15,
                                backgroundColor:
                                    theme.colorScheme.primaryContainer,
                                child: Text(
                                  initial,
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: theme.colorScheme.onPrimaryContainer,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      label.isEmpty ? bot.handle : label,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    Text(
                                      '@${bot.handle}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                            color: theme.colorScheme.primary,
                                            fontFamily: 'monospace',
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
              ),
            if (_mentionItems.isNotEmpty) const SizedBox(height: 8),
            if (_slashItems.isNotEmpty || _slashLoading)
              Material(
                elevation: 3,
                borderRadius: BorderRadius.circular(14),
                color: theme.colorScheme.surfaceContainerHigh,
                clipBehavior: Clip.antiAlias,
                child: ConstrainedBox(
                  // Loading-only is a thin strip; list can grow after results.
                  constraints: BoxConstraints(
                    maxHeight: _slashItems.isEmpty ? 48 : 280,
                  ),
                  child: _slashLoading && _slashItems.isEmpty
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
                      : Builder(
                          builder: (context) {
                            final rows = _slashRows;
                            return ListView.builder(
                              shrinkWrap: true,
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              itemCount: rows.length,
                              itemBuilder: (context, i) {
                                final row = rows[i];
                                if (row.isHeader) {
                                  return Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      14,
                                      10,
                                      14,
                                      2,
                                    ),
                                    child: Text(
                                      row.header!,
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.3,
                                            color: theme.colorScheme.onSurface
                                                .withValues(alpha: 0.45),
                                          ),
                                    ),
                                  );
                                }
                                final item = row.item!;
                                final label = item.display?.isNotEmpty == true
                                    ? item.display!
                                    : item.text;
                                // Desktop: skills render bolder / primary-tinted.
                                final skill = item.isSkill;
                                return InkWell(
                                  onTap: () => _applySlash(item),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          skill
                                              ? Icons.extension
                                              : Icons.chevron_right,
                                          size: 16,
                                          color: skill
                                              ? theme.colorScheme.primary
                                              : theme.colorScheme.onSurface
                                                    .withValues(alpha: 0.35),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                label,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: theme
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      fontFamily: 'monospace',
                                                      fontWeight: skill
                                                          ? FontWeight.w800
                                                          : FontWeight.w600,
                                                      color: skill
                                                          ? theme
                                                                .colorScheme
                                                                .primary
                                                          : null,
                                                    ),
                                              ),
                                              if (item.meta
                                                      ?.trim()
                                                      .isNotEmpty ==
                                                  true)
                                                Text(
                                                  item.meta!.trim(),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: theme
                                                      .textTheme
                                                      .labelSmall
                                                      ?.copyWith(
                                                        color: theme
                                                            .colorScheme
                                                            .onSurface
                                                            .withValues(
                                                              alpha: 0.5,
                                                            ),
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
                            );
                          },
                        ),
                ),
              ),
            if (_slashItems.isNotEmpty || _slashLoading)
              const SizedBox(height: 8),
            if (widget.attachments.isNotEmpty)
              SizedBox(
                height: 72,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.attachments.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final a = widget.attachments[i];
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.memory(
                            a.bytes,
                            width: 72,
                            height: 72,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: -6,
                          right: -6,
                          child: Material(
                            color: theme.colorScheme.surface,
                            shape: const CircleBorder(),
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: () => _removeAttachment(a.id),
                              child: Icon(
                                Icons.cancel,
                                size: 22,
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.75,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            if (widget.attachments.isNotEmpty) const SizedBox(height: 8),
            DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.65,
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: _matchedSlash != null
                      ? theme.colorScheme.primary.withValues(alpha: 0.75)
                      : theme.colorScheme.outline.withValues(alpha: 0.4),
                  width: _matchedSlash != null ? 1.5 : 1,
                ),
              ),
              child: Padding(
                // Symmetric pad so + / mic / send share one optical midline.
                padding: const EdgeInsets.fromLTRB(4, 6, 6, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Recognized slash command chip (Desktop-style affordance).
                    if (_matchedSlash != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 2, 8, 4),
                        child: Row(
                          children: [
                            Icon(
                              isSkillSlashName(_matchedSlash!)
                                  ? Icons.extension
                                  : Icons.terminal,
                              size: 14,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _matchedSlash!,
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.w800,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isSkillSlashName(_matchedSlash!)
                                  ? L10n.current.skillsSection.toLowerCase()
                                  : L10n.current.commandsSection.toLowerCase(),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.7,
                                ),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    Row(
                      // Center (not end) — end sat +/mic on the floor of the
                      // tall TextField padding so they looked too low.
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
                          onPressed: widget.enabled ? _showAttachSheet : null,
                          icon: const Icon(Icons.add_circle_outline, size: 24),
                        ),
                        Expanded(
                          child: TextField(
                            controller: widget.controller,
                            focusNode: _focusNode,
                            // Stays editable through the whole agent turn —
                            // only the send *action* is gated on `sending`
                            // (see the trailing button below). Users can
                            // keep composing their next message while the
                            // reply streams in, same as Desktop/Claude/GPT.
                            enabled: widget.enabled,
                            minLines: 1,
                            maxLines: 6,
                            textInputAction: TextInputAction.newline,
                            textAlignVertical: TextAlignVertical.center,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              height: 1.25,
                              fontWeight: _matchedSlash != null
                                  ? FontWeight.w600
                                  : null,
                              color: _matchedSlash != null
                                  ? theme.colorScheme.onSurface
                                  : null,
                            ),
                            decoration: InputDecoration(
                              hintText: _listening
                                  ? context.l10n.listening
                                  : widget.hint,
                              // Prevent "Message Hermes Go…" wrapping under +.
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
                            // iOS intentionally does not unfocus a TextField
                            // for touch pointers by default. Bot chats expose
                            // this especially clearly because the composer can
                            // fill the only easy dismissal area. Treat any tap
                            // outside the field as an explicit keyboard close;
                            // TapRegion preserves buttons, links, selection,
                            // and message gestures while doing so.
                            onTapOutside: (_) =>
                                FocusManager.instance.primaryFocus?.unfocus(),
                            onChanged: (_) => setState(() {}),
                            onSubmitted: canSend
                                ? (_) {
                                    _dismissSlashPanel();
                                    widget.onSend();
                                  }
                                : null,
                          ),
                        ),
                        // While generating, only show Stop — free width + less
                        // chrome (mic/speaker do nothing useful mid-turn).
                        if (!widget.sending) ...[
                          IconButton(
                            tooltip: _listening
                                ? context.l10n.stopDictation
                                : context.l10n.dictate,
                            style: IconButton.styleFrom(
                              fixedSize: const Size(40, 40),
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: widget.enabled ? _toggleMic : null,
                            icon: Icon(
                              _listening ? Icons.mic : Icons.mic_none,
                              size: 24,
                              color: _listening
                                  ? theme.colorScheme.error
                                  : null,
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

class _SlashRow {
  const _SlashRow.header(this.header) : item = null, isHeader = true;
  const _SlashRow.item(this.item) : header = null, isHeader = false;

  final bool isHeader;
  final String? header;
  final SlashCompletion? item;
}

/// App-wide TTS helper for "read replies aloud".
class ReplySpeaker {
  ReplySpeaker() {
    _tts = FlutterTts();
    unawaited(_configure());
  }

  late final FlutterTts _tts;
  var _enabled = false;
  var _speaking = false;

  bool get enabled => _enabled;
  bool get speaking => _speaking;

  Future<void> _configure() async {
    await _tts.setSpeechRate(0.48);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    await _tts.awaitSpeakCompletion(true);
  }

  void setEnabled(bool value) {
    _enabled = value;
    if (!value) {
      unawaited(stop());
    }
  }

  Future<void> speak(String text) async {
    final cleaned = _stripForSpeech(text);
    if (!_enabled || cleaned.isEmpty) return;
    await stop();
    _speaking = true;
    try {
      await _tts.speak(cleaned);
    } finally {
      _speaking = false;
    }
  }

  Future<void> speakOnce(String text) async {
    final cleaned = _stripForSpeech(text);
    if (cleaned.isEmpty) return;
    await stop();
    _speaking = true;
    try {
      await _tts.speak(cleaned);
    } finally {
      _speaking = false;
    }
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
    _speaking = false;
  }

  Future<void> dispose() async {
    await stop();
  }

  static String _stripForSpeech(String raw) {
    // Drop fenced code blocks and light markdown noise for cleaner TTS.
    var s = raw.replaceAll(
      RegExp(r'```[\s\S]*?```', multiLine: true),
      ' code block ',
    );
    s = s.replaceAll(RegExp(r'`[^`]+`'), ' ');
    s = s.replaceAll(RegExp(r'[*_#>\[\]\(\)!]'), ' ');
    s = s.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (s.length > 2500) s = '${s.substring(0, 2500)}…';
    return s;
  }
}
