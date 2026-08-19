// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Hermes Go';

  @override
  String get tagline => 'Vá mais longe. Fique conectado.';

  @override
  String get aboutBody =>
      'Hermes Go v0.1\nGo further. Stay connected.\nGateway connector — sessions, chat, models, jobs.';

  @override
  String failedToLoadConnection(String error) {
    return 'Failed to load connection: $error';
  }

  @override
  String get navSessions => 'Sessões';

  @override
  String get navBots => 'Bots';

  @override
  String get navJobs => 'Tarefas';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get botsTitle => 'Bots';

  @override
  String get botsEmpty => 'Ainda não há bots. Toque em + para criar um.';

  @override
  String get newBotTitle => 'Novo bot';

  @override
  String get newBotSubtitle =>
      'Um colega com nome, memória, habilidades e chat próprios.';

  @override
  String get botNameLabel => 'Nome';

  @override
  String get botNameHelper => 'Usado como identificador @';

  @override
  String get botNameTaken => 'Esse identificador já existe';

  @override
  String get botDescriptionLabel => 'Descrição';

  @override
  String get botAppearanceLabel => 'Aparência';

  @override
  String get createBotAction => 'Criar bot';

  @override
  String get creatingBot => 'Criando…';

  @override
  String get editBotAction => 'Editar perfil';

  @override
  String get editBotTitle => 'Editar bot';

  @override
  String get savingBot => 'Salvando…';

  @override
  String botHandleImmutable(String handle) {
    return '@$handle é o identificador permanente do bot para sessões e memória.';
  }

  @override
  String get botsNoConversation => 'Ainda não há conversas';

  @override
  String get botsCachedRoster =>
      'Mostrando a última lista enquanto o servidor reconecta.';

  @override
  String get modelLabel => 'Modelo';

  @override
  String get lastActivity => 'Última atividade';

  @override
  String get messagesLabel => 'Mensagens';

  @override
  String get settingsTitle => 'Ajustes';

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
  String get disconnect => 'Desconectar';

  @override
  String get disconnectSubtitle => 'Remove this gateway from the phone';

  @override
  String get disconnectConfirmTitle => 'Disconnect?';

  @override
  String get disconnectConfirmBody =>
      'Removes the saved gateway from this phone. Host agents are not affected.';

  @override
  String get exitSampleWorkspace => 'Sair do espaço de amostra';

  @override
  String get exitSampleWorkspaceSubtitle =>
      'Parar o sandbox e removê-lo deste telefone';

  @override
  String get exitSampleWorkspaceConfirmTitle => 'Sair do espaço de amostra?';

  @override
  String get exitSampleWorkspaceConfirmBody =>
      'Interrompe o gateway de amostra integrado e limpa suas sessões deste telefone. Nada sai do dispositivo.';

  @override
  String get sampleWorkspaceAboutLine =>
      'Espaço de amostra — conecte-se a demo.hermes.go (usuário demo, senha demo) para experimentar o Hermes Go sem configurar um gateway.';

  @override
  String get sampleWorkspaceBadge => 'Amostra';

  @override
  String get cancel => 'Cancelar';

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
  String get language => 'Idioma';

  @override
  String get languageSystem => 'Padrão do sistema';

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
  String get reconnect => 'Reconectar';

  @override
  String get reconnectNow => 'Reconnect now';

  @override
  String get checkNow => 'Check now';

  @override
  String get signIn => 'Entrar';

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
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Escuro';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get skinSectionDesktop => 'Desktop';

  @override
  String get skinSectionMobile => 'Mobile';

  @override
  String get required => 'Obrigatório';

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
      'A sessão do gateway expirou ou foi encerrada.\nDigite sua senha novamente para continuar — não reconectamos automaticamente após a expiração.';

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
  String get username => 'Usuário';

  @override
  String get password => 'Senha';

  @override
  String get continueAction => 'Continuar';

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
      'Nome de usuário e senha obrigatórios.';

  @override
  String signedInAs(String username) {
    return 'Sessão iniciada como $username';
  }

  @override
  String get gatewayNotReachable => 'Gateway not reachable.';

  @override
  String get chats => 'Chats';

  @override
  String get newChat => 'Novo chat';

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
  String get save => 'Salvar';

  @override
  String renameFailed(String error) {
    return 'Rename failed: $error';
  }

  @override
  String get deleteChatTitle => 'Delete chat?';

  @override
  String get delete => 'Excluir';

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
  String get greetingMorning => 'Bom dia';

  @override
  String get greetingAfternoon => 'Boa tarde';

  @override
  String get greetingEvening => 'Boa noite';

  @override
  String get messageHint => 'Mensagem para Hermes Go…';

  @override
  String get messageHintShort => 'Message…';

  @override
  String get sendAMessageToContinue => 'Send a message to continue.';

  @override
  String get sync => 'Sincronizar';

  @override
  String get stop => 'Parar';

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
  String get writing => 'Escrevendo…';

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
  String get deleteMessageTitle => 'Excluir mensagem?';

  @override
  String get deleteMessageBody =>
      'Isso não pode ser desfeito. O Hermes ainda não consegue excluir uma única mensagem no gateway, então ela é removida apenas deste dispositivo — o gateway mantém sua própria cópia e ela pode continuar aparecendo em outros lugares.';

  @override
  String get messageDeleted => 'Mensagem excluída (somente neste dispositivo)';

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
  String get privacyAndData => 'Privacidade e dados';

  @override
  String get privacyAndDataSubtitle =>
      'Como o conteúdo do gateway e os dados no dispositivo são tratados';

  @override
  String get privacyDataFlow =>
      'O Hermes Go envia conversas e anexos diretamente para o gateway escolhido. Esse gateway pode enviá-los aos provedores de modelos e serviços configurados pelo proprietário.';

  @override
  String get privacyOnDevice =>
      'O app mantém neste dispositivo metadados de conexão, cookies de sessão criptografados, preferências e um cache local das conversas. Desconectar remove as conexões salvas e os dados de autenticação.';

  @override
  String get privacyNoAnalytics =>
      'Esta versão não contém SDKs de publicidade ou análise.';

  @override
  String get privacyPolicyMissing =>
      'Ação necessária do publicador: configure uma URL HTTPS pública para a política de privacidade antes do envio à loja.';

  @override
  String get openPrivacyPolicy => 'Abrir política de privacidade';

  @override
  String get couldNotOpenLink => 'Não foi possível abrir o link.';

  @override
  String get unofficialDisclaimer =>
      'Não oficial · Desenvolvido pela comunidade · Não afiliado à Nous Research';

  @override
  String get noCachedJobs =>
      'Ainda não há tarefas em cache.\nCorrija a conexão e tente novamente.';

  @override
  String get noCronJobs =>
      'Não há tarefas cron neste gateway.\nCrie-as no host (`hermes cron` ou Desktop).\nQuando terminarem, esta aba será sincronizada e poderá avisar você.';

  @override
  String get skillsPickerSubtitle =>
      'Instaladas no seu gateway (hub, incluídas e suas).\nEm cache neste telefone quando a rede falha.\nToque para invocá-las como comando slash.';

  @override
  String get noSkillsCached =>
      'Ainda não há skills em cache.\nRecarregue quando o gateway estiver disponível ou digite /skills-name quando o autocompletar funcionar.';

  @override
  String noSkillsMatch(String query) {
    return 'Nenhuma skill corresponde a “$query”.';
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
      'Mesmo catálogo do Desktop (/api/model/options · model.options).\nAplicado à sessão aberta no gateway.';

  @override
  String couldNotLoadModels(String detail) {
    return 'Não foi possível carregar os modelos:\n$detail';
  }

  @override
  String get noModelsFromGateway =>
      'Nenhum modelo deste gateway.\nO Desktop usa GET /api/model/options (cookies de sessão). Configure provedores no host se a lista estiver realmente vazia.';

  @override
  String get notificationsTitle => 'Notificações';

  @override
  String artifactOpenTooltip(String name) {
    return 'Abrir $name';
  }

  @override
  String get artifactKindMarkdown => 'Markdown';

  @override
  String get artifactKindHtml => 'HTML';

  @override
  String get artifactReload => 'Recarregar';

  @override
  String get artifactNotFound =>
      'Arquivo não encontrado. Ele pode ter sido movido ou excluído no gateway.';

  @override
  String get artifactAccessDenied => 'O acesso a este arquivo não é permitido.';

  @override
  String get artifactTooLarge =>
      'Este arquivo é grande demais para pré-visualizar aqui.';

  @override
  String get artifactLoadFailed => 'Não foi possível carregar este arquivo.';

  @override
  String get artifactEnableJs => 'Ativar JavaScript';

  @override
  String get artifactEnableJsWarning =>
      'Desativado por padrão e nunca lembrado — ative apenas para documentos em que você confia.';

  @override
  String get artifactOpenLinkTitle => 'Abrir link?';

  @override
  String artifactOpenLinkBody(String url) {
    return 'Isso abrirá $url no seu navegador, saindo do Hermes Go.';
  }

  @override
  String get artifactOpenLinkAction => 'Abrir no navegador';

  @override
  String imageTapToLoad(String host) {
    return 'Toque para carregar a imagem de $host';
  }

  @override
  String imageBlockedPrivateNetwork(String host) {
    return 'Imagem bloqueada — rede privada ($host)';
  }

  @override
  String get imageBlockedSource => 'Imagem bloqueada — origem não suportada';

  @override
  String get imageLoadFailed => 'Não foi possível carregar a imagem';
}
