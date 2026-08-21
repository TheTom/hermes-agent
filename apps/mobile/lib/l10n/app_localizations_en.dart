// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Hermes Go';

  @override
  String get tagline => 'Go further. Stay connected.';

  @override
  String get aboutBody =>
      'Hermes Go v0.1\nGo further. Stay connected.\nGateway connector — sessions, chat, models, jobs.';

  @override
  String failedToLoadConnection(String error) {
    return 'Failed to load connection: $error';
  }

  @override
  String get navSessions => 'Sessions';

  @override
  String get navBots => 'Bots';

  @override
  String get navJobs => 'Jobs';

  @override
  String get navSettings => 'Settings';

  @override
  String get botsTitle => 'Bots';

  @override
  String get botsEmpty => 'No bots yet. Tap + to create one.';

  @override
  String get newBotTitle => 'New Bot';

  @override
  String get newBotSubtitle =>
      'A named teammate with its own memory, skills, and chat.';

  @override
  String get botNameLabel => 'Name';

  @override
  String get botNameHelper => 'Used as the @handle';

  @override
  String get botNameTaken => 'That handle already exists';

  @override
  String get botDescriptionLabel => 'Description';

  @override
  String get botAppearanceLabel => 'Appearance';

  @override
  String get createBotAction => 'Create Bot';

  @override
  String get creatingBot => 'Creating…';

  @override
  String get editBotAction => 'Edit profile';

  @override
  String get editBotTitle => 'Edit Bot';

  @override
  String get savingBot => 'Saving…';

  @override
  String botHandleImmutable(String handle) {
    return '@$handle is the bot’s permanent handle for sessions and memory.';
  }

  @override
  String get botsNoConversation => 'No conversations yet';

  @override
  String get botsCachedRoster =>
      'Showing the last roster while the server reconnects.';

  @override
  String get modelLabel => 'Model';

  @override
  String get lastActivity => 'Last activity';

  @override
  String get messagesLabel => 'Messages';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get checkConnection => 'Check connection';

  @override
  String get liveChatReady => 'Live — chat ready';

  @override
  String get notLiveSeeStatus => 'Not live — see Connection status';

  @override
  String get wsConnectedChatReady => 'WebSocket connected — chat ready';

  @override
  String get stillOffline => 'Still offline';

  @override
  String get apiToken => 'API token';

  @override
  String get refreshSignIn => 'Refresh sign-in';

  @override
  String get refreshSignInSubtitle =>
      'Re-enter password (e.g. after a host kick). Not automatic.';

  @override
  String get disconnect => 'Disconnect';

  @override
  String get disconnectSubtitle => 'Remove this gateway from the phone';

  @override
  String get disconnectConfirmTitle => 'Disconnect?';

  @override
  String get disconnectConfirmBody =>
      'Removes the saved gateway from this phone. Host agents are not affected.';

  @override
  String get exitSampleWorkspace => 'Exit sample workspace';

  @override
  String get exitSampleWorkspaceSubtitle =>
      'Stop the sandbox and remove it from this phone';

  @override
  String get exitSampleWorkspaceConfirmTitle => 'Exit sample workspace?';

  @override
  String get exitSampleWorkspaceConfirmBody =>
      'Stops the built-in sample gateway and clears its sessions from this phone. Nothing leaves the device.';

  @override
  String get sampleWorkspaceAboutLine =>
      'Sample workspace — connect to demo.hermes.go (user demo, password demo) to try Hermes Go without setting up a gateway.';

  @override
  String get sampleWorkspaceBadge => 'Sample';

  @override
  String get cancel => 'Cancel';

  @override
  String get theme => 'Theme';

  @override
  String get appearance => 'Appearance';

  @override
  String get appearanceSubtitle =>
      'Same built-in skins as Desktop (Nous, Midnight, Ember, …).';

  @override
  String get hapticsSounds => 'Haptics & sounds';

  @override
  String get hapticsOff => 'Off — no taps, no completion chime';

  @override
  String get hapticsOn => 'On — taps, send/stop feedback, reply chime';

  @override
  String get previewHaptics => 'Preview haptics & chime';

  @override
  String get syncNow => 'Sync now';

  @override
  String get syncNowSubtitle => 'Sessions, jobs, models, skills';

  @override
  String syncedWithSummary(String summary) {
    return 'Synced ($summary)';
  }

  @override
  String get about => 'About';

  @override
  String get couldNotOpenBrowser => 'Could not open browser — link copied';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System default';

  @override
  String get languageSubtitle =>
      'App UI language. Chat content follows your agent.';

  @override
  String get connectedChatReady => 'Connected · chat ready';

  @override
  String get connectedChatReadyBody =>
      'Live WebSocket to the gateway. Messages and slash commands work.';

  @override
  String get signedInChatOffline => 'Signed in · chat offline';

  @override
  String get signedInReconnecting => 'Signed in · reconnecting';

  @override
  String get autoReconnectGaveUp =>
      'Auto-reconnect gave up. Tap Reconnect or check that the host is reachable.';

  @override
  String get signedInChatOfflineBody =>
      'HTTPS/cookies may work for lists, but the live WebSocket is down. Auto-retry runs with backoff; or tap Reconnect.';

  @override
  String get sessionExpired => 'Session expired';

  @override
  String get sessionExpiredBody =>
      'Sign in again. Expiry may be intentional (signed out on host).';

  @override
  String get gaveUpReconnecting => 'Gave up reconnecting';

  @override
  String get connectionProblem => 'Connection problem';

  @override
  String get cannotReachGateway =>
      'Cannot reach the gateway. Check the host address, network connection, and host power.';

  @override
  String get notConnected => 'Not connected';

  @override
  String get noGatewaySaved =>
      'No gateway saved on this phone. Sign in from Connect.';

  @override
  String get webSocket => 'WebSocket';

  @override
  String get live => 'Live';

  @override
  String get httpsRest => 'HTTPS / REST';

  @override
  String get checking => 'Checking…';

  @override
  String get ok => 'OK';

  @override
  String get fail => 'Fail';

  @override
  String get unknown => 'Unknown';

  @override
  String get host => 'Host';

  @override
  String get user => 'User';

  @override
  String get reconnect => 'Reconnect';

  @override
  String get reconnectNow => 'Reconnect now';

  @override
  String get checkNow => 'Check now';

  @override
  String get signIn => 'Sign in';

  @override
  String get signInAndReconnect => 'Sign in & reconnect';

  @override
  String get gaveUpTapReconnect => 'Gave up — tap Reconnect';

  @override
  String get connecting => 'Connecting…';

  @override
  String get error => 'Error';

  @override
  String get closed => 'Closed';

  @override
  String get idle => 'Idle';

  @override
  String get offline => 'Offline';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';

  @override
  String get skinSectionDesktop => 'Desktop';

  @override
  String get skinSectionMobile => 'Mobile';

  @override
  String get required => 'Required';

  @override
  String get signedInWsLive => 'Signed in — WebSocket live';

  @override
  String signedInWsOffline(String status) {
    return 'Signed in; WebSocket: $status';
  }

  @override
  String reenterPasswordFor(String user, String host) {
    return 'Re-enter the password for $user on $host.\nWe never auto-reconnect after expiry (kicks stay kicked).';
  }

  @override
  String get connectTitle => 'Hermes Go';

  @override
  String get signInAgain => 'Sign in again';

  @override
  String get sessionExpiredBanner =>
      'Your gateway session expired (or was signed out).\nRe-enter your password to continue — we do not auto-reconnect after expiry.';

  @override
  String get connectIntro =>
      'Connect to your Hermes gateway — same as Desktop: base URL, then username and password. No API key.';

  @override
  String get gatewayBaseUrl => 'Gateway base URL';

  @override
  String get httpPrivateNetworkHint =>
      'Plain HTTP is allowed only on a trusted LAN or private VPN. Public remote access requires HTTPS.';

  @override
  String get urlRequired => 'URL required';

  @override
  String get provider => 'Provider';

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get continueAction => 'Continue';

  @override
  String get changeUrl => 'Change URL';

  @override
  String get gatewayOpenHint =>
      'Gateway is open (no password gate). You can connect without credentials.';

  @override
  String get signInPasswordHint =>
      'Sign in with username and password (same as Desktop remote gateway).';

  @override
  String get oauthOnlyError =>
      'This gateway uses OAuth sign-in only. Password login is not enabled. Enable a supports_password provider on the host, or use Desktop for OAuth.';

  @override
  String get connectedOpenGateway => 'Connected (open gateway).';

  @override
  String get noPasswordProvider => 'No password provider selected.';

  @override
  String get usernamePasswordRequired => 'Username and password required.';

  @override
  String signedInAs(String username) {
    return 'Signed in as $username';
  }

  @override
  String get gatewayNotReachable => 'Gateway not reachable.';

  @override
  String get chats => 'Chats';

  @override
  String get newChat => 'New chat';

  @override
  String get noChatsYet => 'No chats yet';

  @override
  String get startNewChatHint => 'Start a new chat, or open one from the menu.';

  @override
  String get pinned => 'Pinned';

  @override
  String get recents => 'Recents';

  @override
  String get renameChat => 'Rename chat';

  @override
  String get title => 'Title';

  @override
  String get save => 'Save';

  @override
  String renameFailed(String error) {
    return 'Rename failed: $error';
  }

  @override
  String get deleteChatTitle => 'Delete chat?';

  @override
  String get delete => 'Delete';

  @override
  String get sessionIdCopied => 'Session ID copied';

  @override
  String get sessionActions => 'Session actions';

  @override
  String get pin => 'Pin';

  @override
  String get unpin => 'Unpin';

  @override
  String get copyId => 'Copy ID';

  @override
  String get export => 'Export';

  @override
  String get rename => 'Rename';

  @override
  String get archive => 'Archive';

  @override
  String exportFailed(String error) {
    return 'Export failed: $error';
  }

  @override
  String couldNotStartChat(String error) {
    return 'Could not start chat: $error';
  }

  @override
  String sessionNotFound(String id) {
    return 'Session not found: $id';
  }

  @override
  String get selectModel => 'Select model';

  @override
  String get imageChat => 'Image chat';

  @override
  String get greetingMorning => 'Good morning';

  @override
  String get greetingAfternoon => 'Good afternoon';

  @override
  String get greetingEvening => 'Good evening';

  @override
  String get messageHint => 'Message Hermes Go…';

  @override
  String get messageHintShort => 'Message…';

  @override
  String get sendAMessageToContinue => 'Send a message to continue.';

  @override
  String get sync => 'Sync';

  @override
  String get stop => 'Stop';

  @override
  String get dictate => 'Dictate';

  @override
  String get stopDictation => 'Stop dictation';

  @override
  String get listening => 'Listening…';

  @override
  String get readAloudOn => 'Read aloud: on';

  @override
  String get readAloudOff => 'Read aloud: off';

  @override
  String get readAloud => 'Read aloud';

  @override
  String get addContext => 'Add context';

  @override
  String get photoLibrary => 'Photo library';

  @override
  String get camera => 'Camera';

  @override
  String get pasteImageFromClipboard => 'Paste image from clipboard';

  @override
  String get noImageOnClipboard =>
      'No image on clipboard — use Photo library or Camera';

  @override
  String couldNotPickImage(String error) {
    return 'Could not pick image: $error';
  }

  @override
  String pasteFailed(String error) {
    return 'Paste failed: $error';
  }

  @override
  String get speechUnavailable =>
      'Speech recognition unavailable on this device';

  @override
  String get micPermissionDenied =>
      'Microphone / speech permission denied — enable in Settings';

  @override
  String get couldNotStartDictation =>
      'Could not start dictation — check mic & speech permissions';

  @override
  String dictationFailed(String error) {
    return 'Dictation failed: $error';
  }

  @override
  String get uploadingImage => 'Uploading image…';

  @override
  String get thinking => 'Thinking';

  @override
  String get writing => 'Writing…';

  @override
  String runningTool(String name) {
    return 'Running $name…';
  }

  @override
  String imageAttachFailed(String error) {
    return 'Image attach failed: $error';
  }

  @override
  String get savedWaitingWs =>
      'Saved on phone — waiting for live WebSocket (Settings may show HTTPS only).';

  @override
  String get queuedForSync => 'Queued for sync to gateway…';

  @override
  String stopFailed(String error) {
    return 'Stop failed: $error';
  }

  @override
  String get editMessage => 'Edit message';

  @override
  String get saveAndResend => 'Save & resend';

  @override
  String get editAndResend => 'Edit & resend';

  @override
  String get rewindAndRun => 'Rewind to this prompt and run again';

  @override
  String get regenerate => 'Regenerate';

  @override
  String get resend => 'Resend';

  @override
  String get resubmitMessage => 'Resubmit this message';

  @override
  String get retryFromPrevious => 'Retry from the previous user message';

  @override
  String get noResponseYet => 'No reply yet — resend or edit this message';

  @override
  String get messageActions => 'Message actions';

  @override
  String get deleteMessageTitle => 'Delete message?';

  @override
  String get deleteMessageBody =>
      'This can\'t be undone. Hermes can\'t delete a single message on the gateway yet, so it\'s removed from this device only — the gateway keeps its own copy and it may still appear elsewhere.';

  @override
  String get messageDeleted => 'Message deleted (this device only)';

  @override
  String get copied => 'Copied';

  @override
  String get copy => 'Copy';

  @override
  String get codeCopied => 'Code copied';

  @override
  String copiedLink(String href) {
    return 'Copied link: $href';
  }

  @override
  String get stopRequested => 'Stop requested.';

  @override
  String slashFailed(String error) {
    return 'Slash failed: $error';
  }

  @override
  String modelSavedLocal(String error) {
    return 'Model saved on phone; gateway: $error';
  }

  @override
  String get pleaseLookAtImage => 'Please look at the attached image.';

  @override
  String get pleaseLookAtImages => 'Please look at the attached images.';

  @override
  String nImages(int count) {
    return '$count image(s)';
  }

  @override
  String get jobsTitle => 'Jobs';

  @override
  String get retry => 'Retry';

  @override
  String get runNow => 'Run now';

  @override
  String get pause => 'Pause';

  @override
  String get resume => 'Resume';

  @override
  String get modelPickerTitle => 'Model';

  @override
  String get modelPickerSubtitle => 'Same catalog as Desktop';

  @override
  String get reasoningOptions => 'Options';

  @override
  String get thinkingOnHint => 'Model may use reasoning tokens';

  @override
  String get thinkingOffHint => 'Reasoning disabled for this session';

  @override
  String get effort => 'Effort';

  @override
  String get applyEffort => 'Apply effort to session';

  @override
  String get confirmModel => 'Use this model';

  @override
  String get modelPickerConfirmHint =>
      'Select a model, set its options, then confirm.';

  @override
  String get modelNoOptions => 'This model has no Thinking or Fast options.';

  @override
  String get modelCapsLoading => 'Loading per-model options…';

  @override
  String get fastMode => 'Fast';

  @override
  String get fastModeHint =>
      'Priority / lower-latency when the model supports it';

  @override
  String get contextUsageTitle => 'Context Usage';

  @override
  String contextUsageTokenSummary(String used, String max) {
    return '~$used / $max Tokens';
  }

  @override
  String contextUsagePercentFull(int percent) {
    return '$percent% Full';
  }

  @override
  String get contextUsageLoading => 'Loading breakdown…';

  @override
  String get contextUsageEmpty => 'No context data yet — send a message first.';

  @override
  String get contextUsageOpen => 'Context usage';

  @override
  String get contextCatSystemPrompt => 'System prompt';

  @override
  String get contextCatToolDefinitions => 'Tool definitions';

  @override
  String get contextCatRules => 'Rules';

  @override
  String get contextCatSkills => 'Skills';

  @override
  String get contextCatMcp => 'MCP';

  @override
  String get contextCatSubagents => 'Subagent definitions';

  @override
  String get contextCatMemory => 'Memory';

  @override
  String get contextCatConversation => 'Conversation';

  @override
  String get refreshModels => 'Refresh models';

  @override
  String get skillsTitle => 'Installed skills on your gateway';

  @override
  String get filterSkills => 'Filter skills…';

  @override
  String get reloadSkills => 'Reload skills on gateway';

  @override
  String reloadFailed(String error) {
    return 'Reload failed: $error';
  }

  @override
  String get skillsSection => 'Skills';

  @override
  String get commandsSection => 'Commands';

  @override
  String get optionsSection => 'Options';

  @override
  String get privacyAndData => 'Privacy & data';

  @override
  String get privacyAndDataSubtitle =>
      'How gateway content and on-device data are handled';

  @override
  String get privacyDataFlow =>
      'Hermes Go sends conversations and attachments directly to the gateway you choose. That gateway may send them to the model providers and services configured by its owner.';

  @override
  String get privacyOnDevice =>
      'The app keeps connection metadata, encrypted session cookies, preferences, and a local transcript cache on this device. Disconnect removes saved connections and authentication data.';

  @override
  String get privacyNoAnalytics =>
      'This build contains no advertising or analytics SDK.';

  @override
  String get privacyPolicyMissing =>
      'Publisher action required: configure a public HTTPS privacy-policy URL before store submission.';

  @override
  String get openPrivacyPolicy => 'Open privacy policy';

  @override
  String get couldNotOpenLink => 'Could not open the link.';

  @override
  String get unofficialDisclaimer =>
      'Unofficial · Community-built · Not affiliated with Nous Research';

  @override
  String get noCachedJobs =>
      'No cached jobs yet.\nFix the connection and retry.';

  @override
  String get noCronJobs =>
      'No cron jobs on this gateway.\nCreate them on the host (`hermes cron` or Desktop).\nWhen they finish, this tab syncs and can notify you.';

  @override
  String get skillsPickerSubtitle =>
      'Installed on your gateway (hub, bundled, yours).\nCached on this phone if the network blips.\nTap to invoke as a slash command.';

  @override
  String get noSkillsCached =>
      'No skills cached yet.\nTap reload (needs a live gateway), or type /skills-name once slash autocomplete works.';

  @override
  String noSkillsMatch(String query) {
    return 'No skills match “$query”.';
  }

  @override
  String get commandCheatSheetTitle => 'Slash commands';

  @override
  String get commandCheatSheetSubtitle =>
      'Browse every /command Hermes supports';

  @override
  String get filterCommands => 'Filter commands…';

  @override
  String noCommandsMatch(String query) {
    return 'No commands match “$query”.';
  }

  @override
  String get commandBadgeCli => 'CLI';

  @override
  String get commandBadgeConfigGated => 'config';

  @override
  String get commandsLoadError =>
      'Couldn\'t load commands. Check your connection and try again.';

  @override
  String get modelPickerDetails =>
      'Same catalog as Desktop (/api/model/options · model.options).\nApplied to the open session on the gateway.';

  @override
  String couldNotLoadModels(String detail) {
    return 'Could not load models:\n$detail';
  }

  @override
  String get noModelsFromGateway =>
      'No models from this gateway.\nDesktop uses GET /api/model/options (session cookies). Configure providers on the host if the list is truly empty.';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String artifactOpenTooltip(String name) {
    return 'Open $name';
  }

  @override
  String get artifactKindMarkdown => 'Markdown';

  @override
  String get artifactKindHtml => 'HTML';

  @override
  String get artifactReload => 'Reload';

  @override
  String get artifactNotFound =>
      'File not found. It may have been moved or deleted on the gateway.';

  @override
  String get artifactAccessDenied => 'Access to this file is not allowed.';

  @override
  String get artifactTooLarge => 'This file is too large to preview here.';

  @override
  String get artifactLoadFailed => 'Couldn\'t load this file.';

  @override
  String get artifactEnableJs => 'Enable JavaScript';

  @override
  String get artifactEnableJsWarning =>
      'Off by default, and never remembered — only turn this on for documents you trust.';

  @override
  String get artifactOpenLinkTitle => 'Open link?';

  @override
  String artifactOpenLinkBody(String url) {
    return 'This opens $url in your browser, leaving Hermes Go.';
  }

  @override
  String get artifactOpenLinkAction => 'Open in Browser';

  @override
  String imageTapToLoad(String host) {
    return 'Tap to load image from $host';
  }

  @override
  String imageBlockedPrivateNetwork(String host) {
    return 'Image blocked — private network ($host)';
  }

  @override
  String get imageBlockedSource => 'Image blocked — unsupported source';

  @override
  String get imageLoadFailed => 'Image couldn\'t be loaded';
}
