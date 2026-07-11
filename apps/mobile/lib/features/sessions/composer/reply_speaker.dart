import 'dart:async';

import 'package:flutter_tts/flutter_tts.dart';

/// App-wide TTS helper for "read replies aloud".
///
/// Owned by the chat screen (not the composer chrome); the composer only
/// exposes the volume toggle that enables this helper.
class ReplySpeaker {
  ReplySpeaker() {
    _tts = FlutterTts();
    unawaited(_configure());
  }

  late final FlutterTts _tts;
  var _enabled = false;
  var _speaking = false;

  bool get enabled => _enabled;
  bool get speaking => _speaking;

  Future<void> _configure() async {
    await _tts.setSpeechRate(0.48);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    await _tts.awaitSpeakCompletion(true);
  }

  void setEnabled(bool value) {
    _enabled = value;
    if (!value) {
      unawaited(stop());
    }
  }

  Future<void> speak(String text) async {
    final cleaned = _stripForSpeech(text);
    if (!_enabled || cleaned.isEmpty) return;
    await stop();
    _speaking = true;
    try {
      await _tts.speak(cleaned);
    } finally {
      _speaking = false;
    }
  }

  Future<void> speakOnce(String text) async {
    final cleaned = _stripForSpeech(text);
    if (cleaned.isEmpty) return;
    await stop();
    _speaking = true;
    try {
      await _tts.speak(cleaned);
    } finally {
      _speaking = false;
    }
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
    _speaking = false;
  }

  Future<void> dispose() async {
    await stop();
  }

  static String _stripForSpeech(String raw) {
    // Drop fenced code blocks and light markdown noise for cleaner TTS.
    var s = raw.replaceAll(
      RegExp(r'```[\s\S]*?```', multiLine: true),
      ' code block ',
    );
    s = s.replaceAll(RegExp(r'`[^`]+`'), ' ');
    s = s.replaceAll(RegExp(r'[*_#>\[\]\(\)!]'), ' ');
    s = s.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (s.length > 2500) s = '${s.substring(0, 2500)}…';
    return s;
  }
}
