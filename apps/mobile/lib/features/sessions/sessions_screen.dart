import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:hermes_mobile/core/demo/demo_mode.dart';
import 'package:hermes_mobile/core/models/hermes_models.dart';
import 'package:hermes_mobile/core/network/dashboard_client.dart';
import 'package:hermes_mobile/core/providers.dart';
import 'package:hermes_mobile/core/services/feedback.dart';
import 'package:hermes_mobile/core/services/slash_commands.dart';
import 'package:hermes_mobile/features/models/model_picker_sheet.dart';
import 'package:hermes_mobile/features/skills/skills_picker_sheet.dart';
import 'package:hermes_mobile/features/sessions/chat_composer.dart';
import 'package:hermes_mobile/features/sessions/session_chat_screen.dart';
import 'package:hermes_mobile/l10n/l10n.dart';

/// Claude-style chat home: land in a new chat (greeting + composer), history
/// lives in a drawer. Opening a past chat embeds the transcript.
class SessionsScreen extends ConsumerStatefulWidget {
  const SessionsScreen({super.key});

  @override
  ConsumerState<SessionsScreen> createState() => _SessionsScreenState();
}

class _SessionsScreenState extends ConsumerState<SessionsScreen> {
  final _homeComposer = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  /// null = new-chat home; non-null = open session.
  HermesSession? _active;
  String? _pendingFirstMessage;

  /// Chips on the empty-home composer only.
  List<PendingImage> _homeAttachments = const [];

  /// One-shot handoff into the newly created chat (not used as a rebuild key).
  List<PendingImage> _handoffAttachments = const [];
  var _starting = false;

  @override
  void dispose() {
    _homeComposer.dispose();
    super.dispose();
  }

  String _greetingName(WidgetRef ref) {
    final profile = ref.watch(connectionProfileProvider).value;
    final u = profile?.username?.trim();
    if (u != null && u.isNotEmpty) {
      // Capitalize first letter only.
      return u[0].toUpperCase() + (u.length > 1 ? u.substring(1) : '');
    }
    return 'there';
  }

