// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'Hermes Go';

  @override
  String get tagline => '더 멀리. 연결 유지.';

  @override
  String get aboutBody =>
      'Hermes Go v0.1\nGo further. Stay connected.\nGateway connector — sessions, chat, models, jobs.';

  @override
  String failedToLoadConnection(String error) {
    return 'Failed to load connection: $error';
  }

  @override
  String get navSessions => '세션';

  @override
  String get navBots => '봇';

  @override
  String get navJobs => '작업';

  @override
  String get navSettings => '설정';

  @override
  String get botsTitle => '봇';

  @override
  String get botsEmpty => '아직 봇이 없습니다. +를 눌러 만들어 주세요.';

  @override
  String get newBotTitle => '새 봇';

  @override
  String get newBotSubtitle => '자체 메모리, 기술, 채팅을 가진 이름 있는 팀원입니다.';

  @override
  String get botNameLabel => '이름';

  @override
  String get botNameHelper => '@핸들로 사용됩니다';

  @override
  String get botNameTaken => '이미 존재하는 핸들입니다';

  @override
  String get botDescriptionLabel => '설명';

  @override
  String get botAppearanceLabel => '모양';

  @override
  String get createBotAction => '봇 만들기';

  @override
  String get creatingBot => '만드는 중…';

  @override
  String get editBotAction => '프로필 편집';

  @override
  String get editBotTitle => '봇 편집';

  @override
  String get savingBot => '저장 중…';

  @override
  String botHandleImmutable(String handle) {
    return '@$handle은(는) 세션과 메모리에 사용되는 봇의 영구 핸들입니다.';
  }

  @override
  String get botsNoConversation => '아직 대화가 없습니다';

  @override
  String get botsCachedRoster => '서버가 다시 연결되는 동안 마지막 목록을 표시합니다.';

  @override
  String get modelLabel => '모델';

  @override
  String get lastActivity => '최근 활동';

  @override
  String get messagesLabel => '메시지';

  @override
  String get settingsTitle => '설정';

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
  String get disconnect => '연결 해제';

  @override
  String get disconnectSubtitle => 'Remove this gateway from the phone';

  @override
  String get disconnectConfirmTitle => 'Disconnect?';

  @override
  String get disconnectConfirmBody =>
      'Removes the saved gateway from this phone. Host agents are not affected.';

  @override
  String get exitSampleWorkspace => '샘플 작업 공간 종료';

  @override
  String get exitSampleWorkspaceSubtitle => '샌드박스를 중지하고 이 휴대폰에서 제거합니다';

  @override
  String get exitSampleWorkspaceConfirmTitle => '샘플 작업 공간을 종료하시겠습니까?';

  @override
  String get exitSampleWorkspaceConfirmBody =>
      '내장된 샘플 게이트웨이를 중지하고 이 휴대폰에서 세션을 지웁니다. 기기 밖으로 전송되는 데이터는 없습니다.';

  @override
  String get sampleWorkspaceAboutLine =>
      '샘플 작업 공간 — 게이트웨이를 설정하지 않고 Hermes Go를 사용해 보려면 demo.hermes.go(사용자 demo, 비밀번호 demo)에 연결하세요.';

  @override
  String get sampleWorkspaceBadge => '샘플';

  @override
  String get cancel => '취소';

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
  String get language => '언어';

  @override
  String get languageSystem => '시스템 기본값';

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
  String get reconnect => '다시 연결';

  @override
  String get reconnectNow => 'Reconnect now';

  @override
  String get checkNow => 'Check now';

  @override
  String get signIn => '로그인';

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
  String get themeLight => '라이트';

  @override
  String get themeDark => '다크';

  @override
  String get themeSystem => '시스템';

  @override
  String get skinSectionDesktop => 'Desktop';

  @override
  String get skinSectionMobile => 'Mobile';

  @override
  String get required => '필수 입력';

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
      '게이트웨이 세션이 만료되었거나 로그아웃되었습니다.\n계속하려면 비밀번호를 다시 입력하세요. 만료 후에는 자동으로 재연결하지 않습니다.';

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
  String get username => '사용자 이름';

  @override
  String get password => '비밀번호';

  @override
  String get continueAction => '계속';

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
  String get usernamePasswordRequired => '사용자 이름과 비밀번호가 필요합니다.';

  @override
  String signedInAs(String username) {
    return '$username(으)로 로그인됨';
  }

  @override
  String get gatewayNotReachable => 'Gateway not reachable.';

  @override
  String get chats => '채팅';

  @override
  String get newChat => '새 채팅';

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
  String get save => '저장';

  @override
  String renameFailed(String error) {
    return 'Rename failed: $error';
  }

  @override
  String get deleteChatTitle => 'Delete chat?';

  @override
  String get delete => '삭제';

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
  String get greetingMorning => '좋은 아침입니다';

  @override
  String get greetingAfternoon => '안녕하세요';

  @override
  String get greetingEvening => '좋은 저녁입니다';

  @override
  String get messageHint => 'Hermes Go에 메시지…';

  @override
  String get messageHintShort => 'Message…';

  @override
  String get sendAMessageToContinue => 'Send a message to continue.';

  @override
  String get sync => '동기화';

  @override
  String get stop => '중지';

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
  String get writing => '작성 중…';

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
  String get deleteMessageTitle => '메시지를 삭제할까요?';

  @override
  String get deleteMessageBody =>
      '이 작업은 되돌릴 수 없습니다. Hermes는 아직 게이트웨이에서 개별 메시지를 삭제할 수 없으므로 이 기기에서만 제거됩니다. 게이트웨이에는 자체 사본이 남아 있어 다른 곳에는 계속 표시될 수 있습니다.';

  @override
  String get messageDeleted => '메시지가 삭제되었습니다 (이 기기에서만)';

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
  String get privacyAndData => '개인정보 및 데이터';

  @override
  String get privacyAndDataSubtitle => '게이트웨이 콘텐츠와 기기 내 데이터 처리 방식';

  @override
  String get privacyDataFlow =>
      'Hermes Go는 대화와 첨부 파일을 사용자가 선택한 게이트웨이로 직접 전송합니다. 해당 게이트웨이는 소유자가 설정한 모델 제공업체와 서비스로 이를 전송할 수 있습니다.';

  @override
  String get privacyOnDevice =>
      '앱은 연결 메타데이터, 암호화된 세션 쿠키, 환경설정 및 대화의 로컬 캐시를 이 기기에 저장합니다. 연결을 해제하면 저장된 연결과 인증 데이터가 삭제됩니다.';

  @override
  String get privacyNoAnalytics => '이 빌드에는 광고 또는 분석 SDK가 포함되어 있지 않습니다.';

  @override
  String get privacyPolicyMissing =>
      '게시자 조치 필요: 스토어 제출 전에 공개 HTTPS 개인정보 처리방침 URL을 설정하세요.';

  @override
  String get openPrivacyPolicy => '개인정보 처리방침 열기';

  @override
  String get couldNotOpenLink => '링크를 열 수 없습니다.';

  @override
  String get unofficialDisclaimer => '비공식 · 커뮤니티 제작 · Nous Research와 제휴하지 않음';

  @override
  String get noCachedJobs => '아직 캐시된 작업이 없습니다.\n연결을 확인하고 다시 시도하세요.';

  @override
  String get noCronJobs =>
      '이 게이트웨이에 cron 작업이 없습니다.\n호스트에서 (`hermes cron` 또는 Desktop) 생성하세요.\n완료되면 이 탭에서 동기화하고 알림을 보낼 수 있습니다.';

  @override
  String get skillsPickerSubtitle =>
      '게이트웨이에 설치됨 (허브, 번들 및 내 스킬).\n네트워크가 끊기면 이 기기에 캐시됩니다.\n탭하여 slash 명령으로 호출하세요.';

  @override
  String get noSkillsCached =>
      '아직 캐시된 스킬이 없습니다.\n게이트웨이가 연결되면 새로고침하거나 자동 완성이 작동할 때 /skills-name을 입력하세요.';

  @override
  String noSkillsMatch(String query) {
    return '“$query”와 일치하는 스킬이 없습니다.';
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
      'Desktop와 같은 카탈로그입니다 (/api/model/options · model.options).\n게이트웨이에서 열린 세션에 적용됩니다.';

  @override
  String couldNotLoadModels(String detail) {
    return '모델을 불러올 수 없습니다:\n$detail';
  }

  @override
  String get noModelsFromGateway =>
      '이 게이트웨이에 모델이 없습니다.\nDesktop은 GET /api/model/options(세션 쿠키)를 사용합니다. 목록이 정말 비어 있다면 호스트에서 제공업체를 설정하세요.';

  @override
  String get notificationsTitle => '알림';

  @override
  String artifactOpenTooltip(String name) {
    return '$name 열기';
  }

  @override
  String get artifactKindMarkdown => 'Markdown';

  @override
  String get artifactKindHtml => 'HTML';

  @override
  String get artifactReload => '새로고침';

  @override
  String get artifactNotFound => '파일을 찾을 수 없습니다. 게이트웨이에서 이동되었거나 삭제되었을 수 있습니다.';

  @override
  String get artifactAccessDenied => '이 파일에 대한 접근이 허용되지 않습니다.';

  @override
  String get artifactTooLarge => '이 파일은 너무 커서 여기서 미리 볼 수 없습니다.';

  @override
  String get artifactLoadFailed => '이 파일을 불러오지 못했습니다.';

  @override
  String get artifactEnableJs => 'JavaScript 사용';

  @override
  String get artifactEnableJsWarning =>
      '기본적으로 꺼져 있으며 저장되지 않습니다 — 신뢰하는 문서에만 사용하세요.';

  @override
  String get artifactOpenLinkTitle => '링크를 여시겠습니까?';

  @override
  String artifactOpenLinkBody(String url) {
    return 'Hermes Go를 벗어나 브라우저에서 $url을(를) 엽니다.';
  }

  @override
  String get artifactOpenLinkAction => '브라우저에서 열기';

  @override
  String imageTapToLoad(String host) {
    return '탭하여 $host에서 이미지 불러오기';
  }

  @override
  String imageBlockedPrivateNetwork(String host) {
    return '이미지 차단됨 — 사설 네트워크($host)';
  }

  @override
  String get imageBlockedSource => '이미지 차단됨 — 지원되지 않는 소스';

  @override
  String get imageLoadFailed => '이미지를 불러올 수 없습니다';
}
