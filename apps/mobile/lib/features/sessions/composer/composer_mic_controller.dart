import 'dart:async';

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'package:hermes_mobile/core/services/feedback.dart';
import 'package:hermes_mobile/l10n/l10n.dart';

/// On-device STT session + listening pulse / wave controllers for the composer.
///
/// Animation controllers are owned here; the host [State] supplies a
/// [TickerProvider] and rebuilds via [onChanged] when listening toggles.
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

  bool get listening => _listening;
  bool get isPluginListening => _speech.isListening;

  void dispose() {
    pulseCtrl.dispose();
    waveCtrl.dispose();
    soundLevel.dispose();
    unawaited(_speech.stop());
  }

  /// Single place that flips [_listening] and keeps [pulseCtrl] in sync.
  void setListening(bool value) {
    _listening = value;
    final ctx = mounted() ? context() : null;
    final reduceMotion =
        ctx != null && (MediaQuery.maybeOf(ctx)?.disableAnimations ?? false);
    if (value) {
      if (reduceMotion) {
        pulseCtrl.value = 1.0;
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
    soundLevel.value = soundLevel.value * 0.6 + norm * 0.4;
  }

  Future<void> ensureReady() async {
    if (_speechReady && _speech.isAvailable) return;
    try {
      _speechReady = await _speech.initialize(
        onError: (e) {
          debugPrint('Speech error: ${e.errorMsg} permanent=${e.permanent}');
          if (!mounted()) return;
          setListening(false);
          onChanged();
          final msg = e.errorMsg.toLowerCase();
          final soft =
              msg.contains('no_match') ||
              msg.contains('speech_timeout') ||
              msg.contains('error_no_match') ||
              msg.contains('error_speech_timeout');
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
          final active = status == 'listening' || _speech.isListening;
          if (_listening != active) {
            setListening(active);
            onChanged();
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
          if (result.finalResult && spoken.trim().isNotEmpty) {
            _dictationBase = joined;
          }
        },
        onSoundLevelChange: _onSoundLevel,
        listenOptions: stt.SpeechListenOptions(
          partialResults: true,
          cancelOnError: false,
          listenMode: stt.ListenMode.dictation,
          listenFor: const Duration(minutes: 2),
          pauseFor: const Duration(seconds: 5),
          localeId: localeId,
          autoPunctuation: true,
          enableHapticFeedback: true,
        ),
      );

      if (mounted()) {
        final live = _speech.isListening;
        setListening(live);
        onChanged();
        if (!live) {
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
