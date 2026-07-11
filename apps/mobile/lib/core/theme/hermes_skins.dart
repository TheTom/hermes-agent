import 'package:flutter/material.dart';

/// Builtin skins for Hermes Go.
///
/// Two layers share the same [HermesPalette] token shape:
///
/// 1. **Desktop parity** — hand-port of `apps/desktop/src/themes/presets.ts`.
///    Ids, labels, and list order match Desktop `BUILTIN_THEME_LIST` so product
///    skins stay aligned when we port palette updates. Fonts stay system
///    defaults on mobile (Desktop typography is not applied).
///
/// 2. **Mobile-only extras** — skins that ship only on Go (e.g. anime packs).
///    Appended after [kDesktopParitySkinCount] so they never reorder Desktop
///    skins. Not present in Desktop presets; free to evolve without a Desktop
///    PR. The Appearance picker surfaces this split as "Desktop" / "Mobile".
///
/// Flat color tokens shared by every skin.
///
/// Shape mirrors Desktop `DesktopThemeColors` (minus desktop-only fields such
/// as popover / midground / typography) so hand-ports stay 1:1 for the parity
/// skins. Mobile-only skins use the same contract so [buildThemeData] and the
/// chat bubble contrast rules (primary @ 16% + foreground) apply uniformly.
class HermesPalette {
  const HermesPalette({
    required this.background,
    required this.foreground,
    required this.card,
    required this.cardForeground,
    required this.muted,
    required this.mutedForeground,
    required this.primary,
    required this.primaryForeground,
    required this.secondary,
    required this.secondaryForeground,
    required this.accent,
    required this.accentForeground,
    required this.border,
    required this.input,
    required this.ring,
    required this.destructive,
    required this.destructiveForeground,
    this.sidebarBackground,
    this.userBubble,
  });

  final Color background;
  final Color foreground;
  final Color card;
  final Color cardForeground;
  final Color muted;
  final Color mutedForeground;
  final Color primary;
  final Color primaryForeground;
  final Color secondary;
  final Color secondaryForeground;
  final Color accent;
  final Color accentForeground;
  final Color border;
  final Color input;
  final Color ring;
  final Color destructive;
  final Color destructiveForeground;
  final Color? sidebarBackground;
  final Color? userBubble;
}

class HermesSkin {
  const HermesSkin({
    required this.id,
    required this.label,
    required this.description,
    required this.colors,
    this.darkColors,
  });

  final String id;
  final String label;
  final String description;

  /// Light palette (or only palette when [darkColors] is null).
  final HermesPalette colors;

  /// Hand-tuned dark palette when present (e.g. Nous).
  final HermesPalette? darkColors;

  /// Whether this skin is primarily dark (for preview swatches).
  bool get prefersDark {
    if (darkColors != null) return false; // dual-mode
    return ThemeData.estimateBrightnessForColor(colors.background) ==
        Brightness.dark;
  }

  HermesPalette paletteFor(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return darkColors ?? colors;
    }
    // Dual-mode skins use light [colors]; single dark skins still use colors
    // for light mode (Desktop reuses the same palette when darkColors is null).
    return colors;
  }
}

Color _hex(String raw) {
  var s = raw.trim();
  if (s.startsWith('#')) s = s.substring(1);
  if (s.length == 6) s = 'FF$s';
  return Color(int.parse(s, radix: 16));
}

// ── Desktop-parity skins (from desktop presets.ts) ───────────────────
// Keep order and ids locked to Desktop BUILTIN_THEME_LIST.

const _nousBlue = Color(0xFF0053FD);
const _psycheBlue = Color(0xFF1540B1);
const _psycheWarm = Color(0xFFFFE6CB);

