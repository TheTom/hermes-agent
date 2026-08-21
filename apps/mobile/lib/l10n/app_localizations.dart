import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('ja'),
    Locale('ko'),
    Locale('pt'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Hermes Go'**
  String get appTitle;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Go further. Stay connected.'**
  String get tagline;

  /// No description provided for @aboutBody.
  ///
  /// In en, this message translates to:
  /// **'Hermes Go v0.1\nGo further. Stay connected.\nGateway connector — sessions, chat, models, jobs.'**
  String get aboutBody;

  /// No description provided for @failedToLoadConnection.
  ///
  /// In en, this message translates to:
  /// **'Failed to load connection: {error}'**
  String failedToLoadConnection(String error);

  /// No description provided for @navSessions.
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get navSessions;

  /// No description provided for @navBots.
  ///
  /// In en, this message translates to:
  /// **'Bots'**
  String get navBots;

  /// No description provided for @navJobs.
  ///
  /// In en, this message translates to:
  /// **'Jobs'**
  String get navJobs;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @botsTitle.
  ///
  /// In en, this message translates to:
  /// **'Bots'**
  String get botsTitle;

  /// No description provided for @botsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No bots yet. Tap + to create one.'**
  String get botsEmpty;

  /// No description provided for @newBotTitle.
  ///
  /// In en, this message translates to:
  /// **'New Bot'**
  String get newBotTitle;

  /// No description provided for @newBotSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A named teammate with its own memory, skills, and chat.'**
  String get newBotSubtitle;

  /// No description provided for @botNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get botNameLabel;

  /// No description provided for @botNameHelper.
  ///
  /// In en, this message translates to:
  /// **'Used as the @handle'**
  String get botNameHelper;

  /// No description provided for @botNameTaken.
  ///
  /// In en, this message translates to:
  /// **'That handle already exists'**
  String get botNameTaken;

  /// No description provided for @botDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get botDescriptionLabel;

  /// No description provided for @botAppearanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get botAppearanceLabel;

  /// No description provided for @createBotAction.
  ///
  /// In en, this message translates to:
  /// **'Create Bot'**
  String get createBotAction;

  /// No description provided for @creatingBot.
  ///
  /// In en, this message translates to:
  /// **'Creating…'**
  String get creatingBot;

  /// No description provided for @editBotAction.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editBotAction;

  /// No description provided for @editBotTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Bot'**
  String get editBotTitle;

  /// No description provided for @savingBot.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get savingBot;

  /// No description provided for @botHandleImmutable.
  ///
  /// In en, this message translates to:
  /// **'@{handle} is the bot’s permanent handle for sessions and memory.'**
  String botHandleImmutable(String handle);

  /// No description provided for @botsNoConversation.
  ///
  /// In en, this message translates to:
  /// **'No conversations yet'**
  String get botsNoConversation;

  /// No description provided for @botsCachedRoster.
  ///
  /// In en, this message translates to:
  /// **'Showing the last roster while the server reconnects.'**
  String get botsCachedRoster;

  /// No description provided for @modelLabel.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get modelLabel;

  /// No description provided for @lastActivity.
  ///
  /// In en, this message translates to:
  /// **'Last activity'**
  String get lastActivity;

  /// No description provided for @messagesLabel.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messagesLabel;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @checkConnection.
  ///
  /// In en, this message translates to:
  /// **'Check connection'**
  String get checkConnection;

  /// No description provided for @liveChatReady.
  ///
  /// In en, this message translates to:
  /// **'Live — chat ready'**
  String get liveChatReady;

  /// No description provided for @notLiveSeeStatus.
  ///
  /// In en, this message translates to:
  /// **'Not live — see Connection status'**
  String get notLiveSeeStatus;

  /// No description provided for @wsConnectedChatReady.
  ///
  /// In en, this message translates to:
  /// **'WebSocket connected — chat ready'**
  String get wsConnectedChatReady;

  /// No description provided for @stillOffline.
  ///
  /// In en, this message translates to:
  /// **'Still offline'**
  String get stillOffline;

  /// No description provided for @apiToken.
  ///
  /// In en, this message translates to:
  /// **'API token'**
  String get apiToken;

  /// No description provided for @refreshSignIn.
  ///
  /// In en, this message translates to:
  /// **'Refresh sign-in'**
  String get refreshSignIn;

  /// No description provided for @refreshSignInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Re-enter password (e.g. after a host kick). Not automatic.'**
  String get refreshSignInSubtitle;

  /// No description provided for @disconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get disconnect;

  /// No description provided for @disconnectSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Remove this gateway from the phone'**
  String get disconnectSubtitle;

  /// No description provided for @disconnectConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Disconnect?'**
  String get disconnectConfirmTitle;

  /// No description provided for @disconnectConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Removes the saved gateway from this phone. Host agents are not affected.'**
  String get disconnectConfirmBody;

  /// No description provided for @exitSampleWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Exit sample workspace'**
  String get exitSampleWorkspace;

  /// No description provided for @exitSampleWorkspaceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Stop the sandbox and remove it from this phone'**
  String get exitSampleWorkspaceSubtitle;

  /// No description provided for @exitSampleWorkspaceConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Exit sample workspace?'**
  String get exitSampleWorkspaceConfirmTitle;

  /// No description provided for @exitSampleWorkspaceConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Stops the built-in sample gateway and clears its sessions from this phone. Nothing leaves the device.'**
  String get exitSampleWorkspaceConfirmBody;

  /// No description provided for @sampleWorkspaceAboutLine.
  ///
  /// In en, this message translates to:
  /// **'Sample workspace — connect to demo.hermes.go (user demo, password demo) to try Hermes Go without setting up a gateway.'**
  String get sampleWorkspaceAboutLine;

  /// No description provided for @sampleWorkspaceBadge.
  ///
  /// In en, this message translates to:
  /// **'Sample'**
  String get sampleWorkspaceBadge;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @appearanceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Same built-in skins as Desktop (Nous, Midnight, Ember, …).'**
  String get appearanceSubtitle;

  /// No description provided for @hapticsSounds.
  ///
  /// In en, this message translates to:
  /// **'Haptics & sounds'**
  String get hapticsSounds;

  /// No description provided for @hapticsOff.
  ///
  /// In en, this message translates to:
  /// **'Off — no taps, no completion chime'**
  String get hapticsOff;

  /// No description provided for @hapticsOn.
  ///
  /// In en, this message translates to:
  /// **'On — taps, send/stop feedback, reply chime'**
  String get hapticsOn;

  /// No description provided for @previewHaptics.
  ///
  /// In en, this message translates to:
  /// **'Preview haptics & chime'**
  String get previewHaptics;

  /// No description provided for @syncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync now'**
  String get syncNow;

  /// No description provided for @syncNowSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sessions, jobs, models, skills'**
  String get syncNowSubtitle;

  /// No description provided for @syncedWithSummary.
  ///
  /// In en, this message translates to:
  /// **'Synced ({summary})'**
  String syncedWithSummary(String summary);

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @couldNotOpenBrowser.
  ///
  /// In en, this message translates to:
  /// **'Could not open browser — link copied'**
  String get couldNotOpenBrowser;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystem;

  /// No description provided for @languageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'App UI language. Chat content follows your agent.'**
  String get languageSubtitle;

  /// No description provided for @connectedChatReady.
  ///
  /// In en, this message translates to:
  /// **'Connected · chat ready'**
  String get connectedChatReady;

  /// No description provided for @connectedChatReadyBody.
  ///
  /// In en, this message translates to:
  /// **'Live WebSocket to the gateway. Messages and slash commands work.'**
  String get connectedChatReadyBody;

  /// No description provided for @signedInChatOffline.
  ///
  /// In en, this message translates to:
  /// **'Signed in · chat offline'**
  String get signedInChatOffline;

  /// No description provided for @signedInReconnecting.
  ///
  /// In en, this message translates to:
  /// **'Signed in · reconnecting'**
  String get signedInReconnecting;

  /// No description provided for @autoReconnectGaveUp.
  ///
  /// In en, this message translates to:
  /// **'Auto-reconnect gave up. Tap Reconnect or check that the host is reachable.'**
  String get autoReconnectGaveUp;

  /// No description provided for @signedInChatOfflineBody.
  ///
  /// In en, this message translates to:
  /// **'HTTPS/cookies may work for lists, but the live WebSocket is down. Auto-retry runs with backoff; or tap Reconnect.'**
  String get signedInChatOfflineBody;

  /// No description provided for @sessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Session expired'**
  String get sessionExpired;

  /// No description provided for @sessionExpiredBody.
  ///
  /// In en, this message translates to:
  /// **'Sign in again. Expiry may be intentional (signed out on host).'**
  String get sessionExpiredBody;

  /// No description provided for @gaveUpReconnecting.
  ///
  /// In en, this message translates to:
  /// **'Gave up reconnecting'**
  String get gaveUpReconnecting;

  /// No description provided for @connectionProblem.
  ///
  /// In en, this message translates to:
  /// **'Connection problem'**
  String get connectionProblem;

  /// No description provided for @cannotReachGateway.
  ///
  /// In en, this message translates to:
  /// **'Cannot reach the gateway. Check the host address, network connection, and host power.'**
  String get cannotReachGateway;

  /// No description provided for @notConnected.
  ///
  /// In en, this message translates to:
  /// **'Not connected'**
  String get notConnected;

  /// No description provided for @noGatewaySaved.
  ///
  /// In en, this message translates to:
  /// **'No gateway saved on this phone. Sign in from Connect.'**
  String get noGatewaySaved;

  /// No description provided for @webSocket.
  ///
  /// In en, this message translates to:
  /// **'WebSocket'**
  String get webSocket;

  /// No description provided for @live.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get live;

  /// No description provided for @httpsRest.
  ///
  /// In en, this message translates to:
  /// **'HTTPS / REST'**
  String get httpsRest;

  /// No description provided for @checking.
  ///
  /// In en, this message translates to:
  /// **'Checking…'**
  String get checking;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @fail.
  ///
  /// In en, this message translates to:
  /// **'Fail'**
  String get fail;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @host.
  ///
  /// In en, this message translates to:
  /// **'Host'**
  String get host;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @reconnect.
  ///
  /// In en, this message translates to:
  /// **'Reconnect'**
  String get reconnect;

  /// No description provided for @reconnectNow.
  ///
  /// In en, this message translates to:
  /// **'Reconnect now'**
  String get reconnectNow;

  /// No description provided for @checkNow.
  ///
  /// In en, this message translates to:
  /// **'Check now'**
  String get checkNow;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @signInAndReconnect.
  ///
  /// In en, this message translates to:
  /// **'Sign in & reconnect'**
  String get signInAndReconnect;

  /// No description provided for @gaveUpTapReconnect.
  ///
  /// In en, this message translates to:
  /// **'Gave up — tap Reconnect'**
  String get gaveUpTapReconnect;

  /// No description provided for @connecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting…'**
  String get connecting;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @closed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closed;

  /// No description provided for @idle.
  ///
  /// In en, this message translates to:
  /// **'Idle'**
  String get idle;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @skinSectionDesktop.
  ///
  /// In en, this message translates to:
  /// **'Desktop'**
  String get skinSectionDesktop;

  /// No description provided for @skinSectionMobile.
  ///
  /// In en, this message translates to:
  /// **'Mobile'**
  String get skinSectionMobile;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @signedInWsLive.
  ///
  /// In en, this message translates to:
  /// **'Signed in — WebSocket live'**
  String get signedInWsLive;

  /// No description provided for @signedInWsOffline.
  ///
  /// In en, this message translates to:
  /// **'Signed in; WebSocket: {status}'**
  String signedInWsOffline(String status);

  /// No description provided for @reenterPasswordFor.
  ///
  /// In en, this message translates to:
  /// **'Re-enter the password for {user} on {host}.\nWe never auto-reconnect after expiry (kicks stay kicked).'**
  String reenterPasswordFor(String user, String host);

  /// No description provided for @connectTitle.
  ///
  /// In en, this message translates to:
  /// **'Hermes Go'**
  String get connectTitle;

  /// No description provided for @signInAgain.
  ///
  /// In en, this message translates to:
  /// **'Sign in again'**
  String get signInAgain;

  /// No description provided for @sessionExpiredBanner.
  ///
  /// In en, this message translates to:
  /// **'Your gateway session expired (or was signed out).\nRe-enter your password to continue — we do not auto-reconnect after expiry.'**
  String get sessionExpiredBanner;

  /// No description provided for @connectIntro.
  ///
  /// In en, this message translates to:
  /// **'Connect to your Hermes gateway — same as Desktop: base URL, then username and password. No API key.'**
  String get connectIntro;

  /// No description provided for @gatewayBaseUrl.
  ///
  /// In en, this message translates to:
  /// **'Gateway base URL'**
  String get gatewayBaseUrl;

  /// No description provided for @httpPrivateNetworkHint.
  ///
  /// In en, this message translates to:
  /// **'Plain HTTP is allowed only on a trusted LAN or private VPN. Public remote access requires HTTPS.'**
  String get httpPrivateNetworkHint;

  /// No description provided for @urlRequired.
  ///
  /// In en, this message translates to:
  /// **'URL required'**
  String get urlRequired;

  /// No description provided for @provider.
  ///
  /// In en, this message translates to:
  /// **'Provider'**
  String get provider;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @continueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// No description provided for @changeUrl.
  ///
  /// In en, this message translates to:
  /// **'Change URL'**
  String get changeUrl;

  /// No description provided for @gatewayOpenHint.
  ///
  /// In en, this message translates to:
  /// **'Gateway is open (no password gate). You can connect without credentials.'**
  String get gatewayOpenHint;

  /// No description provided for @signInPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Sign in with username and password (same as Desktop remote gateway).'**
  String get signInPasswordHint;

  /// No description provided for @oauthOnlyError.
  ///
  /// In en, this message translates to:
  /// **'This gateway uses OAuth sign-in only. Password login is not enabled. Enable a supports_password provider on the host, or use Desktop for OAuth.'**
  String get oauthOnlyError;

  /// No description provided for @connectedOpenGateway.
  ///
  /// In en, this message translates to:
  /// **'Connected (open gateway).'**
  String get connectedOpenGateway;

  /// No description provided for @noPasswordProvider.
  ///
  /// In en, this message translates to:
  /// **'No password provider selected.'**
  String get noPasswordProvider;

  /// No description provided for @usernamePasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Username and password required.'**
  String get usernamePasswordRequired;

  /// No description provided for @signedInAs.
  ///
  /// In en, this message translates to:
  /// **'Signed in as {username}'**
  String signedInAs(String username);

  /// No description provided for @gatewayNotReachable.
  ///
  /// In en, this message translates to:
  /// **'Gateway not reachable.'**
  String get gatewayNotReachable;

  /// No description provided for @chats.
  ///
  /// In en, this message translates to:
  /// **'Chats'**
  String get chats;

  /// No description provided for @newChat.
  ///
  /// In en, this message translates to:
  /// **'New chat'**
  String get newChat;

  /// No description provided for @noChatsYet.
  ///
  /// In en, this message translates to:
  /// **'No chats yet'**
  String get noChatsYet;

  /// No description provided for @startNewChatHint.
  ///
  /// In en, this message translates to:
  /// **'Start a new chat, or open one from the menu.'**
  String get startNewChatHint;

  /// No description provided for @pinned.
  ///
  /// In en, this message translates to:
  /// **'Pinned'**
  String get pinned;

  /// No description provided for @recents.
  ///
  /// In en, this message translates to:
  /// **'Recents'**
  String get recents;

  /// No description provided for @renameChat.
  ///
  /// In en, this message translates to:
  /// **'Rename chat'**
  String get renameChat;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @renameFailed.
  ///
  /// In en, this message translates to:
  /// **'Rename failed: {error}'**
  String renameFailed(String error);

  /// No description provided for @deleteChatTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete chat?'**
  String get deleteChatTitle;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @sessionIdCopied.
  ///
  /// In en, this message translates to:
  /// **'Session ID copied'**
  String get sessionIdCopied;

  /// No description provided for @sessionActions.
  ///
  /// In en, this message translates to:
  /// **'Session actions'**
  String get sessionActions;

  /// No description provided for @pin.
  ///
  /// In en, this message translates to:
  /// **'Pin'**
  String get pin;

  /// No description provided for @unpin.
  ///
  /// In en, this message translates to:
  /// **'Unpin'**
  String get unpin;

  /// No description provided for @copyId.
  ///
  /// In en, this message translates to:
  /// **'Copy ID'**
  String get copyId;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// No description provided for @archive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archive;

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String exportFailed(String error);

  /// No description provided for @couldNotStartChat.
  ///
  /// In en, this message translates to:
  /// **'Could not start chat: {error}'**
  String couldNotStartChat(String error);

  /// No description provided for @sessionNotFound.
  ///
  /// In en, this message translates to:
  /// **'Session not found: {id}'**
  String sessionNotFound(String id);

  /// No description provided for @selectModel.
  ///
  /// In en, this message translates to:
  /// **'Select model'**
  String get selectModel;

  /// No description provided for @imageChat.
  ///
  /// In en, this message translates to:
  /// **'Image chat'**
  String get imageChat;

  /// No description provided for @greetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get greetingMorning;

  /// No description provided for @greetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get greetingEvening;

  /// No description provided for @messageHint.
  ///
  /// In en, this message translates to:
  /// **'Message Hermes Go…'**
  String get messageHint;

  /// No description provided for @messageHintShort.
  ///
  /// In en, this message translates to:
  /// **'Message…'**
  String get messageHintShort;

  /// No description provided for @sendAMessageToContinue.
  ///
  /// In en, this message translates to:
  /// **'Send a message to continue.'**
  String get sendAMessageToContinue;

  /// No description provided for @sync.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get sync;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @dictate.
  ///
  /// In en, this message translates to:
  /// **'Dictate'**
  String get dictate;

  /// No description provided for @stopDictation.
  ///
  /// In en, this message translates to:
  /// **'Stop dictation'**
  String get stopDictation;

  /// No description provided for @listening.
  ///
  /// In en, this message translates to:
  /// **'Listening…'**
  String get listening;

  /// No description provided for @readAloudOn.
  ///
  /// In en, this message translates to:
  /// **'Read aloud: on'**
  String get readAloudOn;

  /// No description provided for @readAloudOff.
  ///
  /// In en, this message translates to:
  /// **'Read aloud: off'**
  String get readAloudOff;

  /// No description provided for @readAloud.
  ///
  /// In en, this message translates to:
  /// **'Read aloud'**
  String get readAloud;

  /// No description provided for @addContext.
  ///
  /// In en, this message translates to:
  /// **'Add context'**
  String get addContext;

  /// No description provided for @photoLibrary.
  ///
  /// In en, this message translates to:
  /// **'Photo library'**
  String get photoLibrary;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @pasteImageFromClipboard.
  ///
  /// In en, this message translates to:
  /// **'Paste image from clipboard'**
  String get pasteImageFromClipboard;

  /// No description provided for @noImageOnClipboard.
  ///
  /// In en, this message translates to:
  /// **'No image on clipboard — use Photo library or Camera'**
  String get noImageOnClipboard;

  /// No description provided for @couldNotPickImage.
  ///
  /// In en, this message translates to:
  /// **'Could not pick image: {error}'**
  String couldNotPickImage(String error);

  /// No description provided for @pasteFailed.
  ///
  /// In en, this message translates to:
  /// **'Paste failed: {error}'**
  String pasteFailed(String error);

  /// No description provided for @speechUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Speech recognition unavailable on this device'**
  String get speechUnavailable;

  /// No description provided for @micPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Microphone / speech permission denied — enable in Settings'**
  String get micPermissionDenied;

  /// No description provided for @couldNotStartDictation.
  ///
  /// In en, this message translates to:
  /// **'Could not start dictation — check mic & speech permissions'**
  String get couldNotStartDictation;

  /// No description provided for @dictationFailed.
  ///
  /// In en, this message translates to:
  /// **'Dictation failed: {error}'**
  String dictationFailed(String error);

  /// No description provided for @uploadingImage.
  ///
  /// In en, this message translates to:
  /// **'Uploading image…'**
  String get uploadingImage;

  /// No description provided for @thinking.
  ///
  /// In en, this message translates to:
  /// **'Thinking'**
  String get thinking;

  /// No description provided for @writing.
  ///
  /// In en, this message translates to:
  /// **'Writing…'**
  String get writing;

  /// No description provided for @runningTool.
  ///
  /// In en, this message translates to:
  /// **'Running {name}…'**
  String runningTool(String name);

  /// No description provided for @imageAttachFailed.
  ///
  /// In en, this message translates to:
  /// **'Image attach failed: {error}'**
  String imageAttachFailed(String error);

  /// No description provided for @savedWaitingWs.
  ///
  /// In en, this message translates to:
  /// **'Saved on phone — waiting for live WebSocket (Settings may show HTTPS only).'**
  String get savedWaitingWs;

  /// No description provided for @queuedForSync.
  ///
  /// In en, this message translates to:
  /// **'Queued for sync to gateway…'**
  String get queuedForSync;

  /// No description provided for @stopFailed.
  ///
  /// In en, this message translates to:
  /// **'Stop failed: {error}'**
  String stopFailed(String error);

  /// No description provided for @editMessage.
  ///
  /// In en, this message translates to:
  /// **'Edit message'**
  String get editMessage;

  /// No description provided for @saveAndResend.
  ///
  /// In en, this message translates to:
  /// **'Save & resend'**
  String get saveAndResend;

  /// No description provided for @editAndResend.
  ///
  /// In en, this message translates to:
  /// **'Edit & resend'**
  String get editAndResend;

  /// No description provided for @rewindAndRun.
  ///
  /// In en, this message translates to:
  /// **'Rewind to this prompt and run again'**
  String get rewindAndRun;

  /// No description provided for @regenerate.
  ///
  /// In en, this message translates to:
  /// **'Regenerate'**
  String get regenerate;

  /// No description provided for @resend.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get resend;

  /// No description provided for @resubmitMessage.
  ///
  /// In en, this message translates to:
  /// **'Resubmit this message'**
  String get resubmitMessage;

  /// No description provided for @retryFromPrevious.
  ///
  /// In en, this message translates to:
  /// **'Retry from the previous user message'**
  String get retryFromPrevious;

  /// No description provided for @noResponseYet.
  ///
  /// In en, this message translates to:
  /// **'No reply yet — resend or edit this message'**
  String get noResponseYet;

  /// No description provided for @messageActions.
  ///
  /// In en, this message translates to:
  /// **'Message actions'**
  String get messageActions;

  /// No description provided for @deleteMessageTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete message?'**
  String get deleteMessageTitle;

  /// No description provided for @deleteMessageBody.
  ///
  /// In en, this message translates to:
  /// **'This can\'t be undone. Hermes can\'t delete a single message on the gateway yet, so it\'s removed from this device only — the gateway keeps its own copy and it may still appear elsewhere.'**
  String get deleteMessageBody;

  /// No description provided for @messageDeleted.
  ///
  /// In en, this message translates to:
  /// **'Message deleted (this device only)'**
  String get messageDeleted;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get copied;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @codeCopied.
  ///
  /// In en, this message translates to:
  /// **'Code copied'**
  String get codeCopied;

  /// No description provided for @copiedLink.
  ///
  /// In en, this message translates to:
  /// **'Copied link: {href}'**
  String copiedLink(String href);

  /// No description provided for @stopRequested.
  ///
  /// In en, this message translates to:
  /// **'Stop requested.'**
  String get stopRequested;

  /// No description provided for @slashFailed.
  ///
  /// In en, this message translates to:
  /// **'Slash failed: {error}'**
  String slashFailed(String error);

  /// No description provided for @modelSavedLocal.
  ///
  /// In en, this message translates to:
  /// **'Model saved on phone; gateway: {error}'**
  String modelSavedLocal(String error);

  /// No description provided for @pleaseLookAtImage.
  ///
  /// In en, this message translates to:
  /// **'Please look at the attached image.'**
  String get pleaseLookAtImage;

  /// No description provided for @pleaseLookAtImages.
  ///
  /// In en, this message translates to:
  /// **'Please look at the attached images.'**
  String get pleaseLookAtImages;

  /// No description provided for @nImages.
  ///
  /// In en, this message translates to:
  /// **'{count} image(s)'**
  String nImages(int count);

  /// No description provided for @jobsTitle.
  ///
  /// In en, this message translates to:
  /// **'Jobs'**
  String get jobsTitle;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @runNow.
  ///
  /// In en, this message translates to:
  /// **'Run now'**
  String get runNow;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @modelPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get modelPickerTitle;

  /// No description provided for @modelPickerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Same catalog as Desktop'**
  String get modelPickerSubtitle;

  /// No description provided for @reasoningOptions.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get reasoningOptions;

  /// No description provided for @thinkingOnHint.
  ///
  /// In en, this message translates to:
  /// **'Model may use reasoning tokens'**
  String get thinkingOnHint;

  /// No description provided for @thinkingOffHint.
  ///
  /// In en, this message translates to:
  /// **'Reasoning disabled for this session'**
  String get thinkingOffHint;

  /// No description provided for @effort.
  ///
  /// In en, this message translates to:
  /// **'Effort'**
  String get effort;

  /// No description provided for @applyEffort.
  ///
  /// In en, this message translates to:
  /// **'Apply effort to session'**
  String get applyEffort;

  /// No description provided for @confirmModel.
  ///
  /// In en, this message translates to:
  /// **'Use this model'**
  String get confirmModel;

  /// No description provided for @modelPickerConfirmHint.
  ///
  /// In en, this message translates to:
  /// **'Select a model, set its options, then confirm.'**
  String get modelPickerConfirmHint;

  /// No description provided for @modelNoOptions.
  ///
  /// In en, this message translates to:
  /// **'This model has no Thinking or Fast options.'**
  String get modelNoOptions;

  /// No description provided for @modelCapsLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading per-model options…'**
  String get modelCapsLoading;

  /// No description provided for @fastMode.
  ///
  /// In en, this message translates to:
  /// **'Fast'**
  String get fastMode;

  /// No description provided for @fastModeHint.
  ///
  /// In en, this message translates to:
  /// **'Priority / lower-latency when the model supports it'**
  String get fastModeHint;

  /// No description provided for @contextUsageTitle.
  ///
  /// In en, this message translates to:
  /// **'Context Usage'**
  String get contextUsageTitle;

  /// No description provided for @contextUsageTokenSummary.
  ///
  /// In en, this message translates to:
  /// **'~{used} / {max} Tokens'**
  String contextUsageTokenSummary(String used, String max);

  /// No description provided for @contextUsagePercentFull.
  ///
  /// In en, this message translates to:
  /// **'{percent}% Full'**
  String contextUsagePercentFull(int percent);

  /// No description provided for @contextUsageLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading breakdown…'**
  String get contextUsageLoading;

  /// No description provided for @contextUsageEmpty.
  ///
  /// In en, this message translates to:
  /// **'No context data yet — send a message first.'**
  String get contextUsageEmpty;

  /// No description provided for @contextUsageOpen.
  ///
  /// In en, this message translates to:
  /// **'Context usage'**
  String get contextUsageOpen;

  /// No description provided for @contextCatSystemPrompt.
  ///
  /// In en, this message translates to:
  /// **'System prompt'**
  String get contextCatSystemPrompt;

  /// No description provided for @contextCatToolDefinitions.
  ///
  /// In en, this message translates to:
  /// **'Tool definitions'**
  String get contextCatToolDefinitions;

  /// No description provided for @contextCatRules.
  ///
  /// In en, this message translates to:
  /// **'Rules'**
  String get contextCatRules;

  /// No description provided for @contextCatSkills.
  ///
  /// In en, this message translates to:
  /// **'Skills'**
  String get contextCatSkills;

  /// No description provided for @contextCatMcp.
  ///
  /// In en, this message translates to:
  /// **'MCP'**
  String get contextCatMcp;

  /// No description provided for @contextCatSubagents.
  ///
  /// In en, this message translates to:
  /// **'Subagent definitions'**
  String get contextCatSubagents;

  /// No description provided for @contextCatMemory.
  ///
  /// In en, this message translates to:
  /// **'Memory'**
  String get contextCatMemory;

  /// No description provided for @contextCatConversation.
  ///
  /// In en, this message translates to:
  /// **'Conversation'**
  String get contextCatConversation;

  /// No description provided for @refreshModels.
  ///
  /// In en, this message translates to:
  /// **'Refresh models'**
  String get refreshModels;

  /// No description provided for @skillsTitle.
  ///
  /// In en, this message translates to:
  /// **'Installed skills on your gateway'**
  String get skillsTitle;

  /// No description provided for @filterSkills.
  ///
  /// In en, this message translates to:
  /// **'Filter skills…'**
  String get filterSkills;

  /// No description provided for @reloadSkills.
  ///
  /// In en, this message translates to:
  /// **'Reload skills on gateway'**
  String get reloadSkills;

  /// No description provided for @reloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Reload failed: {error}'**
  String reloadFailed(String error);

  /// No description provided for @skillsSection.
  ///
  /// In en, this message translates to:
  /// **'Skills'**
  String get skillsSection;

  /// No description provided for @commandsSection.
  ///
  /// In en, this message translates to:
  /// **'Commands'**
  String get commandsSection;

  /// No description provided for @optionsSection.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get optionsSection;

  /// No description provided for @privacyAndData.
  ///
  /// In en, this message translates to:
  /// **'Privacy & data'**
  String get privacyAndData;

  /// No description provided for @privacyAndDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'How gateway content and on-device data are handled'**
  String get privacyAndDataSubtitle;

  /// No description provided for @privacyDataFlow.
  ///
  /// In en, this message translates to:
  /// **'Hermes Go sends conversations and attachments directly to the gateway you choose. That gateway may send them to the model providers and services configured by its owner.'**
  String get privacyDataFlow;

  /// No description provided for @privacyOnDevice.
  ///
  /// In en, this message translates to:
  /// **'The app keeps connection metadata, encrypted session cookies, preferences, and a local transcript cache on this device. Disconnect removes saved connections and authentication data.'**
  String get privacyOnDevice;

  /// No description provided for @privacyNoAnalytics.
  ///
  /// In en, this message translates to:
  /// **'This build contains no advertising or analytics SDK.'**
  String get privacyNoAnalytics;

  /// No description provided for @privacyPolicyMissing.
  ///
  /// In en, this message translates to:
  /// **'Publisher action required: configure a public HTTPS privacy-policy URL before store submission.'**
  String get privacyPolicyMissing;

  /// No description provided for @openPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Open privacy policy'**
  String get openPrivacyPolicy;

  /// No description provided for @couldNotOpenLink.
  ///
  /// In en, this message translates to:
  /// **'Could not open the link.'**
  String get couldNotOpenLink;

  /// No description provided for @unofficialDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Unofficial · Community-built · Not affiliated with Nous Research'**
  String get unofficialDisclaimer;

  /// No description provided for @noCachedJobs.
  ///
  /// In en, this message translates to:
  /// **'No cached jobs yet.\nFix the connection and retry.'**
  String get noCachedJobs;

  /// No description provided for @noCronJobs.
  ///
  /// In en, this message translates to:
  /// **'No cron jobs on this gateway.\nCreate them on the host (`hermes cron` or Desktop).\nWhen they finish, this tab syncs and can notify you.'**
  String get noCronJobs;

  /// No description provided for @skillsPickerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Installed on your gateway (hub, bundled, yours).\nCached on this phone if the network blips.\nTap to invoke as a slash command.'**
  String get skillsPickerSubtitle;

  /// No description provided for @noSkillsCached.
  ///
  /// In en, this message translates to:
  /// **'No skills cached yet.\nTap reload (needs a live gateway), or type /skills-name once slash autocomplete works.'**
  String get noSkillsCached;

  /// No description provided for @noSkillsMatch.
  ///
  /// In en, this message translates to:
  /// **'No skills match “{query}”.'**
  String noSkillsMatch(String query);

  /// No description provided for @commandCheatSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Slash commands'**
  String get commandCheatSheetTitle;

  /// No description provided for @commandCheatSheetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Browse every /command Hermes supports'**
  String get commandCheatSheetSubtitle;

  /// No description provided for @filterCommands.
  ///
  /// In en, this message translates to:
  /// **'Filter commands…'**
  String get filterCommands;

  /// No description provided for @noCommandsMatch.
  ///
  /// In en, this message translates to:
  /// **'No commands match “{query}”.'**
  String noCommandsMatch(String query);

  /// No description provided for @commandBadgeCli.
  ///
  /// In en, this message translates to:
  /// **'CLI'**
  String get commandBadgeCli;

  /// No description provided for @commandBadgeConfigGated.
  ///
  /// In en, this message translates to:
  /// **'config'**
  String get commandBadgeConfigGated;

  /// No description provided for @commandsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load commands. Check your connection and try again.'**
  String get commandsLoadError;

  /// No description provided for @modelPickerDetails.
  ///
  /// In en, this message translates to:
  /// **'Same catalog as Desktop (/api/model/options · model.options).\nApplied to the open session on the gateway.'**
  String get modelPickerDetails;

  /// No description provided for @couldNotLoadModels.
  ///
  /// In en, this message translates to:
  /// **'Could not load models:\n{detail}'**
  String couldNotLoadModels(String detail);

  /// No description provided for @noModelsFromGateway.
  ///
  /// In en, this message translates to:
  /// **'No models from this gateway.\nDesktop uses GET /api/model/options (session cookies). Configure providers on the host if the list is truly empty.'**
  String get noModelsFromGateway;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @artifactOpenTooltip.
  ///
  /// In en, this message translates to:
  /// **'Open {name}'**
  String artifactOpenTooltip(String name);

  /// No description provided for @artifactKindMarkdown.
  ///
  /// In en, this message translates to:
  /// **'Markdown'**
  String get artifactKindMarkdown;

  /// No description provided for @artifactKindHtml.
  ///
  /// In en, this message translates to:
  /// **'HTML'**
  String get artifactKindHtml;

  /// No description provided for @artifactReload.
  ///
  /// In en, this message translates to:
  /// **'Reload'**
  String get artifactReload;

  /// No description provided for @artifactNotFound.
  ///
  /// In en, this message translates to:
  /// **'File not found. It may have been moved or deleted on the gateway.'**
  String get artifactNotFound;

  /// No description provided for @artifactAccessDenied.
  ///
  /// In en, this message translates to:
  /// **'Access to this file is not allowed.'**
  String get artifactAccessDenied;

  /// No description provided for @artifactTooLarge.
  ///
  /// In en, this message translates to:
  /// **'This file is too large to preview here.'**
  String get artifactTooLarge;

  /// No description provided for @artifactLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load this file.'**
  String get artifactLoadFailed;

  /// No description provided for @artifactEnableJs.
  ///
  /// In en, this message translates to:
  /// **'Enable JavaScript'**
  String get artifactEnableJs;

  /// No description provided for @artifactEnableJsWarning.
  ///
  /// In en, this message translates to:
  /// **'Off by default, and never remembered — only turn this on for documents you trust.'**
  String get artifactEnableJsWarning;

  /// No description provided for @artifactOpenLinkTitle.
  ///
  /// In en, this message translates to:
  /// **'Open link?'**
  String get artifactOpenLinkTitle;

  /// No description provided for @artifactOpenLinkBody.
  ///
  /// In en, this message translates to:
  /// **'This opens {url} in your browser, leaving Hermes Go.'**
  String artifactOpenLinkBody(String url);

  /// No description provided for @artifactOpenLinkAction.
  ///
  /// In en, this message translates to:
  /// **'Open in Browser'**
  String get artifactOpenLinkAction;

  /// No description provided for @imageTapToLoad.
  ///
  /// In en, this message translates to:
  /// **'Tap to load image from {host}'**
  String imageTapToLoad(String host);

  /// No description provided for @imageBlockedPrivateNetwork.
  ///
  /// In en, this message translates to:
  /// **'Image blocked — private network ({host})'**
  String imageBlockedPrivateNetwork(String host);

  /// No description provided for @imageBlockedSource.
  ///
  /// In en, this message translates to:
  /// **'Image blocked — unsupported source'**
  String get imageBlockedSource;

  /// No description provided for @imageLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Image couldn\'t be loaded'**
  String get imageLoadFailed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'de',
    'en',
    'es',
    'fr',
    'ja',
    'ko',
    'pt',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'pt':
      return AppLocalizationsPt();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
