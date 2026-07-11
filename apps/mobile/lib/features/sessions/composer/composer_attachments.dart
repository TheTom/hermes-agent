import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'package:hermes_mobile/core/services/feedback.dart';
import 'package:hermes_mobile/features/sessions/composer/pending_image.dart';
import 'package:hermes_mobile/l10n/l10n.dart';

/// Gallery / camera / clipboard attach flows for the composer.
class ComposerAttachmentActions {
  ComposerAttachmentActions({
    required this.mounted,
    required this.context,
    ImagePicker? picker,
  }) : _picker = picker ?? ImagePicker();

  final bool Function() mounted;
  final BuildContext Function() context;
  final ImagePicker _picker;

  Future<void> showSheet({
    required bool enabled,
    required bool sending,
    required List<PendingImage> attachments,
    required ValueChanged<List<PendingImage>>? onChanged,
    VoidCallback? onPickSkill,
  }) async {
    if (!enabled || sending) return;
    final ctx = context();
    final choice = await showModalBottomSheet<String>(
      context: ctx,
      showDragHandle: true,
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(ctx.l10n.photoLibrary),
              onTap: () => Navigator.pop(sheetCtx, 'gallery'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(ctx.l10n.camera),
              onTap: () => Navigator.pop(sheetCtx, 'camera'),
            ),
            ListTile(
              leading: const Icon(Icons.content_paste_go_outlined),
              title: Text(ctx.l10n.pasteImageFromClipboard),
              onTap: () => Navigator.pop(sheetCtx, 'paste'),
            ),
            if (onPickSkill != null)
              ListTile(
                leading: const Icon(Icons.extension_outlined),
                title: Text(ctx.l10n.skillsSection),
                subtitle: Text(ctx.l10n.skillsTitle),
                onTap: () => Navigator.pop(sheetCtx, 'skills'),
              ),
          ],
        ),
      ),
    );
    if (!mounted() || choice == null) return;
    hermesHaptic(HapticIntent.selection);
    switch (choice) {
      case 'gallery':
        await pickImages(
          ImageSource.gallery,
          attachments: attachments,
          onChanged: onChanged,
        );
      case 'camera':
        await pickImages(
          ImageSource.camera,
          attachments: attachments,
          onChanged: onChanged,
        );
      case 'paste':
        await pasteImage(attachments: attachments, onChanged: onChanged);
      case 'skills':
        onPickSkill?.call();
    }
  }

  Future<void> pickImages(
    ImageSource source, {
    required List<PendingImage> attachments,
    required ValueChanged<List<PendingImage>>? onChanged,
  }) async {
    try {
      if (source == ImageSource.gallery) {
        final files = await _picker.pickMultiImage(
          imageQuality: 85,
          maxWidth: 2048,
          maxHeight: 2048,
        );
        if (files.isEmpty) return;
        final next = [...attachments];
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
        onChanged?.call(next);
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
          ...attachments,
          PendingImage(
            id: 'img_${DateTime.now().microsecondsSinceEpoch}',
            bytes: bytes,
            filename: file.name.isNotEmpty ? file.name : 'camera.jpg',
          ),
        ];
        hermesHaptic(HapticIntent.success);
        onChanged?.call(next);
      }
    } catch (e) {
      if (!mounted()) return;
      FeedbackService.instance.error();
      final ctx = context();
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(content: Text(ctx.l10n.couldNotPickImage('$e'))),
      );
    }
  }

  Future<void> pasteImage({
    required List<PendingImage> attachments,
    required ValueChanged<List<PendingImage>>? onChanged,
  }) async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      final text = data?.text;
      if (text != null && text.startsWith('data:image')) {
        final comma = text.indexOf(',');
        if (comma > 0) {
          final bytes = base64Decode(text.substring(comma + 1));
          final next = [
            ...attachments,
            PendingImage(
              id: 'img_${DateTime.now().microsecondsSinceEpoch}',
              bytes: Uint8List.fromList(bytes),
              filename: 'pasted.png',
            ),
          ];
          onChanged?.call(next);
          return;
        }
      }
      if (!mounted()) return;
      final ctx = context();
      ScaffoldMessenger.of(
        ctx,
      ).showSnackBar(SnackBar(content: Text(ctx.l10n.noImageOnClipboard)));
    } catch (e) {
      if (!mounted()) return;
      final ctx = context();
      ScaffoldMessenger.of(
        ctx,
      ).showSnackBar(SnackBar(content: Text(ctx.l10n.pasteFailed('$e'))));
    }
  }

  static List<PendingImage> remove(List<PendingImage> attachments, String id) {
    return attachments.where((a) => a.id != id).toList();
  }
}

/// Horizontal pending-image chips above the composer pill.
class ComposerAttachmentStrip extends StatelessWidget {
  const ComposerAttachmentStrip({
    super.key,
    required this.attachments,
    required this.sending,
    required this.onRemove,
  });

  final List<PendingImage> attachments;
  final bool sending;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: attachments.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final a = attachments[i];
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
                    onTap: sending ? null : () => onRemove(a.id),
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
    );
  }
}