HermesPalette get _nousLight => HermesPalette(
  background: const Color(0xFFF8FAFF),
  foreground: const Color(0xFF17171A),
  card: const Color(0xFFFFFFFF),
  cardForeground: const Color(0xFF17171A),
  muted: Color.lerp(_nousBlue, Colors.white, 0.95)!,
  mutedForeground: const Color(0xFF666678),
  primary: _nousBlue,
  primaryForeground: const Color(0xFFFCFCFC),
  secondary: Color.lerp(_nousBlue, Colors.white, 0.93)!,
  secondaryForeground: const Color(0xFF242432),
  accent: Color.lerp(_nousBlue, Colors.white, 0.90)!,
  accentForeground: const Color(0xFF202030),
  border: _nousBlue.withValues(alpha: 0.22),
  input: _nousBlue.withValues(alpha: 0.30),
  ring: _nousBlue,
  destructive: const Color(0xFFC72E4D),
  destructiveForeground: Colors.white,
  sidebarBackground: const Color(0xFFF3F7FF),
  userBubble: Color.lerp(_nousBlue, Colors.white, 0.94)!,
);

HermesPalette get _nousDark => const HermesPalette(
  background: Color(0xFF0D2F86),
  foreground: _psycheWarm,
  card: Color(0xFF12378F),
  cardForeground: _psycheWarm,
  muted: Color(0xFF183F9A),
  mutedForeground: Color(0xFFB5C7F3),
  primary: _psycheWarm,
  primaryForeground: Color(0xFF0D2F86),
  secondary: Color(0xFF1B45A4),
  secondaryForeground: Color(0xFFE0E8FF),
  accent: _psycheBlue,
  accentForeground: Color(0xFFF0F4FF),
  border: Color(0xFF3158AD),
  input: Color(0xFF0B2566),
  ring: _psycheWarm,
  destructive: Color(0xFFC0473A),
  destructiveForeground: Color(0xFFFEF2F2),
  sidebarBackground: Color(0xFF09286F),
  userBubble: Color(0xFF143B91),
);

final HermesSkin nousSkin = HermesSkin(
  id: 'nous',
  label: 'Nous',
  description: 'Glass neutrals with Nous blue accents',
  colors: _nousLight,
  darkColors: _nousDark,
);

final HermesSkin midnightSkin = HermesSkin(
  id: 'midnight',
  label: 'Midnight',
  description: 'Deep blue-violet with cool accents',
  colors: HermesPalette(
    background: _hex('#08081c'),
    foreground: _hex('#ddd6ff'),
    card: _hex('#0d0d28'),
    cardForeground: _hex('#ddd6ff'),
    muted: _hex('#13133a'),
    mutedForeground: _hex('#7c7ab0'),
    primary: _hex('#ddd6ff'),
    primaryForeground: _hex('#08081c'),
    secondary: _hex('#1a1a4a'),
    secondaryForeground: _hex('#c4bff0'),
    accent: _hex('#1a1a44'),
    accentForeground: _hex('#d0c8ff'),
    border: _hex('#1e1e52'),
    input: _hex('#1e1e52'),
    ring: _hex('#8b80e8'),
    destructive: _hex('#b03060'),
    destructiveForeground: _hex('#fef2f2'),
    sidebarBackground: _hex('#06061a'),
    userBubble: _hex('#14143a'),
  ),
);

final HermesSkin emberSkin = HermesSkin(
  id: 'ember',
  label: 'Ember',
  description: 'Warm crimson and bronze — forge vibes',
  colors: HermesPalette(
    background: _hex('#160800'),
    foreground: _hex('#ffd8b0'),
    card: _hex('#1e0e04'),
    cardForeground: _hex('#ffd8b0'),
    muted: _hex('#2a1408'),
    mutedForeground: _hex('#aa7a56'),
    primary: _hex('#ffd8b0'),
    primaryForeground: _hex('#160800'),
    secondary: _hex('#341800'),
    secondaryForeground: _hex('#f0c090'),
    accent: _hex('#301600'),
    accentForeground: _hex('#e8c080'),
    border: _hex('#3a1c08'),
    input: _hex('#3a1c08'),
    ring: _hex('#d97316'),
    destructive: _hex('#c43010'),
    destructiveForeground: _hex('#fef2f2'),
    sidebarBackground: _hex('#100600'),
    userBubble: _hex('#2a1000'),
  ),
);

