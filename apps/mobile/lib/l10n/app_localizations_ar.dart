// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'Hermes Go';

  @override
  String get tagline => 'انطلق أبعد. ابقَ متصلاً.';

  @override
  String get aboutBody =>
      'Hermes Go v0.1\nGo further. Stay connected.\nGateway connector — sessions, chat, models, jobs.';

  @override
  String failedToLoadConnection(String error) {
    return 'Failed to load connection: $error';
  }

  @override
  String get navSessions => 'الجلسات';

  @override
  String get navBots => 'الروبوتات';

  @override
  String get navJobs => 'مهام';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get botsTitle => 'الروبوتات';

  @override
  String get botsEmpty => 'لا توجد روبوتات بعد. اضغط + لإنشاء واحد.';

  @override
  String get newBotTitle => 'روبوت جديد';

  @override
  String get newBotSubtitle =>
      'زميل مُسمّى له ذاكرته ومهاراته ومحادثته الخاصة.';

  @override
  String get botNameLabel => 'الاسم';

  @override
  String get botNameHelper => 'يُستخدم كمعرّف @';

  @override
  String get botNameTaken => 'هذا المعرّف موجود بالفعل';

  @override
  String get botDescriptionLabel => 'الوصف';

  @override
  String get botAppearanceLabel => 'المظهر';

  @override
  String get createBotAction => 'إنشاء روبوت';

  @override
  String get creatingBot => 'جارٍ الإنشاء…';

  @override
  String get editBotAction => 'تعديل الملف الشخصي';

  @override
  String get editBotTitle => 'تعديل الروبوت';

  @override
  String get savingBot => 'جارٍ الحفظ…';

  @override
  String botHandleImmutable(String handle) {
    return '@$handle هو المعرّف الدائم للروبوت للجلسات والذاكرة.';
  }

  @override
  String get botsNoConversation => 'لا توجد محادثات بعد';

  @override
  String get botsCachedRoster => 'يتم عرض آخر قائمة أثناء إعادة اتصال الخادم.';

  @override
  String get modelLabel => 'النموذج';

  @override
  String get lastActivity => 'آخر نشاط';

  @override
  String get messagesLabel => 'الرسائل';

  @override
  String get settingsTitle => 'الإعدادات';

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
  String get disconnect => 'قطع الاتصال';

  @override
  String get disconnectSubtitle => 'Remove this gateway from the phone';

  @override
  String get disconnectConfirmTitle => 'Disconnect?';

  @override
  String get disconnectConfirmBody =>
      'Removes the saved gateway from this phone. Host agents are not affected.';

  @override
  String get exitSampleWorkspace => 'الخروج من مساحة العمل التجريبية';

  @override
  String get exitSampleWorkspaceSubtitle =>
      'إيقاف بيئة التجربة وإزالتها من هذا الهاتف';

  @override
  String get exitSampleWorkspaceConfirmTitle =>
      'الخروج من مساحة العمل التجريبية؟';

  @override
  String get exitSampleWorkspaceConfirmBody =>
      'يوقف بوابة العينة المدمجة ويمسح جلساتها من هذا الهاتف. لا تُرسل أي بيانات خارج الجهاز.';

  @override
  String get sampleWorkspaceAboutLine =>
      'مساحة عمل تجريبية — اتصل بـ demo.hermes.go (المستخدم demo، كلمة المرور demo) لتجربة Hermes Go بدون إعداد بوابة.';

  @override
  String get sampleWorkspaceBadge => 'تجريبي';

  @override
  String get cancel => 'إلغاء';

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
  String get language => 'اللغة';

  @override
  String get languageSystem => 'إعدادات النظام';

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
  String get reconnect => 'إعادة الاتصال';

  @override
  String get reconnectNow => 'Reconnect now';

  @override
  String get checkNow => 'Check now';

  @override
  String get signIn => 'تسجيل الدخول';

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
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String get themeSystem => 'النظام';

  @override
  String get skinSectionDesktop => 'Desktop';

  @override
  String get skinSectionMobile => 'Mobile';

  @override
  String get required => 'مطلوب';

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
      'انتهت جلسة البوابة أو تم تسجيل الخروج منها.\nأعد إدخال كلمة المرور للمتابعة — لا نعيد الاتصال تلقائياً بعد انتهاء الجلسة.';

  @override
  String get connectIntro =>
      'Connect to your Hermes gateway — same as Desktop: base URL, then username and password. No API key.';

  @override
  String get gatewayBaseUrl => 'Gateway base URL';

  @override
  String get httpPrivateNetworkHint =>
      'Use unencrypted HTTP only on a trusted local network. Use HTTPS for remote access.';

  @override
  String get urlRequired => 'URL required';

  @override
  String get provider => 'Provider';

  @override
  String get username => 'اسم المستخدم';

  @override
  String get password => 'كلمة المرور';

  @override
  String get continueAction => 'متابعة';

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
  String get usernamePasswordRequired => 'اسم المستخدم وكلمة المرور مطلوبان.';

  @override
  String signedInAs(String username) {
    return 'تم تسجيل الدخول باسم $username';
  }

  @override
  String get gatewayNotReachable => 'Gateway not reachable.';

  @override
  String get chats => 'المحادثات';

  @override
  String get newChat => 'محادثة جديدة';

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
  String get save => 'حفظ';

  @override
  String renameFailed(String error) {
    return 'Rename failed: $error';
  }

  @override
  String get deleteChatTitle => 'Delete chat?';

  @override
  String get delete => 'حذف';

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
  String get greetingMorning => 'صباح الخير';

  @override
  String get greetingAfternoon => 'مساء الخير';

  @override
  String get greetingEvening => 'مساء الخير';

  @override
  String get messageHint => 'رسالة إلى Hermes Go…';

  @override
  String get messageHintShort => 'Message…';

  @override
  String get sendAMessageToContinue => 'Send a message to continue.';

  @override
  String get sync => 'مزامنة';

  @override
  String get stop => 'إيقاف';

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
  String get writing => 'يكتب…';

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
  String get deleteMessageTitle => 'حذف الرسالة؟';

  @override
  String get deleteMessageBody =>
      'لا يمكن التراجع عن هذا الإجراء. لا يمكن لتطبيق Hermes حذف رسالة واحدة على البوابة بعد، لذا تتم إزالتها من هذا الجهاز فقط — تحتفظ البوابة بنسختها الخاصة وقد تظل تظهر في أماكن أخرى.';

  @override
  String get messageDeleted => 'تم حذف الرسالة (على هذا الجهاز فقط)';

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
  String get privacyAndData => 'الخصوصية والبيانات';

  @override
  String get privacyAndDataSubtitle =>
      'كيفية التعامل مع محتوى البوابة والبيانات الموجودة على الجهاز';

  @override
  String get privacyDataFlow =>
      'يرسل Hermes Go المحادثات والمرفقات مباشرةً إلى البوابة التي تختارها. وقد ترسلها تلك البوابة إلى موفري النماذج والخدمات التي يحددها مالكها.';

  @override
  String get privacyOnDevice =>
      'يحتفظ التطبيق على هذا الجهاز ببيانات الاتصال الوصفية وملفات تعريف ارتباط الجلسة المشفرة والتفضيلات ونسخة محلية مؤقتة من المحادثات. يؤدي قطع الاتصال إلى إزالة الاتصالات المحفوظة وبيانات المصادقة.';

  @override
  String get privacyNoAnalytics =>
      'لا يتضمن هذا الإصدار حزم SDK للإعلانات أو التحليلات.';

  @override
  String get privacyPolicyMissing =>
      'إجراء مطلوب من الناشر: يجب إعداد رابط HTTPS عام لسياسة الخصوصية قبل إرسال التطبيق إلى المتجر.';

  @override
  String get openPrivacyPolicy => 'فتح سياسة الخصوصية';

  @override
  String get couldNotOpenLink => 'تعذر فتح الرابط.';

  @override
  String get unofficialDisclaimer =>
      'غير رسمي · مبني من المجتمع · غير تابع لـ Nous Research';

  @override
  String get noCachedJobs =>
      'لا توجد مهام مخزنة مؤقتاً بعد.\nأصلح الاتصال وحاول مرة أخرى.';

  @override
  String get noCronJobs =>
      'لا توجد مهام cron على هذه البوابة.\nأنشئها على المضيف (`hermes cron` أو Desktop).\nعند اكتمالها، ستتم مزامنة هذه الصفحة ويمكنها إرسال إشعار.';

  @override
  String get skillsPickerSubtitle =>
      'المهارات المثبتة على بوابتك (المركزية والمضمنة والخاصة بك).\nتُخزّن مؤقتاً على الهاتف عند انقطاع الشبكة.\nاضغط لاستدعائها كأمر slash.';

  @override
  String get noSkillsCached =>
      'لا توجد مهارات مخزنة مؤقتاً بعد.\nأعد التحميل عند توفر البوابة أو اكتب /skills-name عند عمل الإكمال التلقائي.';

  @override
  String noSkillsMatch(String query) {
    return 'لا توجد مهارات تطابق «$query».';
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
      'نفس قائمة Desktop (/api/model/options · model.options).\nتُطبّق على الجلسة المفتوحة في البوابة.';

  @override
  String couldNotLoadModels(String detail) {
    return 'تعذر تحميل النماذج:\n$detail';
  }

  @override
  String get noModelsFromGateway =>
      'لا توجد نماذج من هذه البوابة.\nيستخدم Desktop ‏GET /api/model/options (ملفات تعريف ارتباط الجلسة). اضبط الموفرين على المضيف إذا كانت القائمة فارغة فعلاً.';

  @override
  String get notificationsTitle => 'الإشعارات';

  @override
  String artifactOpenTooltip(String name) {
    return 'فتح $name';
  }

  @override
  String get artifactKindMarkdown => 'Markdown';

  @override
  String get artifactKindHtml => 'HTML';

  @override
  String get artifactReload => 'إعادة التحميل';

  @override
  String get artifactNotFound =>
      'الملف غير موجود. ربما تم نقله أو حذفه على البوابة.';

  @override
  String get artifactAccessDenied => 'الوصول إلى هذا الملف غير مسموح.';

  @override
  String get artifactTooLarge => 'هذا الملف كبير جدًا للمعاينة هنا.';

  @override
  String get artifactLoadFailed => 'تعذر تحميل هذا الملف.';

  @override
  String get artifactEnableJs => 'تفعيل JavaScript';

  @override
  String get artifactEnableJsWarning =>
      'معطّل افتراضيًا ولا يُحفظ أبدًا — فعّله فقط للمستندات التي تثق بها.';

  @override
  String get artifactOpenLinkTitle => 'فتح الرابط؟';

  @override
  String artifactOpenLinkBody(String url) {
    return 'سيؤدي هذا إلى فتح $url في متصفحك، مغادرًا Hermes Go.';
  }

  @override
  String get artifactOpenLinkAction => 'فتح في المتصفح';

  @override
  String imageTapToLoad(String host) {
    return 'اضغط لتحميل الصورة من $host';
  }

  @override
  String imageBlockedPrivateNetwork(String host) {
    return 'تم حظر الصورة — شبكة خاصة ($host)';
  }

  @override
  String get imageBlockedSource => 'تم حظر الصورة — مصدر غير مدعوم';

  @override
  String get imageLoadFailed => 'تعذّر تحميل الصورة';
}
