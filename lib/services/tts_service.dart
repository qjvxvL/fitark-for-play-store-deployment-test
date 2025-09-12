import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/foundation.dart';

class TTSService {
  static final TTSService _instance = TTSService._internal();
  factory TTSService() => _instance;
  TTSService._internal();

  late FlutterTts _flutterTts;
  bool _isInitialized = false;

  Future<void> _initialize() async {
    if (_isInitialized) return;

    _flutterTts = FlutterTts();
    
    try {
      await _flutterTts.setLanguage("en-US");
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(0.8);
      await _flutterTts.setPitch(1.0);
      
      _isInitialized = true;
    } catch (e) {
      debugPrint('TTS initialization error: $e');
    }
  }

  Future<void> speak(String text) async {
    try {
      await _initialize();
      if (_isInitialized) {
        await _flutterTts.speak(text);
      }
    } catch (e) {
      debugPrint('TTS speak error: $e');
    }
  }

  Future<void> stop() async {
    try {
      if (_isInitialized) {
        await _flutterTts.stop();
      }
    } catch (e) {
      debugPrint('TTS stop error: $e');
    }
  }

  Future<void> pause() async {
    try {
      if (_isInitialized) {
        await _flutterTts.pause();
      }
    } catch (e) {
      debugPrint('TTS pause error: $e');
    }
  }

  void dispose() {
    stop();
  }
}