final HermesSkin monoSkin = HermesSkin(
  id: 'mono',
  label: 'Mono',
  description: 'Clean grayscale — minimal and focused',
  colors: HermesPalette(
    background: _hex('#0e0e0e'),
    foreground: _hex('#eaeaea'),
    card: _hex('#141414'),
    cardForeground: _hex('#eaeaea'),
    muted: _hex('#1e1e1e'),
    mutedForeground: _hex('#808080'),
    primary: _hex('#eaeaea'),
    primaryForeground: _hex('#0e0e0e'),
    secondary: _hex('#262626'),
    secondaryForeground: _hex('#c8c8c8'),
    accent: _hex('#222222'),
    accentForeground: _hex('#d8d8d8'),
    border: _hex('#2a2a2a'),
    input: _hex('#2a2a2a'),
    ring: _hex('#9a9a9a'),
    destructive: _hex('#a84040'),
    destructiveForeground: _hex('#fef2f2'),
    sidebarBackground: _hex('#0a0a0a'),
    userBubble: _hex('#1a1a1a'),
  ),
);

final HermesSkin cyberpunkSkin = HermesSkin(
  id: 'cyberpunk',
  label: 'Cyberpunk',
  description: 'Neon green on black — matrix terminal',
  colors: HermesPalette(
    background: _hex('#000a00'),
    foreground: _hex('#00ff41'),
    card: _hex('#001200'),
    cardForeground: _hex('#00ff41'),
    muted: _hex('#001a00'),
    mutedForeground: _hex('#1a8a30'),
    primary: _hex('#00ff41'),
    primaryForeground: _hex('#000a00'),
    secondary: _hex('#002800'),
    secondaryForeground: _hex('#00cc34'),
    accent: _hex('#002000'),
    accentForeground: _hex('#00e038'),
    border: _hex('#003000'),
    input: _hex('#003000'),
    ring: _hex('#00ff41'),
    destructive: _hex('#ff003c'),
    destructiveForeground: _hex('#000a00'),
    sidebarBackground: _hex('#000600'),
    userBubble: _hex('#001400'),
  ),
);

final HermesSkin slateSkin = HermesSkin(
  id: 'slate',
  label: 'Slate',
  description: 'Cool slate blue — focused developer theme',
  colors: HermesPalette(
    background: _hex('#0d1117'),
    foreground: _hex('#c9d1d9'),
    card: _hex('#161b22'),
    cardForeground: _hex('#c9d1d9'),
    muted: _hex('#21262d'),
    mutedForeground: _hex('#8b949e'),
    primary: _hex('#c9d1d9'),
    primaryForeground: _hex('#0d1117'),
    secondary: _hex('#2a3038'),
    secondaryForeground: _hex('#adb5bf'),
    accent: _hex('#1e2530'),
    accentForeground: _hex('#c0c8d0'),
    border: _hex('#30363d'),
    input: _hex('#30363d'),
    ring: _hex('#58a6ff'),
    destructive: _hex('#cf4848'),
    destructiveForeground: _hex('#fef2f2'),
    sidebarBackground: _hex('#090d13'),
    userBubble: _hex('#1e2a38'),
  ),
);

// ── Anime-inspired mobile-only skins ─────────────────────────────────
//
// These are NOT ported from desktop presets.ts — they live after the
// Desktop BUILTIN_THEME_LIST order (nous…slate) so shared product skins
// stay in lockstep. Contrast notes (session_chat_screen.dart ~1639):
// user bubble = primary @ 16% over background, text = foreground.

// ── Sakura Night — cherry blossoms over a Tokyo night sky ──

final HermesSkin sakuraNightSkin = HermesSkin(
  id: 'sakura-night',
  label: 'Sakura Night',
  description: 'Cherry blossom pink on deep indigo night',
  colors: HermesPalette(
    background: _hex('#131022'),
    foreground: _hex('#f2dce6'),
    card: _hex('#191530'),
    cardForeground: _hex('#f2dce6'),
    muted: _hex('#221c3e'),
    mutedForeground: _hex('#9a8ab8'),
    primary: _hex('#ff8fb3'), // blossom pink — 16% tint = soft pink bubble
    primaryForeground: _hex('#2a1020'),
    secondary: _hex('#2a2350'),
    secondaryForeground: _hex('#d8c8ec'),
    accent: _hex('#251e48'),
    accentForeground: _hex('#e8d0e0'),
    border: _hex('#2e2752'),
    input: _hex('#2e2752'),
    ring: _hex('#ff8fb3'),
    destructive: _hex('#d94360'),
    destructiveForeground: _hex('#fef2f2'),
    sidebarBackground: _hex('#0e0b1c'),
    userBubble: _hex('#241a3a'),
  ),
);

