// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Hermes Go';

  @override
  String get tagline => '走得更远。保持连接。';

  @override
  String get aboutBody =>
      'Hermes Go v0.1\nGo further. Stay connected.\nGateway connector — sessions, chat, models, jobs.';

  @override
  String failedToLoadConnection(String error) {
    return 'Failed to load connection: $error';
  }

  @override
  String get navSessions => '会话';

  @override
  String get navBots => '机器人';

  @override
  String get navJobs => '任务';

  @override
  String get navSettings => '设置';

  @override
  String get botsTitle => '机器人';

  @override
  String get botsEmpty => '还没有机器人。点按 + 即可创建。';

  @override
  String get newBotTitle => '新建机器人';

  @override
  String get newBotSubtitle => '拥有独立记忆、技能和聊天的命名队友。';

  @override
  String get botNameLabel => '名称';

  @override
  String get botNameHelper => '用作 @用户名';

  @override
  String get botNameTaken => '该用户名已存在';

  @override
  String get botDescriptionLabel => '描述';

  @override
  String get botAppearanceLabel => '外观';

  @override
  String get createBotAction => '创建机器人';

  @override
  String get creatingBot => '正在创建…';

  @override
  String get editBotAction => '编辑资料';

  @override
  String get editBotTitle => '编辑机器人';

  @override
  String get savingBot => '正在保存…';

  @override
  String botHandleImmutable(String handle) {
    return '@$handle 是该机器人用于会话和记忆的永久标识。';
  }

  @override
  String get botsNoConversation => '还没有对话';

  @override
  String get botsCachedRoster => '服务器重新连接时显示上次的列表。';

  @override
  String get modelLabel => '模型';

  @override
  String get lastActivity => '最近活动';

  @override
  String get messagesLabel => '消息';

  @override
  String get settingsTitle => '设置';

  @override
  String get checkConnection => '检查连接';

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
  String get disconnect => '断开';

  @override
  String get disconnectSubtitle => 'Remove this gateway from the phone';

  @override
  String get disconnectConfirmTitle => 'Disconnect?';

  @override
  String get disconnectConfirmBody =>
      'Removes the saved gateway from this phone. Host agents are not affected.';

  @override
  String get exitSampleWorkspace => '退出示例工作区';

  @override
  String get exitSampleWorkspaceSubtitle => '停止沙盒并从此手机中移除';

  @override
  String get exitSampleWorkspaceConfirmTitle => '退出示例工作区?';

  @override
  String get exitSampleWorkspaceConfirmBody => '停止内置示例网关并清除此手机上的会话。数据不会离开设备。';

  @override
  String get sampleWorkspaceAboutLine =>
      '示例工作区 — 连接到 demo.hermes.go(用户名 demo,密码 demo)即可在无需配置网关的情况下试用 Hermes Go。';

  @override
  String get sampleWorkspaceBadge => '示例';

  @override
  String get cancel => '取消';

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
  String get syncNow => '立即同步';

  @override
  String get syncNowSubtitle => 'Sessions, jobs, models, skills';

  @override
  String syncedWithSummary(String summary) {
    return 'Synced ($summary)';
  }

  @override
  String get about => '关于';

  @override
  String get couldNotOpenBrowser => 'Could not open browser — link copied';

  @override
  String get language => '语言';

  @override
  String get languageSystem => '跟随系统';

  @override
  String get languageSubtitle => '应用界面语言。聊天内容由智能体决定。';

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
  String get sessionExpired => '会话已过期';

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
  String get notConnected => '未连接';

  @override
  String get noGatewaySaved =>
      'No gateway saved on this phone. Sign in from Connect.';

  @override
  String get webSocket => 'WebSocket';

  @override
  String get live => '实时';

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
  String get reconnect => '重新连接';

  @override
  String get reconnectNow => 'Reconnect now';

  @override
  String get checkNow => 'Check now';

  @override
  String get signIn => '登录';

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
  String get themeLight => '浅色';

  @override
  String get themeDark => '深色';

  @override
  String get themeSystem => '系统';

  @override
  String get skinSectionDesktop => 'Desktop';

  @override
  String get skinSectionMobile => 'Mobile';

  @override
  String get required => '必填';

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
      '你的网关会话已过期或已退出登录。\n请重新输入密码以继续。会话过期后不会自动重新连接。';

  @override
  String get connectIntro =>
      '连接到你的 Hermes 网关 — 与 Desktop 相同：基础 URL，然后用户名和密码。无需 API 密钥。';

  @override
  String get gatewayBaseUrl => '网关基础 URL';

  @override
  String get httpPrivateNetworkHint =>
      'Plain HTTP is allowed only on a trusted LAN or private VPN. Public remote access requires HTTPS.';

  @override
  String get urlRequired => 'URL required';

  @override
  String get provider => 'Provider';

  @override
  String get username => '用户名';

  @override
  String get password => '密码';

  @override
  String get continueAction => '继续';

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
  String get usernamePasswordRequired => '需要用户名和密码。';

  @override
  String signedInAs(String username) {
    return '已作为 $username 登录';
  }

  @override
  String get gatewayNotReachable => 'Gateway not reachable.';

  @override
  String get chats => '对话';

  @override
  String get newChat => '新对话';

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
  String get save => '保存';

  @override
  String renameFailed(String error) {
    return 'Rename failed: $error';
  }

  @override
  String get deleteChatTitle => 'Delete chat?';

  @override
  String get delete => '删除';

  @override
  String get sessionIdCopied => 'Session ID copied';

  @override
  String get sessionActions => 'Session actions';

  @override
  String get pin => '置顶';

  @override
  String get unpin => '取消置顶';

  @override
  String get copyId => 'Copy ID';

  @override
  String get export => '导出';

  @override
  String get rename => '重命名';

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
  String get greetingMorning => '早上好';

  @override
  String get greetingAfternoon => '下午好';

  @override
  String get greetingEvening => '晚上好';

  @override
  String get messageHint => '给 Hermes Go 发消息…';

  @override
  String get messageHintShort => 'Message…';

  @override
  String get sendAMessageToContinue => 'Send a message to continue.';

  @override
  String get sync => '同步';

  @override
  String get stop => '停止';

  @override
  String get dictate => '语音输入';

  @override
  String get stopDictation => 'Stop dictation';

  @override
  String get listening => '正在聆听…';

  @override
  String get readAloudOn => 'Read aloud: on';

  @override
  String get readAloudOff => 'Read aloud: off';

  @override
  String get readAloud => 'Read aloud';

  @override
  String get addContext => 'Add context';

  @override
  String get photoLibrary => '照片图库';

  @override
  String get camera => '相机';

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
  String get writing => '撰写中…';

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
  String get deleteMessageTitle => '删除这条消息？';

  @override
  String get deleteMessageBody =>
      '此操作无法撤销。Hermes 目前还无法在网关上删除单条消息，因此只会从此设备中移除——网关会保留自己的副本，该消息可能仍会出现在其他地方。';

  @override
  String get messageDeleted => '消息已删除（仅限此设备）';

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
  String get privacyAndData => '隐私与数据';

  @override
  String get privacyAndDataSubtitle => '网关内容和设备本地数据的处理方式';

  @override
  String get privacyDataFlow =>
      'Hermes Go 会将对话和附件直接发送到你选择的网关。该网关可能会将它们发送给网关所有者配置的模型提供商和服务。';

  @override
  String get privacyOnDevice =>
      '本应用会在此设备上保存连接元数据、加密的会话 Cookie、偏好设置和本地对话缓存。断开连接会删除已保存的连接和身份验证数据。';

  @override
  String get privacyNoAnalytics => '此版本不包含广告或分析 SDK。';

  @override
  String get privacyPolicyMissing => '发布者需要采取操作：在提交应用商店前，请配置公开的 HTTPS 隐私政策网址。';

  @override
  String get openPrivacyPolicy => '打开隐私政策';

  @override
  String get couldNotOpenLink => '无法打开链接。';

  @override
  String get unofficialDisclaimer => '非官方 · 社区构建 · 与 Nous Research 无关联';

  @override
  String get noCachedJobs => '暂时没有缓存的任务。\n请修复连接后重试。';

  @override
  String get noCronJobs =>
      '此网关没有 cron 任务。\n请在主机上（`hermes cron` 或 Desktop）创建任务。\n任务完成后，此页面会同步并可发送通知。';

  @override
  String get skillsPickerSubtitle =>
      '已安装在你的网关上（中心、内置和自有技能）。\n网络中断时会缓存到此设备。\n点击即可作为 slash 命令调用。';

  @override
  String get noSkillsCached =>
      '暂时没有缓存的技能。\n网关可用后重新加载，或在 slash 自动补全可用时输入 /skills-name。';

  @override
  String noSkillsMatch(String query) {
    return '没有匹配“$query”的技能。';
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
      '与 Desktop 使用相同的目录（/api/model/options · model.options）。\n应用于网关上的当前会话。';

  @override
  String couldNotLoadModels(String detail) {
    return '无法加载模型：\n$detail';
  }

  @override
  String get noModelsFromGateway =>
      '此网关没有模型。\nDesktop 使用 GET /api/model/options（会话 Cookie）。如果列表确实为空，请在主机上配置提供商。';

  @override
  String get notificationsTitle => '通知';

  @override
  String artifactOpenTooltip(String name) {
    return '打开 $name';
  }

  @override
  String get artifactKindMarkdown => 'Markdown';

  @override
  String get artifactKindHtml => 'HTML';

  @override
  String get artifactReload => '重新加载';

  @override
  String get artifactNotFound => '未找到文件。它可能已在网关上被移动或删除。';

  @override
  String get artifactAccessDenied => '不允许访问此文件。';

  @override
  String get artifactTooLarge => '此文件过大，无法在此预览。';

  @override
  String get artifactLoadFailed => '无法加载此文件。';

  @override
  String get artifactEnableJs => '启用 JavaScript';

  @override
  String get artifactEnableJsWarning => '默认关闭，且不会被记住 — 仅对你信任的文档启用。';

  @override
  String get artifactOpenLinkTitle => '打开链接？';

  @override
  String artifactOpenLinkBody(String url) {
    return '这将在浏览器中打开 $url，并离开 Hermes Go。';
  }

  @override
  String get artifactOpenLinkAction => '在浏览器中打开';

  @override
  String imageTapToLoad(String host) {
    return '点按以从 $host 加载图片';
  }

  @override
  String imageBlockedPrivateNetwork(String host) {
    return '图片已拦截 — 私有网络（$host）';
  }

  @override
  String get imageBlockedSource => '图片已拦截 — 不支持的来源';

  @override
  String get imageLoadFailed => '无法加载图片';
}
