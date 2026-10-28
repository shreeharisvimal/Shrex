import 'dart:async';
import 'package:flutter/foundation.dart';
import 'platform_service.dart';
import 'audio_service.dart';
import 'notification_service.dart';
import 'db_service.dart';
import 'firebase_service.dart';
import '../models/session_model.dart';
import '../utils/constants.dart';

class TimerService extends ChangeNotifier {
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _isRunning = false;
  bool _isLocked = false;
  DateTime? _sessionStartTime;
  int _sessionDuration = 600; // Default 10 minutes

  // Getters
  int get remainingSeconds => _remainingSeconds;
  bool get isRunning => _isRunning;
  bool get isLocked => _isLocked;
  DateTime? get sessionStartTime => _sessionStartTime;
  int get sessionDuration => _sessionDuration;

  // Computed properties
  Duration get remainingDuration => Duration(seconds: _remainingSeconds);
  double get progress {
    if (_sessionDuration <= 0) return 0.0;
    final calculatedProgress = (_sessionDuration - _remainingSeconds) / _sessionDuration;
    // Ensure progress is between 0.0 and 1.0
    return calculatedProgress.clamp(0.0, 1.0);
  }
  bool get isComplete => _remainingSeconds <= 0 && _isRunning;
  
  String get formattedTime {
    final hours = _remainingSeconds ~/ 3600;
    final minutes = (_remainingSeconds % 3600) ~/ 60;
    final seconds = _remainingSeconds % 60;
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  /// Start a focus session
  Future<bool> startSession(int durationSeconds) async {
    if (_isRunning) return false;

    try {
      _sessionDuration = durationSeconds;
      _remainingSeconds = durationSeconds;
      _sessionStartTime = DateTime.now();
      _isRunning = true;
      _isLocked = false;

      // Start audio
      await AudioService.startAmbientAudio();

      // Actually lock the device using platform service
      debugPrint('Starting focus session - attempting to lock device');
      final lockSuccess = await PlatformService.lockDevice(durationSeconds);
      if (lockSuccess) {
        _isLocked = true;
        debugPrint('Device locked successfully');
      } else {
        debugPrint('Failed to lock device, but continuing with session');
        _isLocked = true; // Still trap user in timer page
      }

      // Start timer
      _timer = Timer.periodic(const Duration(seconds: 1), _onTimerTick);
      debugPrint('Timer started with $_remainingSeconds seconds remaining');

      notifyListeners();
      debugPrint('Focus session started for $durationSeconds seconds');
      return true;
    } catch (e) {
      debugPrint('Error starting session: $e');
      await stopSession(success: false);
      return false;
    }
  }

  /// Stop the current session
  Future<void> stopSession({bool success = true}) async {
    if (!_isRunning) return;

    try {
      _timer?.cancel();
      _timer = null;
      _isRunning = false;

      // Stop audio
      await AudioService.stopAmbientAudio();

      // Actually unlock the device if it was locked
      if (_isLocked) {
        debugPrint('Focus session ended - unlocking device');
        await PlatformService.unlockDevice();
        _isLocked = false;
      }

      // Save session to database
      if (_sessionStartTime != null) {
        await _saveSession(success);
      }

      // Play victory sound if successful
      if (success && _remainingSeconds <= 0) {
        await AudioService.playVictorySound();
      }

      // Show completion notification
      if (success) {
        final currentStreak = await _getCurrentStreak();
        await NotificationService.showSessionCompletionNotification(
          durationMinutes: (_sessionDuration - _remainingSeconds) ~/ 60,
          currentStreak: currentStreak,
          isSuccess: true,
        );
      }

      // Reset state
      _remainingSeconds = 0;
      _sessionStartTime = null;

      notifyListeners();
      debugPrint('Focus session stopped (success: $success)');
    } catch (e) {
      debugPrint('Error stopping session: $e');
    }
  }

  /// Pause the session (emergency unlock)
  Future<void> pauseSession() async {
    if (!_isRunning) return;

    try {
      _timer?.cancel();
      _timer = null;
      _isRunning = false;

      // Stop audio
      await AudioService.stopAmbientAudio();

      // Unlock device
      if (_isLocked) {
        debugPrint('Pausing session - unlocking device');
        await PlatformService.unlockDevice();
        _isLocked = false;
      }

      notifyListeners();
      debugPrint('Session paused');
    } catch (e) {
      debugPrint('Error pausing session: $e');
    }
  }

  /// Resume the session
  Future<void> resumeSession() async {
    if (_remainingSeconds <= 0) return;

    _isRunning = true;

    // Start audio
    await AudioService.startAmbientAudio();

    // Lock device again
    final lockSuccess = await PlatformService.lockDevice(_remainingSeconds);
    if (lockSuccess) {
      _isLocked = true;
    }

    // Resume timer
    _timer = Timer.periodic(const Duration(seconds: 1), _onTimerTick);

    notifyListeners();
    debugPrint('Session resumed');
  }

  /// Timer tick handler
  void _onTimerTick(Timer timer) {
    debugPrint('Timer tick: $_remainingSeconds seconds remaining');
    if (_remainingSeconds > 0) {
      _remainingSeconds--;
      debugPrint('Updated timer: $_remainingSeconds seconds remaining, progress: $progress');
      notifyListeners();
    } else {
      // Session completed
      debugPrint('Session completed!');
      stopSession(success: true);
    }
  }

  /// Save session to database
  Future<void> _saveSession(bool success) async {
    if (_sessionStartTime == null) return;

    try {
      final session = SessionModel(
        startTime: _sessionStartTime!,
        endTime: DateTime.now(),
        durationSeconds: _sessionDuration - _remainingSeconds,
        success: success,
        streakAtTime: await _getCurrentStreak(),
        createdAt: DateTime.now(),
      );

      await DbService.insertSession(session);

      // Update user stats
      if (success) {
        await _updateUserStats();
        await _checkStreakMilestone();
      }

      debugPrint('Session saved to database');
    } catch (e) {
      debugPrint('Error saving session: $e');
    }
  }

  /// Update user statistics
  Future<void> _updateUserStats() async {
    try {
      final totalSessions = await DbService.getTotalSessions();
      final totalMinutes = await DbService.getTotalMinutes();
      
      // Get current stats
      final stats = await DbService.getUserStats();
      final currentStreak = stats['current_streak'] ?? 0;
      final bestStreak = stats['best_streak'] ?? 0;

      // Update stats
      await DbService.updateUserStats({
        'total_sessions': totalSessions,
        'total_minutes': totalMinutes,
        'current_streak': currentStreak,
        'best_streak': bestStreak,
        'last_session_date': DateTime.now().toIso8601String(),
      });

      // Sync to Firebase if enabled
      await FirebaseService.updateUserStats(
        totalSessions: totalSessions,
        totalMinutes: totalMinutes,
        currentStreak: currentStreak,
        bestStreak: bestStreak,
      );

      debugPrint('User stats updated');
    } catch (e) {
      debugPrint('Error updating user stats: $e');
    }
  }

  /// Get current streak
  Future<int> _getCurrentStreak() async {
    try {
      final stats = await DbService.getUserStats();
      return stats['current_streak'] ?? 0;
    } catch (e) {
      debugPrint('Error getting current streak: $e');
      return 0;
    }
  }

  /// Check for streak milestones
  Future<void> _checkStreakMilestone() async {
    try {
      final stats = await DbService.getUserStats();
      final currentStreak = stats['current_streak'] ?? 0;
      
      // Check if current streak matches any milestone
      if (AppConstants.streakMilestones.contains(currentStreak)) {
        await NotificationService.showStreakMilestoneNotification(currentStreak);
        debugPrint('Streak milestone notification shown for $currentStreak days');
      }
    } catch (e) {
      debugPrint('Error checking streak milestone: $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