// ── Neo-Tokyo — 80s cyberpunk anime, magenta/cyan duotone ──
// Deliberately distinct from `cyberpunk` (green terminal): pink neon
// primary with an electric-cyan ring.

final HermesSkin neoTokyoSkin = HermesSkin(
  id: 'neo-tokyo',
  label: 'Neo-Tokyo',
  description: 'Neon magenta and cyan — 80s anime city',
  colors: HermesPalette(
    background: _hex('#0d0616'),
    foreground: _hex('#f0e6ff'),
    card: _hex('#140a20'),
    cardForeground: _hex('#f0e6ff'),
    muted: _hex('#1c1030'),
    mutedForeground: _hex('#8f7fb0'),
    primary: _hex('#ff2e88'), // hot magenta — vivid 16% bubble tint
    primaryForeground: _hex('#16041c'),
    secondary: _hex('#241238'),
    secondaryForeground: _hex('#e0ccf5'),
    accent: _hex('#1a0f3a'),
    accentForeground: _hex('#7feeff'),
    border: _hex('#2c1846'),
    input: _hex('#2c1846'),
    ring: _hex('#2ee6ff'), // electric cyan focus ring
    destructive: _hex('#ff1744'),
    destructiveForeground: _hex('#fef2f2'),
    sidebarBackground: _hex('#090410'),
    userBubble: _hex('#22103a'),
  ),
);

// ── Mecha — classic mecha-unit purple/acid-green tension ──

final HermesSkin mechaSkin = HermesSkin(
  id: 'mecha',
  label: 'Mecha',
  description: 'Acid green on armored violet — unit ready',
  colors: HermesPalette(
    background: _hex('#14121e'),
    foreground: _hex('#e2e0ee'),
    card: _hex('#1a1728'),
    cardForeground: _hex('#e2e0ee'),
    muted: _hex('#232034'),
    mutedForeground: _hex('#8d88a5'),
    primary: _hex('#9dff2e'), // acid green — unmistakable 16% tint
    primaryForeground: _hex('#101408'),
    secondary: _hex('#2c2545'),
    secondaryForeground: _hex('#cfc4ee'),
    accent: _hex('#262040'),
    accentForeground: _hex('#b8a8e8'),
    border: _hex('#2e2a44'),
    input: _hex('#2e2a44'),
    ring: _hex('#9dff2e'),
    destructive: _hex('#ff6b1a'), // warning orange
    destructiveForeground: _hex('#201000'),
    sidebarBackground: _hex('#0f0d18'),
    userBubble: _hex('#201d30'),
  ),
);

// ── Sumi — sumi-e ink painting; DUAL-MODE (second after Nous) ──
// Light: warm paper + ink + vermilion seal-stamp ring.
// Dark: inverted ink slab so ColorScheme(brightness: dark) gets a real
// dark palette instead of paper.

HermesPalette get _sumiLight => HermesPalette(
  background: _hex('#f5f1e8'),
  foreground: _hex('#1c1a17'),
  card: _hex('#fbf8f1'),
  cardForeground: _hex('#1c1a17'),
  muted: _hex('#e9e3d6'),
  mutedForeground: _hex('#6e675c'),
  primary: _hex('#c2402e'), // vermilion — 16% tint = warm blush bubble
  primaryForeground: _hex('#fff8f0'),
  secondary: _hex('#ece5d4'),
  secondaryForeground: _hex('#3a352c'),
  accent: _hex('#e5ddc9'),
  accentForeground: _hex('#33302a'),
  border: _hex('#d8d0bf'),
  input: _hex('#d8d0bf'),
  ring: _hex('#c2402e'),
  destructive: _hex('#a82a1a'),
  destructiveForeground: _hex('#fef2f2'),
  sidebarBackground: _hex('#efe9dd'),
  userBubble: _hex('#f0e4d8'),
);

