import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:path_provider/path_provider.dart';

import 'package:hermes_mobile/core/network/connection_store.dart';
import 'package:hermes_mobile/core/network/secure_cookie_storage.dart';

/// Desktop-parity remote gateway auth.
///
/// Flow (mirrors apps/desktop/electron/main.cjs + hermes_cli/dashboard_auth):
/// 1. GET  /api/status              → auth_required?
/// 2. GET  /api/auth/providers      → password vs OAuth providers
/// 3. POST /auth/password-login     → Set-Cookie (hermes_session_at / _rt)
/// 4. POST /api/auth/ws-ticket      → single-use ticket for /api/ws?ticket=
///
/// No API_SERVER_KEY. Credentials are username/password against a
/// `supports_password` provider; the session lives in cookies afterward.
class GatewayAuthClient {
  GatewayAuthClient({required this.baseUrl, CookieJar? cookieJar, Dio? dio})
    : _jar = cookieJar ?? CookieJar(),
      dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: _normalize(baseUrl),
              connectTimeout: const Duration(seconds: 12),
              receiveTimeout: const Duration(seconds: 30),
              headers: {'Accept': 'application/json'},
              // Password login returns Set-Cookie; follow redirects carefully.
              followRedirects: false,
              validateStatus: (s) => s != null && s < 500,
            ),
          ) {
    this.dio.interceptors.add(CookieManager(_jar));
  }

  final String baseUrl;
  final Dio dio;
  final CookieJar _jar;

  CookieJar get cookieJar => _jar;

  // A reconnect used to construct a fresh PersistCookieJar every time, which
  // forced another Keychain read immediately before every WS ticket request.
  // Keep one live jar per saved gateway so ordinary reconnects use the cookies
  // already loaded in this process. Login, reauth, and disconnect all obtain
  // this same instance, so their delete/write operations remain authoritative.
  static final Map<String, Future<PersistCookieJar>> _persistentJars = {};

  static String _normalize(String raw) {
    var v = raw.trim();
    while (v.endsWith('/')) {
      v = v.substring(0, v.length - 1);
    }
    return v;
  }

  /// Persistable cookie jar backed by Keychain / EncryptedSharedPreferences.
  ///
  /// The legacy file store is migration-only. Its contents are moved into
  /// secure storage on first read so upgrades preserve existing sessions.
  ///
  /// [ignoreExpires] is true so an expired access-token cookie is still sent
  /// with the refresh token — server middleware then rotates transparently
  /// (same as Desktop). If we drop expired AT cookies, some hosts only see a
  /// bare RT and still 401 if refresh is not triggered the same way.
  static Future<PersistCookieJar> persistentJar(String gatewayId) async {
    final cached = _persistentJars[gatewayId];
    if (cached != null) return cached;

    final created = _createPersistentJar(gatewayId);
    _persistentJars[gatewayId] = created;
    try {
      return await created;
    } catch (_) {
      if (identical(_persistentJars[gatewayId], created)) {
        _persistentJars.remove(gatewayId);
      }
      rethrow;
    }
  }

  static Future<PersistCookieJar> _createPersistentJar(String gatewayId) async {
    final root = await getApplicationSupportDirectory();
    final safe = gatewayId.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    final dir = Directory('${root.path}/gateway_cookies/$safe');
    await dir.create(recursive: true);
    final legacy = FileStorage(dir.path);
    return PersistCookieJar(
      ignoreExpires: true,
      storage: SecureCookieStorage(
        namespace: safe,
        secureStorage: ConnectionStore.durableSecureStorage(),
        legacyStorage: legacy,
      ),
    );
  }

  /// Validate a gateway base URL before any request is attempted.
  ///
  /// HTTPS is always allowed. Plain HTTP is allowed for loopback and for
  /// private/trusted network space (LAN, VPN mesh, mDNS) because that
  /// traffic never leaves the user's own network — VPN mesh traffic (e.g.
  /// Tailscale/WireGuard) is already encrypted at the tunnel layer. Plain
  /// HTTP to ordinary public hosts remains blocked to protect agent
  /// credentials.
  static String? validateBaseUrl(String raw) {
    final uri = Uri.tryParse(raw.trim());
    if (uri == null ||
        !uri.hasScheme ||
        !uri.hasAuthority ||
        uri.host.isEmpty) {
      return 'Enter a complete gateway URL.';
    }
    final scheme = uri.scheme.toLowerCase();
    if (scheme != 'http' && scheme != 'https') {
      return 'Use https:// (or http:// for a private network / VPN).';
    }
    if (uri.userInfo.isNotEmpty) {
      return 'Do not put credentials in the gateway URL.';
    }
    if (uri.hasQuery || uri.hasFragment) {
      return 'Gateway URLs cannot include a query or fragment.';
    }
    if (uri.path.isNotEmpty && uri.path != '/') {
      return 'Gateway URLs cannot include a path.';
    }
    final host = _canonicalHost(uri.host);
    // Deliberately the *precise* pair, not [isPrivateOrLoopbackHost]: that one
    // fails closed (unknown ⇒ private), which is right for refusing an image
    // fetch but would be backwards here — it would hand plain HTTP to every
    // host this file cannot classify.
    if (scheme != 'https' &&
        !_isLoopbackHost(host) &&
        !_isPrivateNetworkHost(host)) {
      return 'Remote gateways require HTTPS to protect agent credentials.';
    }
    return null;
  }

  /// True when [raw] parses as a plain `http://` URL pointed at an allowed
  /// non-loopback private/VPN host (LAN, Tailscale, mDNS, CGNAT). Used by
  /// the UI to decide whether to show a non-blocking "unencrypted" hint;
  /// loopback and https:// never need it.
  static bool isUnencryptedPrivateNetworkUrl(String raw) {
    final uri = Uri.tryParse(raw.trim());
    if (uri == null ||
        !uri.hasScheme ||
        !uri.hasAuthority ||
        uri.host.isEmpty) {
      return false;
    }
    if (uri.scheme.toLowerCase() != 'http') return false;
    final host = _canonicalHost(uri.host);
    if (_isLoopbackHost(host)) return false;
    return _isPrivateNetworkHost(host);
  }

  /// True when [host] must NOT be handed a same-network request the user
  /// cannot vet — loopback, private/trusted network space (RFC1918 LAN,
  /// link-local, CGNAT/tailnet, mDNS `.local`, MagicDNS `.ts.net`, IPv6 ULA),
  /// **or any host this file cannot positively recognise as public**.
  ///
  /// Exposed so other layers can recognise a LAN-flavoured target without
  /// re-deriving the ranges. The Markdown image gate
  /// (`features/sessions/message_markdown.dart`) uses it to refuse
  /// tap-to-load for such hosts.
  ///
  /// **Fails closed, unlike [validateBaseUrl].** The two callers want opposite
  /// defaults for an unclassifiable host: refusing to fetch an image is cheap,
  /// while refusing a gateway URL locks the user out, so [validateBaseUrl]
  /// keeps using the precise `_isLoopbackHost`/`_isPrivateNetworkHost` pair and
  /// only this entry point treats "not recognisably public" as private.
  /// Recognisably public means a dotted DNS name with a plausible TLD, or an
  /// IP literal that parses and lands outside every special-use range;
  /// single-label names (`intranet`, resolved through the DHCP search domain),
  /// unparseable IPv6, and numeric junk all come back true.
  ///
  /// Every non-canonical spelling of an address is normalised first, because
  /// the classification is otherwise trivial to evade: `Uri` does not
  /// canonicalise IPv6 (`0:0:0:0:0:0:0:1`), and IPv4 literals are legal in
  /// integer (`2130706433`), hex (`0x7f000001`), octal, and short
  /// (`127.1`) forms, all of which `connect()` resolves to 127.0.0.1.
  ///
  /// KNOWN RESIDUAL — this is string inspection, so it cannot stop **DNS
  /// rebinding**: `images.attacker.example` is a perfectly public-looking name
  /// that may resolve to 192.168.1.1 at fetch time, and nothing here (or
  /// anywhere else in-process, short of pinning the resolved address and
  /// re-checking it below the HTTP client) would notice. What this function
  /// buys is that the *literal* SSRF cases — the ones an LLM-authored message
  /// can express directly — are refused, and a public-looking host at least
  /// still costs the attacker a domain the user can read in the placeholder.
  static bool isPrivateOrLoopbackHost(String host) {
    final h = _canonicalHost(host);
    if (h.isEmpty) return true; // Nothing to vet — fail closed.
    if (_isLoopbackHost(h) || _isPrivateNetworkHost(h)) return true;
    return !_looksPublicHost(h);
  }

  /// Strips the syntax `Uri` leaves attached to a host so the classifiers see
  /// one canonical spelling: `[…]` IPv6 brackets, an `%en0` zone id, and the
  /// trailing root dot of an absolute FQDN.
  static String _canonicalHost(String host) {
    var h = host.trim().toLowerCase();
    h = h.replaceAll('[', '').replaceAll(']', '');
    final zone = h.indexOf('%');
    if (zone >= 0) h = h.substring(0, zone);
    while (h.length > 1 && h.endsWith('.')) {
      h = h.substring(0, h.length - 1);
    }
    return h;
  }

  static bool _isLoopbackHost(String host) {
    if (host == 'localhost') return true;
    final v6 = _parseIPv6(host);
    if (v6 != null) {
      // `::` (unspecified) and `::1` in any spelling.
      if (v6.every((b) => b == 0)) return true;
      final embedded = _embeddedIPv4(v6);
      if (embedded != null) return _isLoopbackIPv4(embedded);
      return v6.take(15).every((b) => b == 0) && v6[15] == 1;
    }
    final v4 = _parseIPv4(host);
    return v4 != null && _isLoopbackIPv4(v4);
  }

  /// 127.0.0.0/8, plus 0.0.0.0/8 — `connect()` to `0.0.0.0` reaches the local
  /// host on every platform this app ships to, so it is loopback in practice.
  static bool _isLoopbackIPv4(List<int> v4) => v4[0] == 127 || v4[0] == 0;

  /// RFC1918 private ranges, link-local, CGNAT (Tailscale tailnet IPs),
  /// mDNS `.local` hostnames, and Tailscale MagicDNS `.ts.net` hostnames,
  /// plus the IPv6 equivalents (ULA `fc00::/7`, link-local `fe80::/10`) and
  /// the non-unicast IPv4/IPv6 space nothing should ever be fetched from.
  /// Does not include loopback — see [_isLoopbackHost].
  static bool _isPrivateNetworkHost(String host) {
    if (host.endsWith('.local') || host.endsWith('.ts.net')) return true;
    final v6 = _parseIPv6(host);
    if (v6 != null) {
      // An IPv4-mapped/-compatible address is an IPv4 address wearing a hat:
      // `::ffff:192.168.1.1` connects to 192.168.1.1.
      final embedded = _embeddedIPv4(v6);
      if (embedded != null) return _isPrivateIPv4(embedded);
      if ((v6[0] & 0xfe) == 0xfc) return true; // fc00::/7 unique local
      if (v6[0] == 0xfe && (v6[1] & 0xc0) == 0x80) return true; // fe80::/10
      if (v6[0] == 0xff) return true; // ff00::/8 multicast
      return false;
    }
    final v4 = _parseIPv4(host);
    return v4 != null && _isPrivateIPv4(v4);
  }

  static bool _isPrivateIPv4(List<int> v4) {
    final a = v4[0], b = v4[1];
    if (a == 10) return true; // 10.0.0.0/8
    if (a == 172 && b >= 16 && b <= 31) return true; // 172.16.0.0/12
    if (a == 192 && b == 168) return true; // 192.168.0.0/16
    if (a == 169 && b == 254) return true; // 169.254.0.0/16 link-local
    if (a == 100 && b >= 64 && b <= 127) return true; // 100.64.0.0/10 CGNAT
    if (a >= 224) return true; // 224/4 multicast, 240/4 reserved, broadcast
    return false;
  }

  /// [Uri.parseIPv6Address] guarded, so a host that merely *contains* a colon
  /// does not throw. Returns the 16 address bytes, or null when [host] is not
  /// an IPv6 literal at all.
  static List<int>? _parseIPv6(String host) {
    if (!host.contains(':')) return null;
    try {
      return Uri.parseIPv6Address(host);
    } on FormatException {
      return null;
    }
  }

  /// The four IPv4 bytes an IPv6 address carries when it is really an IPv4
  /// address — `::ffff:a.b.c.d` (mapped) or the deprecated `::a.b.c.d`
  /// (compatible) — else null. `::` and `::1` are excluded: those are handled
  /// as IPv6 loopback rather than as 0.0.0.0 / 0.0.0.1.
  static List<int>? _embeddedIPv4(List<int> v6) {
    for (var i = 0; i < 10; i++) {
      if (v6[i] != 0) return null;
    }
    final mapped = v6[10] == 0xff && v6[11] == 0xff;
    final compatible = v6[10] == 0 && v6[11] == 0;
    if (!mapped && !compatible) return null;
    final tail = v6.sublist(12);
    if (compatible && tail[0] == 0 && tail[1] == 0 && tail[2] == 0) {
      return null; // `::` / `::1` — not a meaningful IPv4 literal.
    }
    return tail;
  }

  /// Hostname shape check: labels of letters/digits/hyphens (underscores
  /// tolerated — they appear in real service records), 1–253 chars total.
  static final RegExp _dnsHostname = RegExp(
    r'^(?=.{1,253}$)[a-z0-9_]([a-z0-9_-]{0,61}[a-z0-9_])?'
    r'(\.[a-z0-9_]([a-z0-9_-]{0,61}[a-z0-9_])?)*$',
  );

  /// A plausible public TLD: alphabetic, or an IDN `xn--` A-label.
  static final RegExp _publicTld = RegExp(r'^([a-z]{2,}|xn--[a-z0-9-]{2,})$');

  /// Positive recognition of a public target, for the fail-closed default in
  /// [isPrivateOrLoopbackHost]. Assumes the private/loopback checks already
  /// said no.
  static bool _looksPublicHost(String host) {
    // IPv6 counts as public only when it actually parses — a colon-bearing
    // host we could not read tells us nothing, so it fails closed.
    if (host.contains(':')) return _parseIPv6(host) != null;
    // A parseable literal that got here is outside every special-use range.
    if (_parseIPv4(host) != null) return true;
    if (!_dnsHostname.hasMatch(host)) return false;
    final labels = host.split('.');
    // Single-label names resolve through the DHCP search domain — i.e. the
    // local network — so they are exactly the case the image gate refuses.
    if (labels.length < 2) return false;
    return _publicTld.hasMatch(labels.last);
  }

  /// Parses an IPv4 literal in **any** form `inet_aton`/`connect()` accepts —
  /// dotted quad, but also the short (`127.1`), integer (`2130706433`), hex
  /// (`0x7f000001`) and octal (`0177.0.0.1`) spellings — into 4 octets, or
  /// null if [host] is not an IPv4 address. Checking only the dotted quad let
  /// every other spelling of 127.0.0.1 through the private-host gate.
  static List<int>? _parseIPv4(String host) {
    if (host.isEmpty) return null;
    final parts = host.split('.');
    if (parts.length > 4) return null;
    final values = <int>[];
    for (final part in parts) {
      final n = _parseIPv4Part(part);
      if (n == null) return null;
      values.add(n);
    }
    // inet_aton: the final part spreads over every octet the leading parts
    // did not claim — `127.1` is 127.0.0.1, `2130706433` is the whole word.
    final octets = <int>[];
    for (var i = 0; i < values.length - 1; i++) {
      if (values[i] > 0xff) return null;
      octets.add(values[i]);
    }
    const maxForWidth = <int>[0, 0xff, 0xffff, 0xffffff, 0xffffffff];
    final remaining = 4 - octets.length;
    final tail = values.last;
    if (tail > maxForWidth[remaining]) return null;
    for (var shift = remaining - 1; shift >= 0; shift--) {
      octets.add((tail >> (8 * shift)) & 0xff);
    }
    return octets;
  }

  static final RegExp _hexPart = RegExp(r'^0x[0-9a-f]{1,8}$');
  static final RegExp _octalPart = RegExp(r'^0[0-7]{1,11}$');
  static final RegExp _decimalPart = RegExp(r'^\d{1,10}$');

  static int? _parseIPv4Part(String part) {
    if (part.isEmpty) return null;
    if (part.startsWith('0x')) {
      if (!_hexPart.hasMatch(part)) return null;
      return int.parse(part.substring(2), radix: 16);
    }
    if (part.length > 1 && part.startsWith('0')) {
      if (!_octalPart.hasMatch(part)) return null;
      return int.parse(part.substring(1), radix: 8);
    }
    if (!_decimalPart.hasMatch(part)) return null;
    final n = int.parse(part);
    return n > 0xffffffff ? null : n;
  }

  /// Public probe — no credentials (Desktop probeRemoteAuthMode).
  static Future<GatewayAuthProbe> probe(String baseUrl) async {
    final base = _normalize(baseUrl);
    final dio = Dio(
      BaseOptions(
        baseUrl: base,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Accept': 'application/json'},
      ),
    );

    Map<String, dynamic>? status;
    try {
      final res = await dio.get<Map<String, dynamic>>('/api/status');
      status = res.data;
    } catch (e) {
      return GatewayAuthProbe(
        baseUrl: base,
        reachable: false,
        authMode: GatewayAuthMode.unknown,
        error: e.toString(),
      );
    }

    final authRequired = status?['auth_required'] == true;
    final providers = <GatewayAuthProvider>[];

    if (authRequired) {
      try {
        final res = await dio.get<Map<String, dynamic>>('/api/auth/providers');
        final raw = res.data?['providers'];
        if (raw is List) {
          for (final p in raw) {
            if (p is Map) {
              final name = '${p['name'] ?? ''}'.trim();
              if (name.isEmpty) continue;
              providers.add(
                GatewayAuthProvider(
                  name: name,
                  displayName:
                      '${p['display_name'] ?? p['displayName'] ?? name}',
                  supportsPassword:
                      p['supports_password'] == true ||
                      p['supportsPassword'] == true,
                ),
              );
            }
          }
        }
      } catch (_) {
        // Optional metadata — auth mode already known.
      }
    }

    return GatewayAuthProbe(
      baseUrl: base,
      reachable: true,
      authMode: authRequired ? GatewayAuthMode.session : GatewayAuthMode.open,
      providers: providers,
      version: status?['version']?.toString(),
    );
  }

  /// POST /auth/password-login — Desktop login page body shape.
  Future<void> passwordLogin({
    required String provider,
    required String username,
    required String password,
  }) async {
    final urlError = validateBaseUrl(baseUrl);
    if (urlError != null) throw GatewayAuthException(urlError);
    final res = await dio.post<Map<String, dynamic>>(
      '/auth/password-login',
      data: {
        'provider': provider,
        'username': username,
        'password': password,
        'next': '',
      },
      options: Options(
        contentType: Headers.jsonContentType,
        headers: {'Content-Type': 'application/json'},
      ),
    );

    final code = res.statusCode ?? 0;
    if (code == 401) {
      throw GatewayAuthException('Invalid username or password.');
    }
    if (code == 429) {
      throw GatewayAuthException('Too many attempts. Wait and try again.');
    }
    if (code == 404) {
      throw GatewayAuthException('Unknown auth provider on this gateway.');
    }
    if (code < 200 || code >= 300) {
      final detail = res.data is Map ? res.data!['detail'] : null;
      throw GatewayAuthException(
        detail != null ? '$detail' : 'Sign-in failed (HTTP $code).',
      );
    }
    final ok = res.data is Map && res.data!['ok'] == true;
    if (!ok && code != 200) {
      throw GatewayAuthException('Sign-in failed.');
    }
    // Cookies are now in the jar via CookieManager.
  }

  /// POST /api/auth/ws-ticket — requires live session cookies.
  ///
  /// 401/403 → [GatewayAuthException.needsReauth]. Callers must prompt
  /// interactive login (no silent password re-login — kicks are intentional).
  Future<String> mintWsTicket({
    @Deprecated('Silent re-login removed; do not pass relogin')
    Future<void> Function()? relogin,
  }) async {
    final res = await dio.post<Map<String, dynamic>>(
      '/api/auth/ws-ticket',
      options: Options(
        contentType: Headers.jsonContentType,
        validateStatus: (s) => s != null && s < 500,
      ),
    );
    if (res.statusCode == 401 || res.statusCode == 403) {
      throw GatewayAuthException(
        'Session expired. Sign in again.',
        needsReauth: true,
      );
    }
    if (res.statusCode != 200) {
      throw GatewayAuthException(
        'Could not mint WebSocket ticket (HTTP ${res.statusCode}).',
      );
    }
    final ticket = res.data?['ticket'];
    if (ticket is! String || ticket.isEmpty) {
      throw GatewayAuthException('Gateway did not return a WS ticket.');
    }
    return ticket;
  }

  /// Whether the jar currently has a session access cookie for [baseUrl].
  Future<bool> hasSessionCookie() async {
    final uri = Uri.parse(_normalize(baseUrl));
    final cookies = await _jar.loadForRequest(uri);
    return cookies.any(
      (c) =>
          c.name.contains('hermes_session_at') ||
          c.name.contains('hermes_session_rt'),
    );
  }
}

enum GatewayAuthMode {
  /// auth_required: true — cookie session (password or OAuth).
  session,

  /// auth_required: false — open / loopback (no password gate).
  open,

  unknown,
}

class GatewayAuthProvider {
  const GatewayAuthProvider({
    required this.name,
    required this.displayName,
    required this.supportsPassword,
  });

  final String name;
  final String displayName;
  final bool supportsPassword;
}

class GatewayAuthProbe {
  const GatewayAuthProbe({
    required this.baseUrl,
    required this.reachable,
    required this.authMode,
    this.providers = const [],
    this.version,
    this.error,
  });

  final String baseUrl;
  final bool reachable;
  final GatewayAuthMode authMode;
  final List<GatewayAuthProvider> providers;
  final String? version;
  final String? error;

  bool get isPasswordGateway =>
      authMode == GatewayAuthMode.session &&
      providers.isNotEmpty &&
      providers.every((p) => p.supportsPassword);

  List<GatewayAuthProvider> get passwordProviders =>
      providers.where((p) => p.supportsPassword).toList();
}

class GatewayAuthException implements Exception {
  GatewayAuthException(this.message, {this.needsReauth = false});
  final String message;
  final bool needsReauth;
  @override
  String toString() => message;
}
