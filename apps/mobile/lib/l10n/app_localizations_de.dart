// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Hermes Go';

  @override
  String get tagline => 'Geh weiter. Bleib verbunden.';

  @override
  String get aboutBody =>
      'Hermes Go v0.1\nGo further. Stay connected.\nGateway connector — sessions, chat, models, jobs.';

  @override
  String failedToLoadConnection(String error) {
    return 'Failed to load connection: $error';
  }

  @override
  String get navSessions => 'Sitzungen';

  @override
  String get navBots => 'Bots';

  @override
  String get navJobs => 'Jobs';

  @override
  String get navSettings => 'Einstellungen';

  @override
  String get botsTitle => 'Bots';

  @override
  String get botsEmpty =>
      'Noch keine Bots. Tippe auf +, um einen zu erstellen.';

  @override
  String get newBotTitle => 'Neuer Bot';

  @override
  String get newBotSubtitle =>
      'Ein benannter Teamkollege mit eigenem Gedächtnis, Fähigkeiten und Chat.';

  @override
  String get botNameLabel => 'Name';

  @override
  String get botNameHelper => 'Wird als @Handle verwendet';

  @override
  String get botNameTaken => 'Dieses Handle existiert bereits';

  @override
  String get botDescriptionLabel => 'Beschreibung';

  @override
  String get botAppearanceLabel => 'Erscheinungsbild';

  @override
  String get createBotAction => 'Bot erstellen';

  @override
  String get creatingBot => 'Wird erstellt…';

  @override
  String get editBotAction => 'Profil bearbeiten';

  @override
  String get editBotTitle => 'Bot bearbeiten';

  @override
  String get savingBot => 'Wird gespeichert…';

  @override
  String botHandleImmutable(String handle) {
    return '@$handle ist das permanente Bot-Handle für Sitzungen und Erinnerungen.';
  }

  @override
  String get botsNoConversation => 'Noch keine Unterhaltungen';

  @override
  String get botsCachedRoster =>
      'Die letzte Liste wird angezeigt, während der Server neu verbindet.';

  @override
  String get modelLabel => 'Modell';

  @override
  String get lastActivity => 'Letzte Aktivität';

  @override
  String get messagesLabel => 'Nachrichten';

  @override
  String get settingsTitle => 'Einstellungen';

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
  String get disconnect => 'Trennen';

  @override
  String get disconnectSubtitle => 'Remove this gateway from the phone';

  @override
  String get disconnectConfirmTitle => 'Disconnect?';

  @override
  String get disconnectConfirmBody =>
      'Removes the saved gateway from this phone. Host agents are not affected.';

  @override
  String get exitSampleWorkspace => 'Beispielarbeitsbereich verlassen';

  @override
  String get exitSampleWorkspaceSubtitle =>
      'Sandbox stoppen und vom Telefon entfernen';

  @override
  String get exitSampleWorkspaceConfirmTitle =>
      'Beispielarbeitsbereich verlassen?';

  @override
  String get exitSampleWorkspaceConfirmBody =>
      'Stoppt das integrierte Beispiel-Gateway und löscht dessen Sitzungen von diesem Telefon. Es verlässt nichts das Gerät.';

  @override
  String get sampleWorkspaceAboutLine =>
      'Beispielarbeitsbereich — verbinde dich mit demo.hermes.go (Benutzer demo, Passwort demo), um Hermes Go ohne Gateway-Einrichtung auszuprobieren.';

  @override
  String get sampleWorkspaceBadge => 'Beispiel';

  @override
  String get cancel => 'Abbrechen';

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
  String get about => 'Info';

  @override
  String get couldNotOpenBrowser => 'Could not open browser — link copied';

  @override
  String get language => 'Sprache';

  @override
  String get languageSystem => 'Systemstandard';

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
  String get sessionExpired => 'Sitzung abgelaufen';

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
  String get notConnected => 'Nicht verbunden';

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
  String get reconnect => 'Erneut verbinden';

  @override
  String get reconnectNow => 'Reconnect now';

  @override
  String get checkNow => 'Check now';

  @override
  String get signIn => 'Anmelden';

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
  String get themeLight => 'Hell';

  @override
  String get themeDark => 'Dunkel';

  @override
  String get themeSystem => 'System';

  @override
  String get skinSectionDesktop => 'Desktop';

  @override
  String get skinSectionMobile => 'Mobile';

  @override
  String get required => 'Erforderlich';

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
      'Deine Gateway-Sitzung ist abgelaufen oder wurde abgemeldet.\nGib dein Passwort erneut ein — nach Ablauf wird nicht automatisch neu verbunden.';

  @override
  String get connectIntro =>
      'Mit deinem Hermes-Gateway verbinden — wie Desktop: Basis-URL, dann Benutzername und Passwort. Kein API-Schlüssel.';

  @override
  String get gatewayBaseUrl => 'Gateway-Basis-URL';

  @override
  String get httpPrivateNetworkHint =>
      'Plain HTTP is allowed only on a trusted LAN or private VPN. Public remote access requires HTTPS.';

  @override
  String get urlRequired => 'URL required';

  @override
  String get provider => 'Provider';

  @override
  String get username => 'Benutzername';

  @override
  String get password => 'Passwort';

  @override
  String get continueAction => 'Weiter';

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
  String get usernamePasswordRequired =>
      'Benutzername und Passwort erforderlich.';

  @override
  String signedInAs(String username) {
    return 'Angemeldet als $username';
  }

  @override
  String get gatewayNotReachable => 'Gateway not reachable.';

  @override
  String get chats => 'Chats';

  @override
  String get newChat => 'Neuer Chat';

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
  String get save => 'Speichern';

  @override
  String renameFailed(String error) {
    return 'Rename failed: $error';
  }

  @override
  String get deleteChatTitle => 'Delete chat?';

  @override
  String get delete => 'Löschen';

  @override
  String get sessionIdCopied => 'Session ID copied';

  @override
  String get sessionActions => 'Session actions';

  @override
  String get pin => 'Anheften';

  @override
  String get unpin => 'Lösen';

  @override
  String get copyId => 'Copy ID';

  @override
  String get export => 'Exportieren';

  @override
  String get rename => 'Umbenennen';

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
  String get greetingMorning => 'Guten Morgen';

  @override
  String get greetingAfternoon => 'Guten Tag';

  @override
  String get greetingEvening => 'Guten Abend';

  @override
  String get messageHint => 'Nachricht an Hermes Go…';

  @override
  String get messageHintShort => 'Message…';

  @override
  String get sendAMessageToContinue => 'Send a message to continue.';

  @override
  String get sync => 'Sync';

  @override
  String get stop => 'Stopp';

  @override
  String get dictate => 'Diktieren';

  @override
  String get stopDictation => 'Stop dictation';

  @override
  String get listening => 'Hört zu…';

  @override
  String get readAloudOn => 'Read aloud: on';

  @override
  String get readAloudOff => 'Read aloud: off';

  @override
  String get readAloud => 'Read aloud';

  @override
  String get addContext => 'Add context';

  @override
  String get photoLibrary => 'Mediathek';

  @override
  String get camera => 'Kamera';

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
  String get writing => 'Schreibe…';

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
  String get deleteMessageTitle => 'Nachricht löschen?';

  @override
  String get deleteMessageBody =>
      'Dies kann nicht rückgängig gemacht werden. Hermes kann einzelne Nachrichten auf dem Gateway noch nicht löschen, daher wird sie nur auf diesem Gerät entfernt — das Gateway behält seine eigene Kopie, und die Nachricht kann anderswo weiterhin erscheinen.';

  @override
  String get messageDeleted => 'Nachricht gelöscht (nur auf diesem Gerät)';

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
  String get privacyAndData => 'Datenschutz & Daten';

  @override
  String get privacyAndDataSubtitle =>
      'Umgang mit Gateway-Inhalten und Gerätedaten';

  @override
  String get privacyDataFlow =>
      'Hermes Go sendet Unterhaltungen und Anhänge direkt an das von dir gewählte Gateway. Dieses Gateway kann sie an die vom Betreiber konfigurierten Modellanbieter und Dienste weiterleiten.';

  @override
  String get privacyOnDevice =>
      'Die App speichert Verbindungsmetadaten, verschlüsselte Sitzungscookies, Einstellungen und einen lokalen Unterhaltungs-Cache auf diesem Gerät. Beim Trennen werden gespeicherte Verbindungen und Authentifizierungsdaten entfernt.';

  @override
  String get privacyNoAnalytics =>
      'Diese Version enthält keine Werbe- oder Analyse-SDKs.';

  @override
  String get privacyPolicyMissing =>
      'Aktion des Herausgebers erforderlich: Vor der Store-Einreichung muss eine öffentliche HTTPS-Datenschutz-URL konfiguriert werden.';

  @override
  String get openPrivacyPolicy => 'Datenschutzerklärung öffnen';

  @override
  String get couldNotOpenLink => 'Der Link konnte nicht geöffnet werden.';

  @override
  String get unofficialDisclaimer =>
      'Inoffiziell · Von der Community entwickelt · Nicht mit Nous Research verbunden';

  @override
  String get noCachedJobs =>
      'Noch keine zwischengespeicherten Aufgaben.\nBehebe die Verbindung und versuche es erneut.';

  @override
  String get noCronJobs =>
      'Keine Cron-Aufgaben auf diesem Gateway.\nErstelle sie auf dem Host (`hermes cron` oder Desktop).\nNach Abschluss wird dieser Tab synchronisiert und kann dich benachrichtigen.';

  @override
  String get skillsPickerSubtitle =>
      'Auf deinem Gateway installiert (Hub, enthaltene und eigene Skills).\nBei Netzproblemen auf diesem Telefon zwischengespeichert.\nTippe, um sie als Slash-Befehl aufzurufen.';

  @override
  String get noSkillsCached =>
      'Noch keine Skills im Cache.\nLade neu, wenn das Gateway erreichbar ist, oder gib /skills-name ein, sobald die Autovervollständigung funktioniert.';

  @override
  String noSkillsMatch(String query) {
    return 'Keine Skills passen zu „$query“.';
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
      'Derselbe Katalog wie in Desktop (/api/model/options · model.options).\nWird auf die offene Sitzung am Gateway angewendet.';

  @override
  String couldNotLoadModels(String detail) {
    return 'Modelle konnten nicht geladen werden:\n$detail';
  }

  @override
  String get noModelsFromGateway =>
      'Keine Modelle von diesem Gateway.\nDesktop verwendet GET /api/model/options (Sitzungscookies). Konfiguriere Anbieter auf dem Host, wenn die Liste wirklich leer ist.';

  @override
  String get notificationsTitle => 'Benachrichtigungen';

  @override
  String artifactOpenTooltip(String name) {
    return '$name öffnen';
  }

  @override
  String get artifactKindMarkdown => 'Markdown';

  @override
  String get artifactKindHtml => 'HTML';

  @override
  String get artifactReload => 'Neu laden';

  @override
  String get artifactNotFound =>
      'Datei nicht gefunden. Sie wurde möglicherweise auf dem Gateway verschoben oder gelöscht.';

  @override
  String get artifactAccessDenied =>
      'Der Zugriff auf diese Datei ist nicht erlaubt.';

  @override
  String get artifactTooLarge => 'Diese Datei ist zu groß für eine Vorschau.';

  @override
  String get artifactLoadFailed => 'Datei konnte nicht geladen werden.';

  @override
  String get artifactEnableJs => 'JavaScript aktivieren';

  @override
  String get artifactEnableJsWarning =>
      'Standardmäßig aus und wird nie gespeichert — aktiviere dies nur für Dokumente, denen du vertraust.';

  @override
  String get artifactOpenLinkTitle => 'Link öffnen?';

  @override
  String artifactOpenLinkBody(String url) {
    return 'Dies öffnet $url in deinem Browser und verlässt Hermes Go.';
  }

  @override
  String get artifactOpenLinkAction => 'Im Browser öffnen';

  @override
  String imageTapToLoad(String host) {
    return 'Zum Laden des Bildes von $host tippen';
  }

  @override
  String imageBlockedPrivateNetwork(String host) {
    return 'Bild blockiert — privates Netzwerk ($host)';
  }

  @override
  String get imageBlockedSource => 'Bild blockiert — nicht unterstützte Quelle';

  @override
  String get imageLoadFailed => 'Bild konnte nicht geladen werden';
}