  String _timeGreeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Morning';
    if (h < 17) return 'Afternoon';
    return 'Evening';
  }

  Future<void> _startNewChat() async {
    hermesHaptic(HapticIntent.open);
    setState(() {
      _active = null;
      _homeAttachments = const [];
      _handoffAttachments = const [];
      _pendingFirstMessage = null;
    });
    _homeComposer.clear();
  }

  Future<void> _openSession(HermesSession session) async {
    hermesHaptic(HapticIntent.selection);
    setState(() {
      _active = session;
      _homeAttachments = const [];
      _handoffAttachments = const [];
      _pendingFirstMessage = null;
    });
    _scaffoldKey.currentState?.closeDrawer();
    // Clear unread dot for this chat.
    unawaited(ref.read(sessionReadMapProvider.notifier).markRead(session));
  }

  Future<void> _sendFromHome() async {
    final text = _homeComposer.text.trim();
    if ((text.isEmpty && _homeAttachments.isEmpty) || _starting) return;

    // Slash from empty home — create a session first, then run the command.
    final isSlash =
        text.isNotEmpty &&
        looksLikeSlashCommand(text) &&
        _homeAttachments.isEmpty;

    final notifier = ref.read(sessionsProvider.notifier);
    final model =
        ref.read(selectedModelProvider).value ??
        ref.read(resolvedModelIdProvider);
    var provider = ref.read(selectedProviderProvider).value;
    final reasoningEffort =
        ref.read(selectedReasoningEffortProvider).value ?? 'medium';
    final fastMode = ref.read(selectedFastModeProvider).value ?? false;
    // Ensure Grok/xAI (etc.) ship with their provider slug on session.create.
    if (model != null && model != context.l10n.selectModel) {
      final opts = ref.read(modelOptionsProvider).value;
      if (opts != null) {
        provider = providerForModel(opts, model, preferred: provider);
      }
    }
    final modelForCreate = model == context.l10n.selectModel ? null : model;
    final titleSeed = isSlash
        ? text
        : (text.isNotEmpty ? text : context.l10n.imageChat);

    hermesHaptic(HapticIntent.submit);
    setState(() => _starting = true);
    try {
      final session = await notifier.create(
        title: titleSeed.length > 48
            ? '${titleSeed.substring(0, 48)}…'
            : titleSeed,
        model: modelForCreate,
        provider: provider,
        reasoningEffort: reasoningEffort,
        fastMode: fastMode,
      );
      if (session == null || !mounted) return;
      final attachments = List<PendingImage>.from(_homeAttachments);
      _homeComposer.clear();
      setState(() {
        _pendingFirstMessage = text.isEmpty ? null : text;
        _handoffAttachments = attachments;
        _homeAttachments = const [];
        _active = session;
        _starting = false;
      });
      unawaited(ref.read(sessionReadMapProvider.notifier).markRead(session));
    } catch (e) {
      if (!mounted) return;
      FeedbackService.instance.error();
      setState(() => _starting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.couldNotStartChat('$e'))),
      );
    }
  }

  Future<void> _openSessionById(String id) async {
    final list = ref.read(sessionsProvider).value ?? const [];
    final hit = list
        .where((s) => s.id == id || s.id.startsWith(id))
        .firstOrNull;
    if (hit != null) {
      await _openSession(hit);
      return;
    }
    // Soft refresh then retry once.
    await ref.read(sessionsProvider.notifier).softRefresh();
    final again = ref.read(sessionsProvider).value ?? const [];
    final found = again
        .where((s) => s.id == id || s.id.startsWith(id))
        .firstOrNull;
    if (found != null) {
      await _openSession(found);
      return;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.sessionNotFound(id))));
  }

  Future<void> _pickModelHome() async {
    final pick = await showModelPickerSheet(context, ref);
    if (pick == null) return;
    await ref
        .read(selectedModelProvider.notifier)
        .select(pick.model, provider: pick.provider);
    if (pick.reasoningEffort != null) {
      await ref
          .read(selectedReasoningEffortProvider.notifier)
          .select(pick.reasoningEffort!);
    }
    if (pick.fastMode != null) {
      await ref.read(selectedFastModeProvider.notifier).select(pick.fastMode!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessions = ref.watch(sessionsProvider);
    final pinnedIds = ref.watch(pinnedSessionsProvider).value ?? const [];
    ref.watch(sessionReadMapProvider); // rebuild drawer when reads change
    // Sticky pick, or gateway default from /api/model/options.
    final model = ref.watch(resolvedModelLabelProvider);
    final active = _active;
    final isDemo = isDemoProfileId(
      ref.watch(connectionProfileProvider).value?.id ?? '',
    );

    // One-shot seed + mark open chat read. Defer provider writes to the next
    // frame so we never invalidate/read-map during this build (Riverpod 3
    // schedules ProviderScope setState via vsync.scheduleRefresh).
    ref.listen(sessionsProvider, (prev, next) {
      next.whenData((list) {
        final openId = _active?.id;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          unawaited(
            ref.read(sessionReadMapProvider.notifier).seedExistingAsRead(list),
          );
          if (openId == null) return;
          final live = list.where((s) => s.id == openId).firstOrNull;
          if (live != null) {
            unawaited(ref.read(sessionReadMapProvider.notifier).markRead(live));
          }
        });
      });
    });

    return Scaffold(
      key: _scaffoldKey,
      drawer: _ChatsDrawer(
        sessions: sessions,
        pinnedIds: pinnedIds,
        activeId: active?.id,
        onOpen: _openSession,
        onNewChat: () {
          _startNewChat();
          _scaffoldKey.currentState?.closeDrawer();
        },
        onTogglePin: (id) {
          hermesHaptic(HapticIntent.selection);
          ref.read(pinnedSessionsProvider.notifier).toggle(id);
        },
        onRename: (session) => _renameSession(session),
        onExport: (session) => _exportSession(session),
        onArchive: (id) async {
          hermesHaptic(HapticIntent.warning);
          await ref.read(sessionsProvider.notifier).archive(id);
          if (_active?.id == id && mounted) {
            setState(() => _active = null);
          }
        },
        onDelete: (id) async {
          hermesHaptic(HapticIntent.cancel);
          await ref.read(sessionsProvider.notifier).delete(id);
          if (_active?.id == id && mounted) {
            setState(() => _active = null);
          }
        },
        onRefresh: () =>
            ref.read(sessionsProvider.notifier).softRefresh(bypassTtl: true),
        isUnread: (s) => ref
            .read(sessionReadMapProvider.notifier)
            .isUnread(s, activeId: active?.id),
      ),
      appBar: AppBar(
        leading: IconButton(
          tooltip: context.l10n.chats,
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: active == null
            ? Text(context.l10n.appTitle)
            : InkWell(
                onTap: () => _renameSession(active),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 6,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          active.displayTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.edit_outlined,
                        size: 16,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.55),
                      ),
                    ],
                  ),
                ),
              ),
        actions: [
          // Tasteful, unobtrusive — a reviewer/user must never mistake a
          // scripted sample reply for their real agent. Not shown anywhere
          // else in the app chrome; the connect screen stays silent about
          // the demo host (see APP_REVIEW_NOTES.md).
          if (isDemo)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Center(
                child: Chip(
                  label: Text(context.l10n.sampleWorkspaceBadge),
                  labelStyle: Theme.of(context).textTheme.labelSmall,
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  side: BorderSide.none,
                ),
              ),
            ),
          if (active != null)
            IconButton(
              tooltip: context.l10n.newChat,
              icon: const Icon(Icons.edit_square),
              onPressed: _startNewChat,
            ),
        ],
      ),
      body: active == null
          ? _NewChatHome(
              greeting: '${_timeGreeting()}, ${_greetingName(ref)}',
              model: model,
              composer: _homeComposer,
              starting: _starting,
              attachments: _homeAttachments,
              onAttachmentsChanged: (next) =>
                  setState(() => _homeAttachments = next),
              onPickModel: _pickModelHome,
              onSend: _sendFromHome,
              // Same Desktop pipeline as open chat (catalog + skills).
              slashCompleter: (text) async {
                final sync = ref.read(sessionSyncProvider);
                if (sync == null) return const [];
                return sync.completeSlashWithSkills(text);
              },
              onPickSkill: () async {
                final cmd = await showSkillsPickerSheet(context, ref);
                if (cmd == null || !mounted) return;
                final withSpace = cmd.endsWith(' ') ? cmd : '$cmd ';
                _homeComposer.value = TextEditingValue(
                  text: withSpace,
                  selection: TextSelection.collapsed(offset: withSpace.length),
                );
              },
            )
          : SessionChatScreen(
              // Key ONLY on session id — never bake pending first-message into
              // the key (clearing it remounted the chat mid-send and wiped the
              // optimistic user bubble while tools kept running).
              key: ValueKey(active.id),
              session: active,
              embedded: true,
              initialMessage: _pendingFirstMessage,
              initialAttachments: _handoffAttachments,
              onNewChat: _startNewChat,
              onOpenSessionId: (id) => unawaited(_openSessionById(id)),
              onSessionUpdated: (s) {
                if (mounted) {
                  setState(() {
                    // Keep key stable when only metadata changes; only swap id
                    // when remap actually produced a new session id.
                    _active = s;
                    _pendingFirstMessage = null;
                    _handoffAttachments = const [];
                  });
                  unawaited(
                    ref.read(sessionReadMapProvider.notifier).markRead(s),
                  );
                }
              },
            ),
    );
  }

  Future<void> _renameSession(HermesSession session) async {
    final next = await showRenameSessionDialog(
      context,
      initialTitle: session.title ?? '',
    );
    if (next == null || next == (session.title ?? '').trim()) return;
    try {
      hermesHaptic(HapticIntent.success);
      await ref.read(sessionsProvider.notifier).rename(session.id, next);
      if (_active?.id == session.id && mounted) {
        setState(() {
          _active = HermesSession(
            id: session.id,
            source: session.source,
            userId: session.userId,
            model: session.model,
            title: next.isEmpty ? null : next,
            startedAt: session.startedAt,
            endedAt: session.endedAt,
            endReason: session.endReason,
            messageCount: session.messageCount,
            toolCallCount: session.toolCallCount,
            lastActive: session.lastActive,
            preview: session.preview,
            parentSessionId: session.parentSessionId,
          );
        });
      }
    } catch (e) {
      if (!mounted) return;
      FeedbackService.instance.error();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.renameFailed('$e'))));
    }
  }

  Future<void> _exportSession(HermesSession session) async {
    final sync = ref.read(sessionSyncProvider);
    if (sync == null) return;
    try {
      hermesHaptic(HapticIntent.selection);
      final payload = await sync.exportSessionPayload(session.id);
      final json = const JsonEncoder.withIndent('  ').convert(payload);
      var safeTitle = session.displayTitle
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9._-]+'), '-')
          .replaceAll(RegExp(r'^-+|-+$'), '');
      if (safeTitle.length > 48) safeTitle = safeTitle.substring(0, 48);
      final idPart = session.id.length > 8
          ? session.id.substring(0, 8)
          : session.id;
      final name = '${safeTitle.isEmpty ? 'session' : safeTitle}-$idPart.json';
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$name');
      await file.writeAsString(json);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'application/json')],
          subject: 'Hermes session ${session.displayTitle}',
        ),
      );
    } catch (e) {
      if (!mounted) return;
      FeedbackService.instance.error();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.exportFailed('$e'))));
    }
  }
}

