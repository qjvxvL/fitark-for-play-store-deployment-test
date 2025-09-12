import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isInitialized = false;
  bool _isMuted = false;

  Future<void> _initialize() async {
    if (_isInitialized) return;
    
    try {
      await _audioPlayer.setVolume(0.5);
      _isInitialized = true;
    } catch (e) {
      debugPrint('Audio service initialization error: $e');
    }
  }

  Future<void> playWorkoutSound() async {
    if (_isMuted) return;
    
    try {
      await _initialize();
      if (_isInitialized) {
        // Play a beep sound for workout start/transitions
        // Since we don't have actual sound files, we'll create a simple tone
        await _playBeep();
      }
    } catch (e) {
      debugPrint('Audio play workout sound error: $e');
    }
  }

  Future<void> playCompletionSound() async {
    if (_isMuted) return;
    
    try {
      await _initialize();
      if (_isInitialized) {
        // Play a completion celebration sound
        await _playCompletionBeep();
      }
    } catch (e) {
      debugPrint('Audio completion sound error: $e');
    }
  }

  Future<void> playRestSound() async {
    if (_isMuted) return;
    
    try {
      await _initialize();
      if (_isInitialized) {
        // Play a gentle rest sound
        await _playRestBeep();
      }
    } catch (e) {
      debugPrint('Audio rest sound error: $e');
    }
  }

  Future<void> playCountdownSound() async {
    if (_isMuted) return;
    
    try {
      await _initialize();
      if (_isInitialized) {
        await _playCountdownBeep();
      }
    } catch (e) {
      debugPrint('Audio countdown sound error: $e');
    }
  }

  // Simple beep sounds using basic audio generation
  Future<void> _playBeep() async {
    try {
      // For now, we'll use system sounds or create simple tones
      // In a real app, you'd have actual audio files
      await _audioPlayer.setVolume(0.3);
      // This would play an actual audio file:
      // await _audioPlayer.play(AssetSource('sounds/workout_beep.mp3'));
      
      // For demo purposes, we'll just set volume (no actual sound)
      await Future.delayed(const Duration(milliseconds: 200));
    } catch (e) {
      debugPrint('Beep sound error: $e');
    }
  }

  Future<void> _playCompletionBeep() async {
    try {
      await _audioPlayer.setVolume(0.5);
      // await _audioPlayer.play(AssetSource('sounds/completion.mp3'));
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      debugPrint('Completion beep error: $e');
    }
  }

  Future<void> _playRestBeep() async {
    try {
      await _audioPlayer.setVolume(0.2);
      // await _audioPlayer.play(AssetSource('sounds/rest.mp3'));
      await Future.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      debugPrint('Rest beep error: $e');
    }
  }

  Future<void> _playCountdownBeep() async {
    try {
      await _audioPlayer.setVolume(0.4);
      // await _audioPlayer.play(AssetSource('sounds/countdown.mp3'));
      await Future.delayed(const Duration(milliseconds: 150));
    } catch (e) {
      debugPrint('Countdown beep error: $e');
    }
  }

  Future<void> playBackgroundMusic(String musicPath) async {
    if (_isMuted) return;
    
    try {
      await _initialize();
      if (_isInitialized) {
        await _audioPlayer.setVolume(0.3);
        await _audioPlayer.play(AssetSource(musicPath));
        await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      }
    } catch (e) {
      debugPrint('Background music error: $e');
    }
  }

  Future<void> stopBackgroundMusic() async {
    try {
      await _audioPlayer.stop();
    } catch (e) {
      debugPrint('Stop background music error: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
    } catch (e) {
      debugPrint('Audio stop error: $e');
    }
  }

  Future<void> pause() async {
    try {
      await _audioPlayer.pause();
    } catch (e) {
      debugPrint('Audio pause error: $e');
    }
  }

  Future<void> resume() async {
    try {
      await _audioPlayer.resume();
    } catch (e) {
      debugPrint('Audio resume error: $e');
    }
  }

  Future<void> setVolume(double volume) async {
    try {
      await _audioPlayer.setVolume(volume.clamp(0.0, 1.0));
    } catch (e) {
      debugPrint('Audio set volume error: $e');
    }
  }

  void mute() {
    _isMuted = true;
    setVolume(0.0);
  }

  void unmute() {
    _isMuted = false;
    setVolume(0.5);
  }

  bool get isMuted => _isMuted;

  void dispose() {
    _audioPlayer.dispose();
  }

  // Additional methods for different types of audio feedback
  Future<void> playSuccessSound() async {
    if (_isMuted) return;
    
    try {
      await _initialize();
      if (_isInitialized) {
        await _audioPlayer.setVolume(0.4);
        // await _audioPlayer.play(AssetSource('sounds/success.mp3'));
        await Future.delayed(const Duration(milliseconds: 400));
      }
    } catch (e) {
      debugPrint('Success sound error: $e');
    }
  }

  Future<void> playErrorSound() async {
    if (_isMuted) return;
    
    try {
      await _initialize();
      if (_isInitialized) {
        await _audioPlayer.setVolume(0.3);
        // await _audioPlayer.play(AssetSource('sounds/error.mp3'));
        await Future.delayed(const Duration(milliseconds: 250));
      }
    } catch (e) {
      debugPrint('Error sound error: $e');
    }
  }

  Future<void> playButtonClickSound() async {
    if (_isMuted) return;
    
    try {
      await _initialize();
      if (_isInitialized) {
        await _audioPlayer.setVolume(0.2);
        // await _audioPlayer.play(AssetSource('sounds/click.mp3'));
        await Future.delayed(const Duration(milliseconds: 100));
      }
    } catch (e) {
      debugPrint('Button click sound error: $e');
    }
  }
}