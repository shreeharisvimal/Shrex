import 'package:flutter/foundation.dart';
import 'db_service.dart';
// import 'notification_service.dart';
import 'audio_service.dart';
import 'firebase_service.dart';

class AppServices {
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    try {
      // Initialize database
      await DbService.init();
      
      // Initialize audio service
      await AudioService.init();
      
      // Initialize Firebase service (optional)
      await FirebaseService.init();
      
      _initialized = true;
      debugPrint('AppServices initialized successfully');
    } catch (e) {
      debugPrint('Error initializing AppServices: $e');
      rethrow;
    }
  }

  static bool get isInitialized => _initialized;
}