/// Greeting + composer home (Claude empty state).
class _NewChatHome extends StatelessWidget {
  const _NewChatHome({
    required this.greeting,
    required this.model,
    required this.composer,
    required this.starting,
    required this.onPickModel,
    required this.onSend,
    this.attachments = const [],
    this.onAttachmentsChanged,
    this.slashCompleter,
    this.onPickSkill,
  });

  final String greeting;
  final String model;
  final TextEditingController composer;
  final bool starting;
  final VoidCallback onPickModel;
  final VoidCallback onSend;
  final List<PendingImage> attachments;
  final ValueChanged<List<PendingImage>>? onAttachmentsChanged;
  final Future<List<SlashCompletion>> Function(String text)? slashCompleter;
  final VoidCallback? onPickSkill;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        // Model at top.
        Material(
          color: theme.scaffoldBackgroundColor,
          child: InkWell(
            onTap: onPickModel,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
              child: Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    size: 16,
                    color: theme.colorScheme.primary.withValues(alpha: 0.9),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      model,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.expand_more,
                    size: 18,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
                  ),
                ],
              ),
            ),
          ),
        ),
        Divider(
          height: 1,
          color: theme.colorScheme.outline.withValues(alpha: 0.35),
        ),
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      size: 36,
                      color: theme.colorScheme.primary.withValues(alpha: 0.85),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      greeting,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                        letterSpacing: -0.3,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.88,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      context.l10n.startNewChatHint,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        ChatComposerBar(
          controller: composer,
          sending: starting,
          onSend: onSend,
          hint: context.l10n.messageHint,
          attachments: attachments,
          onAttachmentsChanged: onAttachmentsChanged,
          slashCompleter: slashCompleter,
          onPickSkill: onPickSkill,
        ),
      ],
    );
  }
}