HermesPalette get _sumiDark => HermesPalette(
  background: _hex('#141210'),
  foreground: _hex('#ece5d4'),
  card: _hex('#1b1815'),
  cardForeground: _hex('#ece5d4'),
  muted: _hex('#26221d'),
  mutedForeground: _hex('#98907f'),
  primary: _hex('#e05540'), // brighter vermilion for dark ink ground
  primaryForeground: _hex('#1a0805'),
  secondary: _hex('#2e2922'),
  secondaryForeground: _hex('#d8d0bd'),
  accent: _hex('#2a251e'),
  accentForeground: _hex('#e0d6c0'),
  border: _hex('#342e26'),
  input: _hex('#342e26'),
  ring: _hex('#e05540'),
  destructive: _hex('#c0392b'),
  destructiveForeground: _hex('#fef2f2'),
  sidebarBackground: _hex('#0f0d0b'),
  userBubble: _hex('#251f18'),
);

final HermesSkin sumiSkin = HermesSkin(
  id: 'sumi',
  label: 'Sumi',
  description: 'Ink on paper with a vermilion seal',
  colors: _sumiLight,
  darkColors: _sumiDark,
);

// ── Shonen — high-energy battle palette ──

final HermesSkin shonenSkin = HermesSkin(
  id: 'shonen',
  label: 'Shonen',
  description: 'Blazing orange on midnight navy — plus ultra',
  colors: HermesPalette(
    background: _hex('#0c1226'),
    foreground: _hex('#eaeefc'),
    card: _hex('#121a34'),
    cardForeground: _hex('#eaeefc'),
    muted: _hex('#1a2442'),
    mutedForeground: _hex('#8391b8'),
    primary: _hex('#ff9424'), // blazing orange — 16% tint = warm bubble
    primaryForeground: _hex('#1c0e00'),
    secondary: _hex('#20305c'),
    secondaryForeground: _hex('#c8d4f2'),
    accent: _hex('#1c2850'),
    accentForeground: _hex('#a8c4ff'),
    border: _hex('#263258'),
    input: _hex('#263258'),
    ring: _hex('#3d8bff'), // electric blue focus ring
    destructive: _hex('#e03e3e'),
    destructiveForeground: _hex('#fef2f2'),
    sidebarBackground: _hex('#080d1e'),
    userBubble: _hex('#1a2a4a'),
  ),
);

/// Count of Desktop-parity skins at the head of [kBuiltinSkins].
///
/// Appearance picker and any "Desktop vs Mobile" split must use this constant
/// so a new Desktop port extends the head without reshuffling mobile extras.
const kDesktopParitySkinCount = 6;

/// All selectable skins: Desktop parity first, then mobile-only extras.
///
/// Do not reorder the Desktop head; append mobile-only skins only.
final List<HermesSkin> kBuiltinSkins = [
  // Desktop parity (presets.ts order) — do not reorder:
  nousSkin,
  midnightSkin,
  emberSkin,
  monoSkin,
  cyberpunkSkin,
  slateSkin,
  // Mobile-only extras (not in Desktop presets.ts):
  sakuraNightSkin,
  neoTokyoSkin,
  mechaSkin,
  sumiSkin,
  shonenSkin,
];

/// Multi-color leading swatch for the Appearance picker.
///
/// Shows background | card | primary | ring so duotone skins (e.g. Neo-Tokyo)
/// read in the list — a single primary dot is not enough.
class SkinSwatchRow extends StatelessWidget {
  const SkinSwatchRow({
    super.key,
    required this.skin,
    required this.brightness,
  });

