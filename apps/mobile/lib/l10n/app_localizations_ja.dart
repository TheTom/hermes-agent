// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Hermes Go';

  @override
  String get tagline => 'もっと先へ。つながり続けよう。';

  @override
  String get aboutBody =>
      'Hermes Go v0.1\nGo further. Stay connected.\nGateway connector — sessions, chat, models, jobs.';

  @override
  String failedToLoadConnection(String error) {
    return 'Failed to load connection: $error';
  }

  @override
  String get navSessions => 'セッション';

  @override
  String get navBots => 'ボット';

  @override
  String get navJobs => 'ジョブ';

  @override
  String get navSettings => '設定';

  @override
  String get botsTitle => 'ボット';

  @override
  String get botsEmpty => 'ボットはまだありません。+ をタップして作成してください。';

  @override
  String get newBotTitle => '新しいボット';

  @override
  String get newBotSubtitle => '独自のメモリ、スキル、チャットを持つ名前付きの仲間です。';

  @override
  String get botNameLabel => '名前';

  @override
  String get botNameHelper => '@ハンドルとして使用されます';

  @override
  String get botNameTaken => 'そのハンドルは既に存在します';

  @override
  String get botDescriptionLabel => '説明';

  @override
  String get botAppearanceLabel => '外観';

  @override
  String get createBotAction => 'ボットを作成';

  @override
  String get creatingBot => '作成中…';

  @override
  String get editBotAction => 'プロフィールを編集';

  @override
  String get editBotTitle => 'ボットを編集';

  @override
  String get savingBot => '保存中…';

  @override
  String botHandleImmutable(String handle) {
    return '@$handle はセッションとメモリに使用されるボットの固定ハンドルです。';
  }

  @override
  String get botsNoConversation => 'まだ会話がありません';

  @override
  String get botsCachedRoster => 'サーバーの再接続中は最後の一覧を表示しています。';

  @override
  String get modelLabel => 'モデル';

  @override
  String get lastActivity => '最終アクティビティ';

  @override
  String get messagesLabel => 'メッセージ';

  @override
  String get settingsTitle => '設定';

  @override
  String get checkConnection => '接続を確認';

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
  String get disconnect => '切断';

  @override
  String get disconnectSubtitle => 'Remove this gateway from the phone';

  @override
  String get disconnectConfirmTitle => 'Disconnect?';

  @override
  String get disconnectConfirmBody =>
      'Removes the saved gateway from this phone. Host agents are not affected.';

  @override
  String get exitSampleWorkspace => 'サンプルワークスペースを終了';

  @override
  String get exitSampleWorkspaceSubtitle => 'サンドボックスを停止してこの端末から削除します';

  @override
  String get exitSampleWorkspaceConfirmTitle => 'サンプルワークスペースを終了しますか?';

  @override
  String get exitSampleWorkspaceConfirmBody =>
      '内蔵のサンプルゲートウェイを停止し、この端末からセッションを消去します。データは端末の外に送信されません。';

  @override
  String get sampleWorkspaceAboutLine =>
      'サンプルワークスペース — ゲートウェイを用意せずに Hermes Go を試すには、demo.hermes.go に接続してください(ユーザー名 demo、パスワード demo)。';

  @override
  String get sampleWorkspaceBadge => 'サンプル';

  @override
  String get cancel => 'キャンセル';

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
  String get syncNow => '今すぐ同期';

  @override
  String get syncNowSubtitle => 'Sessions, jobs, models, skills';

  @override
  String syncedWithSummary(String summary) {
    return 'Synced ($summary)';
  }

  @override
  String get about => '情報';

  @override
  String get couldNotOpenBrowser => 'Could not open browser — link copied';

  @override
  String get language => '言語';

  @override
  String get languageSystem => 'システムのデフォルト';

  @override
  String get languageSubtitle => 'アプリ UI の言語。チャット内容はエージェントに従います。';

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
  String get sessionExpired => 'セッションの期限切れ';

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
  String get notConnected => '未接続';

  @override
  String get noGatewaySaved =>
      'No gateway saved on this phone. Sign in from Connect.';

  @override
  String get webSocket => 'WebSocket';

  @override
  String get live => 'ライブ';

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
  String get host => 'ホスト';

  @override
  String get user => 'ユーザー';

  @override
  String get reconnect => '再接続';

  @override
  String get reconnectNow => 'Reconnect now';

  @override
  String get checkNow => 'Check now';

  @override
  String get signIn => 'サインイン';

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
  String get themeLight => 'ライト';

  @override
  String get themeDark => 'ダーク';

  @override
  String get themeSystem => 'システム';

  @override
  String get skinSectionDesktop => 'Desktop';

  @override
  String get skinSectionMobile => 'Mobile';

  @override
  String get required => '必須です';

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
  String get signInAgain => '再度サインイン';

  @override
  String get sessionExpiredBanner =>
      'ゲートウェイのセッションが期限切れになったか、サインアウトされました。\n続行するにはパスワードを再入力してください。期限切れ後に自動再接続は行いません。';

  @override
  String get connectIntro =>
      'Hermes ゲートウェイに接続 — Desktop と同じ：ベース URL、ユーザー名とパスワード。API キーは不要。';

  @override
  String get gatewayBaseUrl => 'ゲートウェイのベース URL';

  @override
  String get httpPrivateNetworkHint =>
      'Use unencrypted HTTP only on a trusted local network. Use HTTPS for remote access.';

  @override
  String get urlRequired => 'URL required';

  @override
  String get provider => 'プロバイダー';

  @override
  String get username => 'ユーザー名';

  @override
  String get password => 'パスワード';

  @override
  String get continueAction => '続行';

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
  String get usernamePasswordRequired => 'ユーザー名とパスワードが必要です。';

  @override
  String signedInAs(String username) {
    return '$username としてサインインしました';
  }

  @override
  String get gatewayNotReachable => 'Gateway not reachable.';

  @override
  String get chats => 'チャット';

  @override
  String get newChat => '新しいチャット';

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
  String get delete => '削除';

  @override
  String get sessionIdCopied => 'Session ID copied';

  @override
  String get sessionActions => 'Session actions';

  @override
  String get pin => 'ピン留め';

  @override
  String get unpin => 'ピン解除';

  @override
  String get copyId => 'Copy ID';

  @override
  String get export => '書き出し';

  @override
  String get rename => '名前を変更';

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
  String get greetingMorning => 'おはようございます';

  @override
  String get greetingAfternoon => 'こんにちは';

  @override
  String get greetingEvening => 'こんばんは';

  @override
  String get messageHint => 'Hermes Go にメッセージ…';

  @override
  String get messageHintShort => 'Message…';

  @override
  String get sendAMessageToContinue => 'Send a message to continue.';

  @override
  String get sync => '同期';

  @override
  String get stop => '停止';

  @override
  String get dictate => '音声入力';

  @override
  String get stopDictation => 'Stop dictation';

  @override
  String get listening => '聞き取り中…';

  @override
  String get readAloudOn => 'Read aloud: on';

  @override
  String get readAloudOff => 'Read aloud: off';

  @override
  String get readAloud => 'Read aloud';

  @override
  String get addContext => 'Add context';

  @override
  String get photoLibrary => '写真ライブラリ';

  @override
  String get camera => 'カメラ';

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
  String get writing => '作成中…';

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
  String get deleteMessageTitle => 'メッセージを削除しますか？';

  @override
  String get deleteMessageBody =>
      'この操作は取り消せません。Hermes はゲートウェイ上の個々のメッセージをまだ削除できないため、このデバイスからのみ削除されます。ゲートウェイには独自のコピーが残るため、他の場所には引き続き表示される場合があります。';

  @override
  String get messageDeleted => 'メッセージを削除しました（このデバイスのみ）';

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
  String get privacyAndData => 'プライバシーとデータ';

  @override
  String get privacyAndDataSubtitle => 'ゲートウェイのコンテンツと端末内データの取り扱い';

  @override
  String get privacyDataFlow =>
      'Hermes Go は会話と添付ファイルを、選択したゲートウェイへ直接送信します。そのゲートウェイは、所有者が設定したモデルプロバイダーやサービスへそれらを送信する場合があります。';

  @override
  String get privacyOnDevice =>
      'このアプリは接続メタデータ、暗号化されたセッション Cookie、設定、会話のローカルキャッシュを端末に保存します。切断すると、保存済みの接続と認証データが削除されます。';

  @override
  String get privacyNoAnalytics => 'このビルドには広告 SDK や分析 SDK は含まれていません。';

  @override
  String get privacyPolicyMissing =>
      '公開者による対応が必要です。ストアへ提出する前に、公開 HTTPS プライバシーポリシー URL を設定してください。';

  @override
  String get openPrivacyPolicy => 'プライバシーポリシーを開く';

  @override
  String get couldNotOpenLink => 'リンクを開けませんでした。';

  @override
  String get unofficialDisclaimer => '非公式 · コミュニティ製 · Nous Research とは無関係です';

  @override
  String get noCachedJobs => 'キャッシュされたジョブはまだありません。\n接続を確認して再試行してください。';

  @override
  String get noCronJobs =>
      'このゲートウェイに cron ジョブはありません。\nホストで (`hermes cron` または Desktop) 作成してください。\n完了するとこのタブで同期され、通知できます。';

  @override
  String get skillsPickerSubtitle =>
      'ゲートウェイにインストール済み（ハブ、同梱、自分のスキル）。\n通信が途切れた場合は端末にキャッシュされます。\nタップして slash コマンドとして呼び出します。';

  @override
  String get noSkillsCached =>
      'キャッシュされたスキルはまだありません。\nゲートウェイ接続時に再読み込みするか、自動補完が使えるようになったら /skills-name と入力してください。';

  @override
  String noSkillsMatch(String query) {
    return '「$query」に一致するスキルはありません。';
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
      'Desktop と同じカタログです（/api/model/options · model.options）。\nゲートウェイで開いているセッションに適用されます。';

  @override
  String couldNotLoadModels(String detail) {
    return 'モデルを読み込めませんでした:\n$detail';
  }

  @override
  String get noModelsFromGateway =>
      'このゲートウェイからモデルがありません。\nDesktop は GET /api/model/options（セッション Cookie）を使用します。リストが本当に空の場合はホストでプロバイダーを設定してください。';

  @override
  String get notificationsTitle => '通知';

  @override
  String artifactOpenTooltip(String name) {
    return '$name を開く';
  }

  @override
  String get artifactKindMarkdown => 'Markdown';

  @override
  String get artifactKindHtml => 'HTML';

  @override
  String get artifactReload => '再読み込み';

  @override
  String get artifactNotFound => 'ファイルが見つかりません。ゲートウェイ上で移動または削除された可能性があります。';

  @override
  String get artifactAccessDenied => 'このファイルへのアクセスは許可されていません。';

  @override
  String get artifactTooLarge => 'このファイルは大きすぎてここではプレビューできません。';

  @override
  String get artifactLoadFailed => 'このファイルを読み込めませんでした。';

  @override
  String get artifactEnableJs => 'JavaScriptを有効にする';

  @override
  String get artifactEnableJsWarning =>
      '既定でオフで、記憶されません — 信頼できるドキュメントのみで有効にしてください。';

  @override
  String get artifactOpenLinkTitle => 'リンクを開きますか？';

  @override
  String artifactOpenLinkBody(String url) {
    return 'Hermes Goを離れてブラウザで$urlを開きます。';
  }

  @override
  String get artifactOpenLinkAction => 'ブラウザで開く';

  @override
  String imageTapToLoad(String host) {
    return 'タップして $host から画像を読み込む';
  }

  @override
  String imageBlockedPrivateNetwork(String host) {
    return '画像をブロックしました — プライベートネットワーク（$host）';
  }

  @override
  String get imageBlockedSource => '画像をブロックしました — 未対応のソース';

  @override
  String get imageLoadFailed => '画像を読み込めませんでした';
}