class _ChatsDrawer extends StatelessWidget {
  const _ChatsDrawer({
    required this.sessions,
    required this.pinnedIds,
    required this.activeId,
    required this.onOpen,
    required this.onNewChat,
    required this.onTogglePin,
    required this.onRename,
    required this.onExport,
    required this.onArchive,
    required this.onDelete,
    required this.onRefresh,
    required this.isUnread,
  });

  final AsyncValue<List<HermesSession>> sessions;
  final List<String> pinnedIds;
  final String? activeId;
  final ValueChanged<HermesSession> onOpen;
  final VoidCallback onNewChat;
  final ValueChanged<String> onTogglePin;
  final ValueChanged<HermesSession> onRename;
  final ValueChanged<HermesSession> onExport;
  final ValueChanged<String> onArchive;
  final ValueChanged<String> onDelete;
  final VoidCallback onRefresh;
  final bool Function(HermesSession) isUnread;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 12, 4),
              child: Row(
                children: [
                  Text(
                    context.l10n.appTitle,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: context.l10n.sync,
                    onPressed: onRefresh,
                    icon: const Icon(Icons.sync, size: 20),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 12, 10),
              child: Text(
                context.l10n.tagline,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  letterSpacing: 0.1,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: FilledButton.tonalIcon(
                onPressed: onNewChat,
                icon: const Icon(Icons.edit_square, size: 18),
                label: Text(context.l10n.newChat),
                style: FilledButton.styleFrom(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: sessions.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('$e', textAlign: TextAlign.center),
                  ),
                ),
                data: (list) {
                  if (list.isEmpty) {
                    return Center(
                      child: Text(
                        context.l10n.noChatsYet,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.45,
                          ),
                        ),
                      ),
                    );
                  }
                  final ordered = orderSessionsWithPins(list, pinnedIds);
                  final pinnedSet = pinnedIds.toSet();
                  final pinned = ordered
                      .where((s) => pinnedSet.contains(s.id))
                      .toList();
                  final recent = ordered
                      .where((s) => !pinnedSet.contains(s.id))
                      .toList();

                  return ListView(
                    padding: const EdgeInsets.only(bottom: 24),
                    children: [
                      if (pinned.isNotEmpty) ...[
                        _DrawerSectionLabel(context.l10n.pinned),
                        for (final s in pinned)
                          _DrawerSessionTile(
                            session: s,
                            pinned: true,
                            selected: s.id == activeId,
                            unread: isUnread(s),
                            onTap: () => onOpen(s),
                            onTogglePin: () => onTogglePin(s.id),
                            onRename: () => onRename(s),
                            onExport: () => onExport(s),
                            onArchive: () => onArchive(s.id),
                            onDelete: () => onDelete(s.id),
                          ),
                      ],
                      if (recent.isNotEmpty) ...[
                        _DrawerSectionLabel(context.l10n.recents),
                        for (final s in recent)
                          _DrawerSessionTile(
                            session: s,
                            pinned: false,
                            selected: s.id == activeId,
                            unread: isUnread(s),
                            onTap: () => onOpen(s),
                            onTogglePin: () => onTogglePin(s.id),
                            onRename: () => onRename(s),
                            onExport: () => onExport(s),
                            onArchive: () => onArchive(s.id),
                            onDelete: () => onDelete(s.id),
                          ),
                      ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerSectionLabel extends StatelessWidget {
  const _DrawerSectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 6),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _DrawerSessionTile extends StatelessWidget {
  const _DrawerSessionTile({
    required this.session,
    required this.pinned,
    required this.selected,
    required this.unread,
    required this.onTap,
    required this.onTogglePin,
    required this.onRename,
    required this.onExport,
    required this.onArchive,
    required this.onDelete,
  });

  final HermesSession session;
  final bool pinned;
  final bool selected;
  final bool unread;
  final VoidCallback onTap;
  final VoidCallback onTogglePin;
  final VoidCallback onRename;
  final VoidCallback onExport;
  final VoidCallback onArchive;
  final VoidCallback onDelete;

  Future<void> _confirmDelete(BuildContext context) async {
    hermesHaptic(HapticIntent.warning);
    final ok =
        await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(context.l10n.deleteChatTitle),
            content: Text(
              'Remove “${session.displayTitle}” from this gateway?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(context.l10n.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(context.l10n.delete),
              ),
            ],
          ),
        ) ??
        false;
    if (ok) onDelete();
  }

  Future<void> _onMenuSelected(BuildContext context, String action) async {
    hermesHaptic(HapticIntent.selection);
    switch (action) {
      case 'pin':
        onTogglePin();
      case 'copy_id':
        await Clipboard.setData(ClipboardData(text: session.id));
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(context.l10n.sessionIdCopied)));
        }
      case 'export':
        onExport();
      case 'rename':
        onRename();
      case 'archive':
        onArchive();
      case 'delete':
        await _confirmDelete(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Relative only ("2 hours ago") — never raw epoch / ISO dumps.
    final when = formatSessionRelative(session.lastActive ?? session.startedAt);

    // Desktop-style leading bullet: dim when read, lit when unread.
    final bulletColor = unread
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurface.withValues(alpha: 0.22);

    return Dismissible(
      key: ValueKey('drawer-${session.id}'),
      direction: DismissDirection.startToEnd,
      confirmDismiss: (direction) async {
        hermesHaptic(HapticIntent.warning);
        final ok =
            await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text(context.l10n.deleteChatTitle),
                content: Text(
                  'Remove “${session.displayTitle}” from this gateway?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: Text(context.l10n.cancel),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: Text(context.l10n.delete),
                  ),
                ],
              ),
            ) ??
            false;
        if (ok) hermesHaptic(HapticIntent.cancel);
        return ok;
      },
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        color: theme.colorScheme.error.withValues(alpha: 0.9),
        child: Row(
          children: [
            Icon(Icons.delete_outline, color: theme.colorScheme.onError),
            const SizedBox(width: 8),
            Text(
              'Delete',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onError,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      child: ListTile(
        selected: selected,
        selectedTileColor: theme.colorScheme.primary.withValues(alpha: 0.1),
        contentPadding: const EdgeInsets.only(left: 12, right: 4),
        leading: SizedBox(
          width: 18,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: unread ? 8 : 6,
              height: unread ? 8 : 6,
              decoration: BoxDecoration(
                color: bulletColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        title: Text(
          session.displayTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: unread ? FontWeight.w700 : FontWeight.w500,
            fontSize: 15,
          ),
        ),
        subtitle: when == null
            ? null
            : Text(
                when,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
                ),
              ),
        onTap: onTap,
        trailing: PopupMenuButton<String>(
          tooltip: context.l10n.sessionActions,
          padding: EdgeInsets.zero,
          icon: Icon(
            Icons.more_vert,
            size: 20,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
          ),
          onSelected: (action) => unawaited(_onMenuSelected(context, action)),
          itemBuilder: (ctx) => [
            PopupMenuItem(
              value: 'pin',
              child: ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  pinned ? Icons.push_pin : Icons.push_pin_outlined,
                  size: 20,
                ),
                title: Text(pinned ? context.l10n.unpin : context.l10n.pin),
              ),
            ),
            PopupMenuItem(
              value: 'copy_id',
              child: ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.copy_outlined, size: 20),
                title: Text(context.l10n.copyId),
              ),
            ),
            PopupMenuItem(
              value: 'export',
              child: ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.cloud_download_outlined, size: 20),
                title: Text(context.l10n.export),
              ),
            ),
            PopupMenuItem(
              value: 'rename',
              child: ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.edit_outlined, size: 20),
                title: Text(context.l10n.rename),
              ),
            ),
            PopupMenuItem(
              value: 'archive',
              child: ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.archive_outlined, size: 20),
                title: Text(context.l10n.archive),
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.delete_outline,
                  size: 20,
                  color: theme.colorScheme.error,
                ),
                title: Text(
                  'Delete',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
