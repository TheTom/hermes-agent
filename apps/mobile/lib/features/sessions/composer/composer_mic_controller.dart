import 'dart:async';

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'package:hermes_mobile/core/services/feedback.dart';
import 'package:hermes_mobile/l10n/l10n.dart';

/// On-device STT session + listening pulse / wave controllers for the composer.
///
/// Animation controllers are owned here; the host [State] supplies a
/// [TickerProvider] and rebuilds via [onChanged] when listening toggles.
///
/// **Silence / end of session**
/// - [pauseFor]: max silence before the plugin stops (Android OS often ends
///   sooner, ~1–3s, with system beeps).
/// - [listenFor]: hard max session length.
/// - UI must clear on `notListening`/`done`, soft timeouts, **and** via a
///   short watchdog when the OS ends recording without a reliable callback
///   (same code path on iOS and Android).
class ComposerMicSession {
  ComposerMicSession({
    required TickerProvider vsync,
    required this.onChanged,
    required this.mounted,
    required this.context,
  }) {
    pulseCtrl = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 1100),
    );
    waveCtrl = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 900),
    );
  }

  static const listenFor = Duration(minutes: 2);
  static const pauseFor = Duration(seconds: 5);
  static const _watchdogInterval = Duration(milliseconds: 400);
  static const _listenForGrace = Duration(seconds: 2);

  final VoidCallback onChanged;
  final bool Function() mounted;
  final BuildContext Function() context;

  final _speech = stt.SpeechToText();
  var _speechReady = false;
  var _listening = false;
  String _dictationBase = '';

  late final AnimationController pulseCtrl;
  late final AnimationController waveCtrl;

  /// Smoothed, normalized (0..1) microphone level from the STT plugin.
  final ValueNotifier<double> soundLevel = ValueNotifier<double>(0);

  double? _lvlMin;
  double? _lvlMax;

  Timer? _watchdog;
  DateTime? _listenStartedAt;

  bool get listening => _listening;
  bool get isPluginListening => _speech.isListening;

  void dispose() {
    _stopWatchdog();
    pulseCtrl.dispose();
    waveCtrl.dispose();
    soundLevel.dispose();
    unawaited(_speech.stop());
  }

  void _stopWatchdog() {
    _watchdog?.cancel();
    _watchdog = null;
    _listenStartedAt = null;
  }

  /// Poll plugin state so UI cannot stay “listening” after the OS stops
  /// the recognizer (status/error callbacks are not always reliable).
  void _startWatchdog() {
    _stopWatchdog();
    _listenStartedAt = DateTime.now();
    _watchdog = Timer.periodic(_watchdogInterval, (_) {
      if (!mounted()) {
        _stopWatchdog();
        return;
      }
      if (!_listening) {
        _stopWatchdog();
        return;
      }
      // OS / plugin ended session without updating our flag.
      if (!_speech.isListening) {
        debugPrint('Speech watchdog: plugin not listening — clearing UI');
        _clearListeningUi(resyncPlugin: false);
        return;
      }
      final started = _listenStartedAt;
      if (started != null &&
          DateTime.now().difference(started) > listenFor + _listenForGrace) {
        debugPrint('Speech watchdog: listenFor exceeded — forcing stop');
        _clearListeningUi(resyncPlugin: true);
      }
    });
  }

  /// Drop listening chrome; optionally [stop] the plugin to resync.
  void _clearListeningUi({required bool resyncPlugin}) {
    _stopWatchdog();
    if (resyncPlugin) {
      unawaited(
        _speech.stop().catchError((Object _) {
          /* ignore */
        }),
      );
    }
    if (!_listening) return;
    setListening(false);
    if (mounted()) onChanged();
  }

  /// Single place that flips [_listening] and keeps [_pulseCtrl] in sync.
  ///
  /// The plugin toggles listening from several paths (toggle, onStatus,
  /// onError, post-listen check, catch, watchdog) — routing them all through
  /// here means the pulse can never keep running after dictation ended.
  void setListening(bool value) {
    _listening = value;
    if (value) {
      _startWatchdog();
    } else {
      _stopWatchdog();
    }
    final ctx = mounted() ? context() : null;
    final reduceMotion =
        ctx != null && (MediaQuery.maybeOf(ctx)?.disableAnimations ?? false);
    if (value) {
      if (reduceMotion) {
        pulseCtrl.value = 1.0;
        // Wave phase stays static; bars still react to soundLevel.
      } else {
        if (!pulseCtrl.isAnimating) {
          pulseCtrl.repeat(min: 0.35, max: 1.0, reverse: true);
        }
        if (!waveCtrl.isAnimating) waveCtrl.repeat();
      }
    } else {
      pulseCtrl.stop();
      waveCtrl.stop();
      waveCtrl.value = 0;
      if (reduceMotion) {
        pulseCtrl.value = 0.0;
      } else {
        pulseCtrl.animateTo(
          0,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
        );
      }
    }
  }

  void _onSoundLevel(double level) {
    _lvlMin = (_lvlMin == null || level < _lvlMin!) ? level : _lvlMin;
    _lvlMax = (_lvlMax == null || level > _lvlMax!) ? level : _lvlMax;
    final span = _lvlMax! - _lvlMin!;
    final norm = span < 1e-3
        ? 0.0
        : ((level - _lvlMin!) / span).clamp(0.0, 1.0);
    // Light smoothing so the bars breathe instead of jittering.
    soundLevel.value = soundLevel.value * 0.6 + norm * 0.4;
  }

  static bool _isSoftSpeechError(String errorMsg) {
    final msg = errorMsg.toLowerCase();
    return msg.contains('no_match') ||
        msg.contains('speech_timeout') ||
        msg.contains('error_no_match') ||
        msg.contains('error_speech_timeout');
  }

  Future<void> ensureReady() async {
    if (_speechReady && _speech.isAvailable) return;
    try {
      _speechReady = await _speech.initialize(
        onError: (e) {
          debugPrint('Speech error: ${e.errorMsg} permanent=${e.permanent}');
          if (!mounted()) return;
          // Soft ends (silence timeout / no match) and hard errors both clear
          // UI; soft ends also stop the plugin so isListening can't lag.
          final soft = _isSoftSpeechError(e.errorMsg);
          _clearListeningUi(resyncPlugin: true);
          if (!soft) {
            final ctx = context();
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(content: Text(ctx.l10n.dictationFailed(e.errorMsg))),
            );
          }
        },
        onStatus: (status) {
          debugPrint('Speech status: $status');
          if (!mounted()) return;
          // End statuses are definitive — do not re-open via isListening.
          // (Previously: status == listening || isListening could stick UI on.)
          final active = status == stt.SpeechToText.listeningStatus;
          if (active) {
            if (!_listening) {
              setListening(true);
              onChanged();
            }
          } else {
            // notListening / done / anything else → clear chrome.
            _clearListeningUi(resyncPlugin: false);
          }
        },
      );
    } catch (e) {
      debugPrint('Speech initialize threw: $e');
      _speechReady = false;
    }
    if (!_speechReady && mounted()) {
      final perm = await _speech.hasPermission;
      if (!mounted()) return;
      final ctx = context();
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: Text(
            perm
                ? L10n.current.speechUnavailable
                : L10n.current.micPermissionDenied,
          ),
        ),
      );
    }
  }

  Future<void> toggle({
    required bool enabled,
    required bool sending,
    required TextEditingController textController,
  }) async {
    if (!enabled || sending) return;

    if (_listening || _speech.isListening) {
      hermesHaptic(HapticIntent.crisp);
      try {
        await _speech.stop();
      } catch (_) {}
      if (mounted()) {
        setListening(false);
        onChanged();
      }
      return;
    }

    await ensureReady();
    if (!_speechReady || !_speech.isAvailable) return;

    hermesHaptic(HapticIntent.open);
    _dictationBase = textController.text;

    _lvlMin = null;
    _lvlMax = null;
    soundLevel.value = 0;

    // Optimistic UI — listen() is Future<void> and does NOT return success.
    if (mounted()) {
      setListening(true);
      onChanged();
    }

    try {
      String? localeId;
      try {
        final sys = await _speech.systemLocale();
        localeId = sys?.localeId;
      } catch (_) {}

      await _speech.listen(
        onResult: (result) {
          if (!mounted()) return;
          final spoken = result.recognizedWords;
          final base = _dictationBase.trimRight();
          final joined = base.isEmpty
              ? spoken
              : (spoken.isEmpty ? base : '$base $spoken');
          textController.value = TextEditingValue(
            text: joined,
            selection: TextSelection.collapsed(offset: joined.length),
          );
          // After a final chunk, fold into base so the next phrase appends.
          if (result.finalResult && spoken.trim().isNotEmpty) {
            _dictationBase = joined;
          }
        },
        onSoundLevelChange: _onSoundLevel,
        listenOptions: stt.SpeechListenOptions(
          partialResults: true,
          // Don't kill the session on a brief silence / no_match — we clear
          // UI ourselves via onError / onStatus / watchdog.
          cancelOnError: false,
          listenMode: stt.ListenMode.dictation,
          listenFor: listenFor,
          pauseFor: pauseFor,
          localeId: localeId,
          autoPunctuation: true,
          enableHapticFeedback: true,
        ),
      );

      // Plugin reports actual state after listen() returns.
      if (mounted()) {
        final live = _speech.isListening;
        if (live) {
          if (!_listening) {
            setListening(true);
            onChanged();
          }
        } else {
          setListening(false);
          onChanged();
          ScaffoldMessenger.of(context()).showSnackBar(
            SnackBar(content: Text(L10n.current.couldNotStartDictation)),
          );
        }
      }
    } catch (e) {
      debugPrint(L10n.current.dictationFailed('$e'));
      if (!mounted()) return;
      setListening(false);
      onChanged();
      ScaffoldMessenger.of(context()).showSnackBar(
        SnackBar(content: Text(L10n.current.dictationFailed('$e'))),
      );
    }
  }
}
