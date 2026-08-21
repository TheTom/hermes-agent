// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Hermes Go';

  @override
  String get tagline => 'Allez plus loin. Restez connecté.';

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
  String get navJobs => 'Tâches';

  @override
  String get navSettings => 'Réglages';

  @override
  String get botsTitle => 'Bots';

  @override
  String get botsEmpty =>
      'Aucun bot pour le moment. Touchez + pour en créer un.';

  @override
  String get newBotTitle => 'Nouveau bot';

  @override
  String get newBotSubtitle =>
      'Un coéquipier nommé avec sa propre mémoire, ses compétences et son chat.';

  @override
  String get botNameLabel => 'Nom';

  @override
  String get botNameHelper => 'Utilisé comme identifiant @';

  @override
  String get botNameTaken => 'Cet identifiant existe déjà';

  @override
  String get botDescriptionLabel => 'Description';

  @override
  String get botAppearanceLabel => 'Apparence';

  @override
  String get createBotAction => 'Créer le bot';

  @override
  String get creatingBot => 'Création…';

  @override
  String get editBotAction => 'Modifier le profil';

  @override
  String get editBotTitle => 'Modifier le bot';

  @override
  String get savingBot => 'Enregistrement…';

  @override
  String botHandleImmutable(String handle) {
    return '@$handle est l’identifiant permanent du bot pour les sessions et la mémoire.';
  }

  @override
  String get botsNoConversation => 'Aucune conversation pour le moment';

  @override
  String get botsCachedRoster =>
      'Affichage de la dernière liste pendant la reconnexion du serveur.';

  @override
  String get modelLabel => 'Modèle';

  @override
  String get lastActivity => 'Dernière activité';

  @override
  String get messagesLabel => 'Messages';

  @override
  String get settingsTitle => 'Réglages';

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
  String get disconnect => 'Déconnecter';

  @override
  String get disconnectSubtitle => 'Remove this gateway from the phone';

  @override
  String get disconnectConfirmTitle => 'Disconnect?';

  @override
  String get disconnectConfirmBody =>
      'Removes the saved gateway from this phone. Host agents are not affected.';

  @override
  String get exitSampleWorkspace => 'Quitter l\'espace d\'exemple';

  @override
  String get exitSampleWorkspaceSubtitle =>
      'Arrêter le bac à sable et le supprimer de ce téléphone';

  @override
  String get exitSampleWorkspaceConfirmTitle =>
      'Quitter l\'espace d\'exemple ?';

  @override
  String get exitSampleWorkspaceConfirmBody =>
      'Arrête la passerelle d\'exemple intégrée et efface ses sessions de ce téléphone. Rien ne quitte l\'appareil.';

  @override
  String get sampleWorkspaceAboutLine =>
      'Espace d\'exemple — connectez-vous à demo.hermes.go (utilisateur demo, mot de passe demo) pour essayer Hermes Go sans configurer de passerelle.';

  @override
  String get sampleWorkspaceBadge => 'Exemple';

  @override
  String get cancel => 'Annuler';

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
  String get about => 'À propos';

  @override
  String get couldNotOpenBrowser => 'Could not open browser — link copied';

  @override
  String get language => 'Langue';

  @override
  String get languageSystem => 'Langue du système';

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
  String get sessionExpired => 'Session expirée';

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
  String get notConnected => 'Non connecté';

  @override
  String get noGatewaySaved =>
      'No gateway saved on this phone. Sign in from Connect.';

  @override
  String get webSocket => 'WebSocket';

  @override
  String get live => 'En direct';

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
  String get reconnect => 'Reconnecter';

  @override
  String get reconnectNow => 'Reconnect now';

  @override
  String get checkNow => 'Check now';

  @override
  String get signIn => 'Connexion';

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
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get themeSystem => 'Système';

  @override
  String get skinSectionDesktop => 'Desktop';

  @override
  String get skinSectionMobile => 'Mobile';

  @override
  String get required => 'Obligatoire';

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
      'Votre session de passerelle a expiré ou a été fermée.\nSaisissez à nouveau votre mot de passe — aucune reconnexion automatique après expiration.';

  @override
  String get connectIntro =>
      'Connectez-vous à votre gateway Hermes — comme Desktop : URL, puis identifiant et mot de passe. Pas de clé API.';

  @override
  String get gatewayBaseUrl => 'URL de base du gateway';

  @override
  String get httpPrivateNetworkHint =>
      'Plain HTTP is allowed only on a trusted LAN or private VPN. Public remote access requires HTTPS.';

  @override
  String get urlRequired => 'URL required';

  @override
  String get provider => 'Provider';

  @override
  String get username => 'Identifiant';

  @override
  String get password => 'Mot de passe';

  @override
  String get continueAction => 'Continuer';

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
      'Nom d’utilisateur et mot de passe obligatoires.';

  @override
  String signedInAs(String username) {
    return 'Connecté en tant que $username';
  }

  @override
  String get gatewayNotReachable => 'Gateway not reachable.';

  @override
  String get chats => 'Chats';

  @override
  String get newChat => 'Nouveau chat';

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
  String get save => 'Enregistrer';

  @override
  String renameFailed(String error) {
    return 'Rename failed: $error';
  }

  @override
  String get deleteChatTitle => 'Delete chat?';

  @override
  String get delete => 'Supprimer';

  @override
  String get sessionIdCopied => 'Session ID copied';

  @override
  String get sessionActions => 'Session actions';

  @override
  String get pin => 'Épingler';

  @override
  String get unpin => 'Désépingler';

  @override
  String get copyId => 'Copy ID';

  @override
  String get export => 'Exporter';

  @override
  String get rename => 'Renommer';

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
  String get greetingMorning => 'Bonjour';

  @override
  String get greetingAfternoon => 'Bon après-midi';

  @override
  String get greetingEvening => 'Bonsoir';

  @override
  String get messageHint => 'Message à Hermes Go…';

  @override
  String get messageHintShort => 'Message…';

  @override
  String get sendAMessageToContinue => 'Send a message to continue.';

  @override
  String get sync => 'Sync';

  @override
  String get stop => 'Arrêter';

  @override
  String get dictate => 'Dicter';

  @override
  String get stopDictation => 'Stop dictation';

  @override
  String get listening => 'Écoute…';

  @override
  String get readAloudOn => 'Read aloud: on';

  @override
  String get readAloudOff => 'Read aloud: off';

  @override
  String get readAloud => 'Read aloud';

  @override
  String get addContext => 'Add context';

  @override
  String get photoLibrary => 'Photothèque';

  @override
  String get camera => 'Appareil photo';

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
  String get writing => 'Rédaction…';

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
  String get deleteMessageTitle => 'Supprimer le message ?';

  @override
  String get deleteMessageBody =>
      'Cette action est irréversible. Hermes ne peut pas encore supprimer un seul message sur la passerelle ; il est donc supprimé uniquement sur cet appareil — la passerelle conserve sa propre copie et il pourrait encore apparaître ailleurs.';

  @override
  String get messageDeleted => 'Message supprimé (sur cet appareil uniquement)';

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
  String get privacyAndData => 'Confidentialité et données';

  @override
  String get privacyAndDataSubtitle =>
      'Gestion du contenu de la passerelle et des données sur l’appareil';

  @override
  String get privacyDataFlow =>
      'Hermes Go envoie les conversations et les pièces jointes directement à la passerelle choisie. Cette passerelle peut les transmettre aux fournisseurs de modèles et aux services configurés par son propriétaire.';

  @override
  String get privacyOnDevice =>
      'L’app conserve sur cet appareil les métadonnées de connexion, les cookies de session chiffrés, les préférences et un cache local des conversations. La déconnexion supprime les connexions enregistrées et les données d’authentification.';

  @override
  String get privacyNoAnalytics =>
      'Cette version ne contient aucun SDK publicitaire ou analytique.';

  @override
  String get privacyPolicyMissing =>
      'Action requise de l’éditeur : configurez une URL HTTPS publique de politique de confidentialité avant la soumission au store.';

  @override
  String get openPrivacyPolicy => 'Ouvrir la politique de confidentialité';

  @override
  String get couldNotOpenLink => 'Impossible d’ouvrir le lien.';

  @override
  String get unofficialDisclaimer =>
      'Non officielle · Créée par la communauté · Sans affiliation avec Nous Research';

  @override
  String get noCachedJobs =>
      'Aucun travail en cache pour l’instant.\nRéparez la connexion et réessayez.';

  @override
  String get noCronJobs =>
      'Aucun travail cron sur cette passerelle.\nCréez-les sur l’hôte (`hermes cron` ou Desktop).\nÀ leur fin, cet onglet se synchronisera et pourra vous avertir.';

  @override
  String get skillsPickerSubtitle =>
      'Installées sur votre passerelle (hub, intégrées ou personnelles).\nMises en cache sur cet appareil en cas de coupure réseau.\nTouchez pour les invoquer comme commandes slash.';

  @override
  String get noSkillsCached =>
      'Aucune skill en cache pour l’instant.\nRechargez quand la passerelle est accessible, ou saisissez /skills-name lorsque l’autocomplétion fonctionne.';

  @override
  String noSkillsMatch(String query) {
    return 'Aucune skill ne correspond à « $query ».';
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
      'Même catalogue que Desktop (/api/model/options · model.options).\nAppliqué à la session ouverte sur la passerelle.';

  @override
  String couldNotLoadModels(String detail) {
    return 'Impossible de charger les modèles :\n$detail';
  }

  @override
  String get noModelsFromGateway =>
      'Aucun modèle sur cette passerelle.\nDesktop utilise GET /api/model/options (cookies de session). Configurez les fournisseurs sur l’hôte si la liste est vraiment vide.';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String artifactOpenTooltip(String name) {
    return 'Ouvrir $name';
  }

  @override
  String get artifactKindMarkdown => 'Markdown';

  @override
  String get artifactKindHtml => 'HTML';

  @override
  String get artifactReload => 'Recharger';

  @override
  String get artifactNotFound =>
      'Fichier introuvable. Il a peut-être été déplacé ou supprimé sur la passerelle.';

  @override
  String get artifactAccessDenied => 'L’accès à ce fichier n’est pas autorisé.';

  @override
  String get artifactTooLarge =>
      'Ce fichier est trop volumineux pour être prévisualisé ici.';

  @override
  String get artifactLoadFailed => 'Impossible de charger ce fichier.';

  @override
  String get artifactEnableJs => 'Activer JavaScript';

  @override
  String get artifactEnableJsWarning =>
      'Désactivé par défaut et jamais mémorisé — n’activez ceci que pour des documents de confiance.';

  @override
  String get artifactOpenLinkTitle => 'Ouvrir le lien ?';

  @override
  String artifactOpenLinkBody(String url) {
    return 'Cela ouvrira $url dans votre navigateur, en quittant Hermes Go.';
  }

  @override
  String get artifactOpenLinkAction => 'Ouvrir dans le navigateur';

  @override
  String imageTapToLoad(String host) {
    return 'Appuyez pour charger l’image depuis $host';
  }

  @override
  String imageBlockedPrivateNetwork(String host) {
    return 'Image bloquée — réseau privé ($host)';
  }

  @override
  String get imageBlockedSource => 'Image bloquée — source non prise en charge';

  @override
  String get imageLoadFailed => 'Impossible de charger l’image';
}
