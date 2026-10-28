import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class NotificationService {
  static bool _isInitialized = false;

  /// Initialize the notification service
  static Future<void> init() async {
    if (_isInitialized) return;

    try {
      // Simple initialization without flutter_local_notifications
      debugPrint('NotificationService initialized (simplified version)');
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing NotificationService: $e');
    }
  }

  /// Schedule daily reminder notification
  static Future<void> scheduleDailyReminder(TimeOfDay time) async {
    try {
      // Save reminder time to preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.reminderTimeKey, '${time.hour}:${time.minute}');

      debugPrint('Daily reminder scheduled for ${time.hour}:${time.minute} (simplified)');
    } catch (e) {
      debugPrint('Error scheduling daily reminder: $e');
    }
  }

  /// Cancel daily reminder notification
  static Future<void> cancelDailyReminder() async {
    try {
      // Remove reminder time from preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.reminderTimeKey);
      
      debugPrint('Daily reminder cancelled (simplified)');
    } catch (e) {
      debugPrint('Error cancelling daily reminder: $e');
    }
  }

  /// Show session completion notification
  static Future<void> showSessionCompletionNotification({
    required int durationMinutes,
    required int currentStreak,
    required bool isSuccess,
  }) async {
    try {
      final title = isSuccess ? 'Session Complete! 🎉' : 'Session Interrupted';
      final body = isSuccess 
          ? 'Great job! You completed a $durationMinutes-minute focus session. Current streak: $currentStreak days!'
          : 'Your focus session was interrupted. Keep trying!';

      debugPrint('Session completion notification: $title - $body');
    } catch (e) {
      debugPrint('Error showing session completion notification: $e');
    }
  }

  /// Show streak milestone notification
  static Future<void> showStreakMilestoneNotification(int streak) async {
    try {
      String title;
      String body;

      if (streak == 3) {
        title = 'Bronze Streak! 🥉';
        body = 'Amazing! You\'ve maintained a 3-day focus streak. Keep it up!';
      } else if (streak == 7) {
        title = 'Silver Streak! 🥈';
        body = 'Incredible! A full week of focus sessions. You\'re on fire!';
      } else if (streak == 14) {
        title = 'Gold Streak! 🥇';
        body = 'Outstanding! Two weeks of consistent focus. You\'re unstoppable!';
      } else if (streak == 30) {
        title = 'Platinum Streak! 💎';
        body = 'Legendary! A full month of focus sessions. You\'re a focus master!';
      } else if (streak == 50) {
        title = 'Diamond Streak! 💠';
        body = 'Phenomenal! 50 days of focus. You\'re in the elite category!';
      } else if (streak == 100) {
        title = 'Legendary Streak! 👑';
        body = 'Unbelievable! 100 days of focus. You\'re a true legend!';
      } else {
        title = 'Streak Milestone! 🔥';
        body = 'Congratulations on your $streak-day focus streak!';
      }

      debugPrint('Streak milestone notification: $title - $body');
    } catch (e) {
      debugPrint('Error showing streak milestone notification: $e');
    }
  }

  /// Show motivational notification
  static Future<void> showMotivationalNotification() async {
    try {
      final motivationalQuotes = [
        'The way to get started is to quit talking and begin doing. - Walt Disney',
        'Focus is not about saying yes to the thing you\'ve got to focus on. It\'s about saying no to the hundred other good ideas. - Steve Jobs',
        'Success is the sum of small efforts repeated day in and day out. - Robert Collier',
        'The future belongs to those who believe in the beauty of their dreams. - Eleanor Roosevelt',
        'Don\'t watch the clock; do what it does. Keep going. - Sam Levenson',
      ];

      final randomQuote = motivationalQuotes[DateTime.now().day % motivationalQuotes.length];
      debugPrint('Motivational notification: Daily Motivation 💪 - $randomQuote');
    } catch (e) {
      debugPrint('Error showing motivational notification: $e');
    }
  }

  /// Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    try {
      debugPrint('All notifications cancelled (simplified)');
    } catch (e) {
      debugPrint('Error cancelling all notifications: $e');
    }
  }

  /// Check if notifications are enabled
  static Future<bool> areNotificationsEnabled() async {
    try {
      // Always return true for simplified version
      return true;
    } catch (e) {
      debugPrint('Error checking notification status: $e');
      return false;
    }
  }

  /// Open notification settings
  static Future<void> openNotificationSettings() async {
    try {
      debugPrint('Opening notification settings (simplified)');
    } catch (e) {
      debugPrint('Error opening notification settings: $e');
    }
  }
}
