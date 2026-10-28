import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/timer_service.dart';

// Global timer service provider - shared across all screens
final timerServiceProvider = Provider<TimerService>((ref) {
  return TimerService();
});
