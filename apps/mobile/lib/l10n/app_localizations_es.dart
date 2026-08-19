// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Hermes Go';

  @override
  String get tagline => 'Ve más lejos. Mantente conectado.';

  @override
  String get aboutBody =>
      'Hermes Go v0.1\nVe más lejos. Mantente conectado.\nConector de gateway — sesiones, chat, modelos, trabajos.';

  @override
  String failedToLoadConnection(String error) {
    return 'No se pudo cargar la conexión: $error';
  }

  @override
  String get navSessions => 'Sesiones';

  @override
  String get navBots => 'Bots';

  @override
  String get navJobs => 'Trabajos';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get botsTitle => 'Bots';

  @override
  String get botsEmpty => 'Aún no hay bots. Toca + para crear uno.';

  @override
  String get newBotTitle => 'Nuevo bot';

  @override
  String get newBotSubtitle =>
      'Un compañero con nombre, memoria, habilidades y chat propios.';

  @override
  String get botNameLabel => 'Nombre';

  @override
  String get botNameHelper => 'Se usa como @identificador';

  @override
  String get botNameTaken => 'Ese identificador ya existe';

  @override
  String get botDescriptionLabel => 'Descripción';

  @override
  String get botAppearanceLabel => 'Apariencia';

  @override
  String get createBotAction => 'Crear bot';

  @override
  String get creatingBot => 'Creando…';

  @override
  String get editBotAction => 'Editar perfil';

  @override
  String get editBotTitle => 'Editar bot';

  @override
  String get savingBot => 'Guardando…';

  @override
  String botHandleImmutable(String handle) {
    return '@$handle es el identificador permanente del bot para sesiones y memoria.';
  }

  @override
  String get botsNoConversation => 'Aún no hay conversaciones';

  @override
  String get botsCachedRoster =>
      'Mostrando la última lista mientras el servidor se reconecta.';

  @override
  String get modelLabel => 'Modelo';

  @override
  String get lastActivity => 'Última actividad';

  @override
  String get messagesLabel => 'Mensajes';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get checkConnection => 'Comprobar conexión';

  @override
  String get liveChatReady => 'En vivo — chat listo';

  @override
  String get notLiveSeeStatus => 'Sin conexión en vivo — ver estado';

  @override
  String get wsConnectedChatReady => 'WebSocket conectado — chat listo';

  @override
  String get stillOffline => 'Sigue sin conexión';

  @override
  String get apiToken => 'Token de API';

  @override
  String get refreshSignIn => 'Volver a iniciar sesión';

  @override
  String get refreshSignInSubtitle =>
      'Vuelve a introducir la contraseña (p. ej. tras un cierre en el host). No es automático.';

  @override
  String get disconnect => 'Desconectar';

  @override
  String get disconnectSubtitle => 'Quitar este gateway del teléfono';

  @override
  String get disconnectConfirmTitle => '¿Desconectar?';

  @override
  String get disconnectConfirmBody =>
      'Elimina el gateway guardado de este teléfono. Los agentes del host no se ven afectados.';

  @override
  String get exitSampleWorkspace => 'Salir del espacio de muestra';

  @override
  String get exitSampleWorkspaceSubtitle =>
      'Detener la zona de pruebas y eliminarla de este teléfono';

  @override
  String get exitSampleWorkspaceConfirmTitle =>
      '¿Salir del espacio de muestra?';

  @override
  String get exitSampleWorkspaceConfirmBody =>
      'Detiene el gateway de muestra integrado y borra sus sesiones de este teléfono. Nada sale del dispositivo.';

  @override
  String get sampleWorkspaceAboutLine =>
      'Espacio de muestra — conéctate a demo.hermes.go (usuario demo, contraseña demo) para probar Hermes Go sin configurar un gateway.';

  @override
  String get sampleWorkspaceBadge => 'Muestra';

  @override
  String get cancel => 'Cancelar';

  @override
  String get theme => 'Tema';

  @override
  String get appearance => 'Apariencia';

  @override
  String get appearanceSubtitle =>
      'Mismos temas integrados que Desktop (Nous, Midnight, Ember, …).';

  @override
  String get hapticsSounds => 'Háptica y sonidos';

  @override
  String get hapticsOff => 'Desactivado — sin toques ni sonido';

  @override
  String get hapticsOn =>
      'Activado — toques, envío/parada y chime de respuesta';

  @override
  String get previewHaptics => 'Probar háptica y sonido';

  @override
  String get syncNow => 'Sincronizar ahora';

  @override
  String get syncNowSubtitle => 'Sesiones, trabajos, modelos, skills';

  @override
  String syncedWithSummary(String summary) {
    return 'Sincronizado ($summary)';
  }

  @override
  String get about => 'Acerca de';

  @override
  String get couldNotOpenBrowser =>
      'No se pudo abrir el navegador — enlace copiado';

  @override
  String get language => 'Idioma';

  @override
  String get languageSystem => 'Predeterminado del sistema';

  @override
  String get languageSubtitle =>
      'Idioma de la interfaz. El contenido del chat lo define el agente.';

  @override
  String get connectedChatReady => 'Conectado · chat listo';

  @override
  String get connectedChatReadyBody =>
      'WebSocket en vivo con el gateway. Mensajes y comandos slash funcionan.';

  @override
  String get signedInChatOffline => 'Sesión iniciada · chat sin conexión';

  @override
  String get signedInReconnecting => 'Sesión iniciada · reconectando';

  @override
  String get autoReconnectGaveUp =>
      'La reconexión automática se detuvo. Toca Reconectar o comprueba que el host sea accesible.';

  @override
  String get signedInChatOfflineBody =>
      'HTTPS/cookies pueden listar datos, pero el WebSocket en vivo está caído. Reintento con backoff; o toca Reconectar.';

  @override
  String get sessionExpired => 'Sesión caducada';

  @override
  String get sessionExpiredBody =>
      'Inicia sesión de nuevo. Puede ser intencional (cierre en el host).';

  @override
  String get gaveUpReconnecting => 'Se abandonó la reconexión';

  @override
  String get connectionProblem => 'Problema de conexión';

  @override
  String get cannotReachGateway =>
      'No se puede alcanzar el gateway. Revisa la dirección, la conexión de red y que el host esté encendido.';

  @override
  String get notConnected => 'Sin conexión';

  @override
  String get noGatewaySaved =>
      'No hay gateway guardado en este teléfono. Inicia sesión en Conectar.';

  @override
  String get webSocket => 'WebSocket';

  @override
  String get live => 'En vivo';

  @override
  String get httpsRest => 'HTTPS / REST';

  @override
  String get checking => 'Comprobando…';

  @override
  String get ok => 'OK';

  @override
  String get fail => 'Error';

  @override
  String get unknown => 'Desconocido';

  @override
  String get host => 'Host';

  @override
  String get user => 'Usuario';

  @override
  String get reconnect => 'Reconectar';

  @override
  String get reconnectNow => 'Reconectar ahora';

  @override
  String get checkNow => 'Comprobar ahora';

  @override
  String get signIn => 'Iniciar sesión';

  @override
  String get signInAndReconnect => 'Iniciar sesión y reconectar';

  @override
  String get gaveUpTapReconnect => 'Abandonado — toca Reconectar';

  @override
  String get connecting => 'Conectando…';

  @override
  String get error => 'Error';

  @override
  String get closed => 'Cerrado';

  @override
  String get idle => 'Inactivo';

  @override
  String get offline => 'Sin conexión';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get skinSectionDesktop => 'Desktop';

  @override
  String get skinSectionMobile => 'Mobile';

  @override
  String get required => 'Obligatorio';

  @override
  String get signedInWsLive => 'Sesión iniciada — WebSocket en vivo';

  @override
  String signedInWsOffline(String status) {
    return 'Sesión iniciada; WebSocket: $status';
  }

  @override
  String reenterPasswordFor(String user, String host) {
    return 'Vuelve a introducir la contraseña de $user en $host.\nNunca reconectamos en silencio tras caducidad (los kicks se mantienen).';
  }

  @override
  String get connectTitle => 'Hermes Go';

  @override
  String get signInAgain => 'Volver a iniciar sesión';

  @override
  String get sessionExpiredBanner =>
      'Tu sesión del gateway caducó (o se cerró).\nVuelve a introducir la contraseña — no reconectamos automáticamente tras caducidad.';

  @override
  String get connectIntro =>
      'Conéctate a tu gateway Hermes — igual que Desktop: URL base, luego usuario y contraseña. Sin API key.';

  @override
  String get gatewayBaseUrl => 'URL base del gateway';

  @override
  String get httpPrivateNetworkHint =>
      'Usa HTTP sin cifrar solo en una red local de confianza. Usa HTTPS para el acceso remoto.';

  @override
  String get urlRequired => 'URL obligatoria';

  @override
  String get provider => 'Proveedor';

  @override
  String get username => 'Usuario';

  @override
  String get password => 'Contraseña';

  @override
  String get continueAction => 'Continuar';

  @override
  String get changeUrl => 'Cambiar URL';

  @override
  String get gatewayOpenHint =>
      'El gateway está abierto (sin contraseña). Puedes conectar sin credenciales.';

  @override
  String get signInPasswordHint =>
      'Inicia sesión con usuario y contraseña (igual que Desktop remoto).';

  @override
  String get oauthOnlyError =>
      'Este gateway solo admite OAuth. Activa un proveedor con contraseña en el host, o usa Desktop para OAuth.';

  @override
  String get connectedOpenGateway => 'Conectado (gateway abierto).';

  @override
  String get noPasswordProvider =>
      'Ningún proveedor de contraseña seleccionado.';

  @override
  String get usernamePasswordRequired => 'Usuario y contraseña obligatorios.';

  @override
  String signedInAs(String username) {
    return 'Sesión iniciada como $username';
  }

  @override
  String get gatewayNotReachable => 'Gateway no alcanzable.';

  @override
  String get chats => 'Chats';

  @override
  String get newChat => 'Chat nuevo';

  @override
  String get noChatsYet => 'Aún no hay chats';

  @override
  String get startNewChatHint =>
      'Empieza un chat nuevo o ábrelo desde el menú.';

  @override
  String get pinned => 'Fijados';

  @override
  String get recents => 'Recientes';

  @override
  String get renameChat => 'Renombrar chat';

  @override
  String get title => 'Título';

  @override
  String get save => 'Guardar';

  @override
  String renameFailed(String error) {
    return 'Error al renombrar: $error';
  }

  @override
  String get deleteChatTitle => '¿Eliminar chat?';

  @override
  String get delete => 'Eliminar';

  @override
  String get sessionIdCopied => 'ID de sesión copiado';

  @override
  String get sessionActions => 'Acciones de sesión';

  @override
  String get pin => 'Fijar';

  @override
  String get unpin => 'Desfijar';

  @override
  String get copyId => 'Copiar ID';

  @override
  String get export => 'Exportar';

  @override
  String get rename => 'Renombrar';

  @override
  String get archive => 'Archivar';

  @override
  String exportFailed(String error) {
    return 'Error al exportar: $error';
  }

  @override
  String couldNotStartChat(String error) {
    return 'No se pudo iniciar el chat: $error';
  }

  @override
  String sessionNotFound(String id) {
    return 'Sesión no encontrada: $id';
  }

  @override
  String get selectModel => 'Elegir modelo';

  @override
  String get imageChat => 'Chat con imagen';

  @override
  String get greetingMorning => 'Buenos días';

  @override
  String get greetingAfternoon => 'Buenas tardes';

  @override
  String get greetingEvening => 'Buenas noches';

  @override
  String get messageHint => 'Mensaje a Hermes Go…';

  @override
  String get messageHintShort => 'Mensaje…';

  @override
  String get sendAMessageToContinue => 'Envía un mensaje para continuar.';

  @override
  String get sync => 'Sincronizar';

  @override
  String get stop => 'Detener';

  @override
  String get dictate => 'Dictar';

  @override
  String get stopDictation => 'Detener dictado';

  @override
  String get listening => 'Escuchando…';

  @override
  String get readAloudOn => 'Leer en voz alta: sí';

  @override
  String get readAloudOff => 'Leer en voz alta: no';

  @override
  String get readAloud => 'Leer en voz alta';

  @override
  String get addContext => 'Añadir contexto';

  @override
  String get photoLibrary => 'Fototeca';

  @override
  String get camera => 'Cámara';

  @override
  String get pasteImageFromClipboard => 'Pegar imagen del portapapeles';

  @override
  String get noImageOnClipboard =>
      'No hay imagen en el portapapeles — usa Fototeca o Cámara';

  @override
  String couldNotPickImage(String error) {
    return 'No se pudo elegir imagen: $error';
  }

  @override
  String pasteFailed(String error) {
    return 'Error al pegar: $error';
  }

  @override
  String get speechUnavailable =>
      'Reconocimiento de voz no disponible en este dispositivo';

  @override
  String get micPermissionDenied =>
      'Permiso de micrófono/voz denegado — actívalo en Ajustes';

  @override
  String get couldNotStartDictation =>
      'No se pudo iniciar el dictado — revisa micrófono y permisos';

  @override
  String dictationFailed(String error) {
    return 'Error de dictado: $error';
  }

  @override
  String get uploadingImage => 'Subiendo imagen…';

  @override
  String get thinking => 'Thinking';

  @override
  String get writing => 'Escribiendo…';

  @override
  String runningTool(String name) {
    return 'Ejecutando $name…';
  }

  @override
  String imageAttachFailed(String error) {
    return 'Error al adjuntar imagen: $error';
  }

  @override
  String get savedWaitingWs =>
      'Guardado en el teléfono — esperando WebSocket en vivo (Ajustes puede mostrar solo HTTPS).';

  @override
  String get queuedForSync => 'En cola para sincronizar con el gateway…';

  @override
  String stopFailed(String error) {
    return 'Error al detener: $error';
  }

  @override
  String get editMessage => 'Editar mensaje';

  @override
  String get saveAndResend => 'Guardar y reenviar';

  @override
  String get editAndResend => 'Editar y reenviar';

  @override
  String get rewindAndRun => 'Volver a este mensaje y ejecutar de nuevo';

  @override
  String get regenerate => 'Regenerar';

  @override
  String get resend => 'Resend';

  @override
  String get resubmitMessage => 'Reenviar este mensaje';

  @override
  String get retryFromPrevious =>
      'Reintentar desde el mensaje de usuario anterior';

  @override
  String get noResponseYet => 'No reply yet — resend or edit this message';

  @override
  String get messageActions => 'Message actions';

  @override
  String get deleteMessageTitle => '¿Eliminar mensaje?';

  @override
  String get deleteMessageBody =>
      'Esta acción no se puede deshacer. Hermes aún no puede eliminar un solo mensaje en el gateway, así que solo se elimina de este dispositivo — el gateway conserva su propia copia y puede seguir apareciendo en otros lugares.';

  @override
  String get messageDeleted => 'Mensaje eliminado (solo en este dispositivo)';

  @override
  String get copied => 'Copiado';

  @override
  String get copy => 'Copiar';

  @override
  String get codeCopied => 'Código copiado';

  @override
  String copiedLink(String href) {
    return 'Enlace copiado: $href';
  }

  @override
  String get stopRequested => 'Detención solicitada.';

  @override
  String slashFailed(String error) {
    return 'Error de slash: $error';
  }

  @override
  String modelSavedLocal(String error) {
    return 'Modelo guardado en el teléfono; gateway: $error';
  }

  @override
  String get pleaseLookAtImage => 'Por favor mira la imagen adjunta.';

  @override
  String get pleaseLookAtImages => 'Por favor mira las imágenes adjuntas.';

  @override
  String nImages(int count) {
    return '$count imagen(es)';
  }

  @override
  String get jobsTitle => 'Trabajos';

  @override
  String get retry => 'Reintentar';

  @override
  String get runNow => 'Ejecutar ahora';

  @override
  String get pause => 'Pausar';

  @override
  String get resume => 'Reanudar';

  @override
  String get modelPickerTitle => 'Modelo';

  @override
  String get modelPickerSubtitle => 'Mismo catálogo que Desktop';

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
  String get refreshModels => 'Actualizar modelos';

  @override
  String get skillsTitle => 'Skills instaladas en tu gateway';

  @override
  String get filterSkills => 'Filtrar skills…';

  @override
  String get reloadSkills => 'Recargar skills en el gateway';

  @override
  String reloadFailed(String error) {
    return 'Error al recargar: $error';
  }

  @override
  String get skillsSection => 'Skills';

  @override
  String get commandsSection => 'Comandos';

  @override
  String get optionsSection => 'Opciones';

  @override
  String get privacyAndData => 'Privacidad y datos';

  @override
  String get privacyAndDataSubtitle =>
      'Cómo se gestionan el contenido del gateway y los datos del dispositivo';

  @override
  String get privacyDataFlow =>
      'Hermes Go envía las conversaciones y los archivos adjuntos directamente al gateway que elijas. Ese gateway puede enviarlos a los proveedores de modelos y servicios configurados por su propietario.';

  @override
  String get privacyOnDevice =>
      'La app guarda en este dispositivo metadatos de conexión, cookies de sesión cifradas, preferencias y una caché local de conversaciones. Desconectar elimina las conexiones guardadas y los datos de autenticación.';

  @override
  String get privacyNoAnalytics =>
      'Esta versión no contiene SDK de publicidad ni de analítica.';

  @override
  String get privacyPolicyMissing =>
      'Acción requerida del editor: configura una URL HTTPS pública para la política de privacidad antes de enviar la app a la tienda.';

  @override
  String get openPrivacyPolicy => 'Abrir política de privacidad';

  @override
  String get couldNotOpenLink => 'No se pudo abrir el enlace.';

  @override
  String get unofficialDisclaimer =>
      'No oficial · Creada por la comunidad · No afiliada a Nous Research';

  @override
  String get noCachedJobs =>
      'Aún no hay trabajos en caché.\nCorrige la conexión y vuelve a intentarlo.';

  @override
  String get noCronJobs =>
      'No hay trabajos cron en este gateway.\nCréelos en el host (`hermes cron` o Desktop).\nCuando terminen, esta pestaña se sincronizará y podrá avisarte.';

  @override
  String get skillsPickerSubtitle =>
      'Instaladas en tu gateway (hub, incluidas y propias).\nSe guardan en este teléfono si falla la red.\nToca para invocarlas como un comando slash.';

  @override
  String get noSkillsCached =>
      'Aún no hay skills en caché.\nRecarga cuando el gateway esté disponible o escribe /skills-name cuando funcione el autocompletado.';

  @override
  String noSkillsMatch(String query) {
    return 'Ninguna skill coincide con «$query».';
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
      'Mismo catálogo que Desktop (/api/model/options · model.options).\nSe aplica a la sesión abierta en el gateway.';

  @override
  String couldNotLoadModels(String detail) {
    return 'No se pudieron cargar los modelos:\n$detail';
  }

  @override
  String get noModelsFromGateway =>
      'No hay modelos de este gateway.\nDesktop usa GET /api/model/options (cookies de sesión). Configura proveedores en el host si la lista está realmente vacía.';

  @override
  String get notificationsTitle => 'Notificaciones';

  @override
  String artifactOpenTooltip(String name) {
    return 'Abrir $name';
  }

  @override
  String get artifactKindMarkdown => 'Markdown';

  @override
  String get artifactKindHtml => 'HTML';

  @override
  String get artifactReload => 'Recargar';

  @override
  String get artifactNotFound =>
      'Archivo no encontrado. Puede que se haya movido o eliminado en el gateway.';

  @override
  String get artifactAccessDenied => 'No se permite el acceso a este archivo.';

  @override
  String get artifactTooLarge =>
      'Este archivo es demasiado grande para previsualizarlo aquí.';

  @override
  String get artifactLoadFailed => 'No se pudo cargar este archivo.';

  @override
  String get artifactEnableJs => 'Activar JavaScript';

  @override
  String get artifactEnableJsWarning =>
      'Desactivado de forma predeterminada y nunca se recuerda — actívalo solo para documentos de confianza.';

  @override
  String get artifactOpenLinkTitle => '¿Abrir enlace?';

  @override
  String artifactOpenLinkBody(String url) {
    return 'Esto abrirá $url en tu navegador, saliendo de Hermes Go.';
  }

  @override
  String get artifactOpenLinkAction => 'Abrir en el navegador';

  @override
  String imageTapToLoad(String host) {
    return 'Toca para cargar la imagen de $host';
  }

  @override
  String imageBlockedPrivateNetwork(String host) {
    return 'Imagen bloqueada — red privada ($host)';
  }

  @override
  String get imageBlockedSource => 'Imagen bloqueada — origen no admitido';

  @override
  String get imageLoadFailed => 'No se pudo cargar la imagen';
}
