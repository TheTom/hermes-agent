import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hermes_mobile/core/models/hermes_models.dart';
import 'package:hermes_mobile/core/providers.dart';
import 'package:hermes_mobile/features/bots/bot_advanced_editor.dart';
import 'package:hermes_mobile/features/bots/bot_avatar_picker.dart';
import 'package:hermes_mobile/l10n/l10n.dart';

Future<bool> showEditBotSheet(
  BuildContext context, {
  required HermesBotProfile bot,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => _EditBotSheet(bot: bot),
  ).then((saved) => saved ?? false);
}

class _EditBotSheet extends ConsumerStatefulWidget {
  const _EditBotSheet({required this.bot});

  final HermesBotProfile bot;

  @override
  ConsumerState<_EditBotSheet> createState() => _EditBotSheetState();
}

class _EditBotSheetState extends ConsumerState<_EditBotSheet> {
  late final TextEditingController _title;
  late final TextEditingController _description;
  late String _shape;
  late String _color;
  late bool _usePhoto;
  final _advanced = BotAdvancedController.edit();
  Uint8List? _pickedAvatar;
  bool _avatarChanged = false;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.bot.title ?? '');
    _description = TextEditingController(text: widget.bot.description ?? '');
    _shape = widget.bot.shape ?? 'circle';
    _color = widget.bot.color ?? '#f97316';
    _usePhoto = widget.bot.usesImageAvatar && widget.bot.hasAvatar;
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _advanced.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy) return;
    final sync = ref.read(sessionSyncProvider);
    if (sync == null) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await sync.updateBot(
        bot: widget.bot,
        title: _title.text,
        description: _description.text,
        shape: _shape,
        color: _color,
        usePhoto: _usePhoto,
        avatarBytes: _pickedAvatar,
        avatarChanged: _avatarChanged,
        soul: _advanced.dirtySoul ? _advanced.soul.text : null,
        model: _advanced.dirtyModel ? _advanced.model : '',
        provider: _advanced.dirtyModel ? _advanced.provider : '',
        disabledSkills: _advanced.disabledSkills,
        enabledToolsets: _advanced.enabledToolsets,
        enabledMcpServers: _advanced.enabledMcpServers,
      );
      ref.invalidate(botAvatarProvider(widget.bot.name));
      if (mounted) Navigator.of(context).pop(true);
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
              Text(l10n.editBotTitle, style: theme.textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(
                l10n.botHandleImmutable(widget.bot.handle),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.62),
                ),
              ),
              const SizedBox(height: 18),
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
                maxLines: 5,
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
                profile: widget.bot.name,
                profileNames: const {},
                enabled: !_busy,
              ),
              const SizedBox(height: 10),
              Text(l10n.botAppearanceLabel, style: theme.textTheme.titleSmall),
              const SizedBox(height: 10),
              BotAvatarPicker(
                bot: widget.bot.name,
                title: _title.text,
                description: _description.text,
                shape: _shape,
                color: _color,
                useImage: _usePhoto,
                imageBytes: _pickedAvatar,
                enabled: !_busy,
                onShape: (value) => setState(() => _shape = value),
                onColor: (value) => setState(() => _color = value),
                onImage: (bytes) => setState(() {
                  _pickedAvatar = bytes;
                  _usePhoto = bytes != null;
                  _avatarChanged = bytes != null || widget.bot.hasAvatar;
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
                    onPressed: _busy ? null : _submit,
                    icon: _busy
                        ? const SizedBox.square(
                            dimension: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save_outlined),
                    label: Text(_busy ? l10n.savingBot : l10n.save),
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