  final HermesSkin skin;
  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    final p = skin.paletteFor(brightness);
    final swatches = [p.background, p.card, p.primary, p.ring];
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.4),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (i, c) in swatches.indexed)
            Container(
              width: 12,
              height: 24,
              decoration: BoxDecoration(
                color: c,
                borderRadius: BorderRadius.horizontal(
                  left: i == 0 ? const Radius.circular(6) : Radius.zero,
                  right: i == swatches.length - 1
                      ? const Radius.circular(6)
                      : Radius.zero,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

const kDefaultSkinId = 'nous';

HermesSkin skinById(String? id) {
  final key = (id ?? kDefaultSkinId).trim().toLowerCase();
  for (final s in kBuiltinSkins) {
    if (s.id == key) return s;
  }
  return nousSkin;
}

/// Build Flutter [ThemeData] from a desktop skin palette.
///
/// [brightness] is the *requested slot* (light vs dark theme) and is used
/// only to pick which palette [HermesSkin.paletteFor] hands back — dual-mode
/// skins (e.g. Nous) have distinct light/dark palettes, but single-palette
/// skins (midnight/ember/mono/cyberpunk/slate) reuse the same dark-looking
/// palette for both slots. Everything brightness-sensitive below must
/// instead key off the palette that was actually resolved, or Material
/// internals that trust `ThemeData.brightness` (SnackBar inverseSurface,
/// elevation overlays, AppBar status-bar icon color, text selection
/// defaults, ...) end up disagreeing with what's actually on screen. See
/// [HermesSkin.prefersDark] for the same background-color estimation.
ThemeData buildThemeData(HermesSkin skin, Brightness brightness) {
  final p = skin.paletteFor(brightness);
  final effectiveBrightness = ThemeData.estimateBrightnessForColor(
    p.background,
  );
  // M3 *container* tokens must be set explicitly. If omitted, Flutter falls
  // back container -> base (primaryContainer -> primary, onPrimaryContainer
  // -> onPrimary, errorContainer -> error, ...), so surfaces painted with
  // container colors (e.g. the Settings connection status card, which uses
  // primaryContainer@0.55 / tertiaryContainer@0.65 / errorContainer) render
  // as loud flat brand-color slabs with brand-foreground text instead of
  // subtle tints. Lerping ~72% toward the palette background yields — after
  // the card's own alpha — roughly the same tint intensity as user chat
  // bubbles (primary @ 16%), keeping the app cohesive. Container text is
  // p.foreground, matching the rest of the UI.
  final scheme = ColorScheme(
    brightness: effectiveBrightness,
    primary: p.primary,
    onPrimary: p.primaryForeground,
    // Tinted "healthy / live" surfaces (connection card, chips):
    primaryContainer: Color.lerp(p.primary, p.background, 0.72)!,
    onPrimaryContainer: p.foreground,
    secondary: p.ring,
    onSecondary: p.primaryForeground,
    // Used by chat system bubbles (secondaryContainer @ 0.45):
    secondaryContainer: p.secondary,
    onSecondaryContainer: p.secondaryForeground,
    // "Degraded" warning card state:
    tertiary: p.ring,
    onTertiary: p.primaryForeground,
    tertiaryContainer: Color.lerp(p.ring, p.background, 0.72)!,
    onTertiaryContainer: p.foreground,
    error: p.destructive,
    onError: p.destructiveForeground,
    // Reauth / error card states:
    errorContainer: Color.lerp(p.destructive, p.background, 0.62)!,
    onErrorContainer: p.foreground,
    surface: p.card,
    onSurface: p.foreground,
    outline: p.border,
    surfaceContainerHighest: p.muted,
    surfaceContainerHigh: p.secondary,
    surfaceContainer: p.card,
  );

  final base = ThemeData(
    useMaterial3: true,
    brightness: effectiveBrightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: p.background,
    appBarTheme: AppBarTheme(
      backgroundColor: p.background,
      foregroundColor: p.foreground,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: p.foreground,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
    ),
    cardTheme: CardThemeData(
      color: p.card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: p.border, width: 0.5),
      ),
    ),
    dividerTheme: DividerThemeData(color: p.border, thickness: 0.5),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: p.input.withValues(
        alpha: effectiveBrightness == Brightness.dark ? 0.35 : 0.15,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: p.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: p.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: p.ring, width: 1.2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      hintStyle: TextStyle(color: p.mutedForeground),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: p.primary,
      foregroundColor: p.primaryForeground,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: p.sidebarBackground ?? p.card,
      indicatorColor: p.primary.withValues(alpha: 0.18),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 12,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          color: selected ? p.primary : p.mutedForeground,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(color: selected ? p.primary : p.mutedForeground);
      }),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: p.mutedForeground,
      textColor: p.foreground,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: p.card,
      contentTextStyle: TextStyle(color: p.foreground),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: p.card,
      surfaceTintColor: Colors.transparent,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: p.card,
      surfaceTintColor: Colors.transparent,
    ),
  );

  return base.copyWith(
    textTheme: base.textTheme.apply(
      bodyColor: p.foreground,
      displayColor: p.foreground,
    ),
  );
}
