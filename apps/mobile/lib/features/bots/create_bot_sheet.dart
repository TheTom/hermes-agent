import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hermes_mobile/core/models/hermes_models.dart';
import 'package:hermes_mobile/core/providers.dart';
import 'package:hermes_mobile/features/bots/bot_advanced_editor.dart';
import 'package:hermes_mobile/features/bots/bot_avatar_picker.dart';
import 'package:hermes_mobile/l10n/l10n.dart';

String botSlugify(String value) {
  final slug = value
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9_-]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
  return slug.length > 64 ? slug.substring(0, 64) : slug;
}

Future<HermesBotProfile?> showCreateBotSheet(
  BuildContext context, {
  required Set<String> existingNames,
}) {
  return showModalBottomSheet<HermesBotProfile>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => _CreateBotSheet(existingNames: existingNames),
  );
}

class _CreateBotSheet extends ConsumerStatefulWidget {
  const _CreateBotSheet({required this.existingNames});

  final Set<String> existingNames;

  @override
  ConsumerState<_CreateBotSheet> createState() => _CreateBotSheetState();
}

class _CreateBotSheetState extends ConsumerState<_CreateBotSheet> {
  final _name = TextEditingController();
  final _title = TextEditingController();
  final _description = TextEditingController();
  var _shape = 'circle';
  var _color = '#f97316';
  Uint8List? _avatarBytes;
  var _useImage = false;
  var _busy = false;
  final _advanced = BotAdvancedController.create();
  String? _error;

  String get _slug => botSlugify(_name.text);
  bool get _taken => widget.existingNames.contains(_slug);
  bool get _valid =>
      _slug.isNotEmpty && RegExp(r'^[a-z0-9][a-z0-9_-]{0,63}$').hasMatch(_slug);

  @override
  void dispose() {
    _name.dispose();
    _title.dispose();
    _description.dispose();
    _advanced.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_valid || _taken || _busy) return;
    final sync = ref.read(sessionSyncProvider);
    if (sync == null) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final bot = await sync.createBot(
        name: _slug,
        title: _title.text,
        description: _description.text,
        shape: _shape,
        color: _color,
        avatarBytes: _useImage ? _avatarBytes : null,
        cloneFrom: _advanced.cloneFrom,
        shareAuth: _advanced.shareAuth,
        noSkills: _advanced.noSkills,
        customSoul: _advanced.soul.text,
        model: _advanced.model,
        provider: _advanced.provider,
        disabledSkills: _advanced.disabledSkills,
        enabledToolsets: _advanced.enabledToolsets,
        enabledMcpServers: _advanced.enabledMcpServers,
      );
      if (mounted) Navigator.of(context).pop(bot);
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
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      padding: EdgeInsets.only(bottom: bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.9,
        ),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.newBotTitle, style: theme.textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(
                l10n.newBotSubtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.62),
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: _name,
                enabled: !_busy,
                textInputAction: TextInputAction.next,
                autocorrect: false,
                decoration: InputDecoration(
                  labelText: l10n.botNameLabel,
                  helperText: _slug.isEmpty ? l10n.botNameHelper : '@$_slug',
                  errorText: _taken ? l10n.botNameTaken : null,
                ),
                onTapOutside: (_) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _title,
                enabled: !_busy,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(labelText: l10n.title),
                onTapOutside: (_) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _description,
                enabled: !_busy,
                minLines: 2,
                maxLines: 4,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  labelText: l10n.botDescriptionLabel,
                ),
                onTapOutside: (_) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
              ),
              const SizedBox(height: 20),
              BotAdvancedEditor(
                controller: _advanced,
                profile: _slug,
                profileNames: widget.existingNames,
                enabled: !_busy,
              ),
              const SizedBox(height: 10),
              Text(l10n.botAppearanceLabel, style: theme.textTheme.titleSmall),
              const SizedBox(height: 10),
              BotAvatarPicker(
                bot: _slug.isEmpty ? 'agent' : _slug,
                title: _title.text,
                description: _description.text,
                shape: _shape,
                color: _color,
                useImage: _useImage,
                imageBytes: _avatarBytes,
                enabled: !_busy,
                onShape: (value) => setState(() => _shape = value),
                onColor: (value) => setState(() => _color = value),
                onImage: (bytes) => setState(() {
                  _avatarBytes = bytes;
                  _useImage = bytes != null;
                }),
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(
                  _error!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _busy ? null : () => Navigator.of(context).pop(),
                    child: Text(l10n.cancel),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: _valid && !_taken && !_busy ? _submit : null,
                    icon: _busy
                        ? const SizedBox.square(
                            dimension: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.add),
                    label: Text(
                      _busy ? l10n.creatingBot : l10n.createBotAction,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
