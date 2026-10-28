import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioService {
  static AudioPlayer? _ambientPlayer;
  static AudioPlayer? _victoryPlayer;
  static bool _isInitialized = false;
  static double _volume = 0.3;

  static Future<void> init() async {
    if (_isInitialized) return;

    try {
      _ambientPlayer = AudioPlayer();
      _victoryPlayer = AudioPlayer();
      
      // Load audio files
      await _ambientPlayer!.setAsset('assets/audio/ambient.mp3');
      await _victoryPlayer!.setAsset('assets/audio/victory.mp3');
      
      // Set loop mode for ambient audio
      await _ambientPlayer!.setLoopMode(LoopMode.one);
      
      // Load saved volume
      final prefs = await SharedPreferences.getInstance();
      _volume = prefs.getDouble('audio_volume') ?? 0.3;
      await _ambientPlayer!.setVolume(_volume);
      await _victoryPlayer!.setVolume(_volume);
      
      _isInitialized = true;
      debugPrint('AudioService initialized successfully');
    } catch (e) {
      debugPrint('Error initializing AudioService: $e');
      // Continue without audio if files are missing
    }
  }

  /// Start playing ambient background audio
  static Future<void> startAmbientAudio() async {
    if (!_isInitialized || _ambientPlayer == null) return;

    try {
      await _ambientPlayer!.play();
      debugPrint('Started ambient audio');
    } catch (e) {
      debugPrint('Error starting ambient audio: $e');
    }
  }

  /// Stop ambient background audio
  static Future<void> stopAmbientAudio() async {
    if (!_isInitialized || _ambientPlayer == null) return;

    try {
      await _ambientPlayer!.stop();
      debugPrint('Stopped ambient audio');
    } catch (e) {
      debugPrint('Error stopping ambient audio: $e');
    }
  }

  /// Play victory sound
  static Future<void> playVictorySound() async {
    if (!_isInitialized || _victoryPlayer == null) return;

    try {
      await _victoryPlayer!.seek(Duration.zero);
      await _victoryPlayer!.play();
      debugPrint('Played victory sound');
    } catch (e) {
      debugPrint('Error playing victory sound: $e');
    }
  }

  /// Set audio volume
  static Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    
    if (_ambientPlayer != null) {
      await _ambientPlayer!.setVolume(_volume);
    }
    if (_victoryPlayer != null) {
      await _victoryPlayer!.setVolume(_volume);
    }

    // Save volume preference
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('audio_volume', _volume);
  }

  /// Get current volume
  static double get volume => _volume;

  /// Check if ambient audio is playing
  static bool get isPlaying => _ambientPlayer?.playing ?? false;

  /// Dispose audio players
  static Future<void> dispose() async {
    await _ambientPlayer?.dispose();
    await _victoryPlayer?.dispose();
    _ambientPlayer = null;
    _victoryPlayer = null;
    _isInitialized = false;
  }
}
