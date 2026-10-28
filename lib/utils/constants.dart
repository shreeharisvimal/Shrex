class AppConstants {
  // App Info
  static const String appName = 'Shrex';
  static const String appVersion = '1.0.0';
  
  // Session Settings
  static const List<int> defaultDurations = [5, 10, 15, 25, 30, 45, 60]; // minutes
  static const int defaultDuration = 10; // minutes
  
  // Streak Milestones
  static const List<int> streakMilestones = [3, 7, 14, 30, 50, 100];
  
  // Audio Settings
  static const double defaultVolume = 0.3;
  static const double minVolume = 0.0;
  static const double maxVolume = 1.0;
  
  // Database
  static const String databaseName = 'shrex.db';
  static const int databaseVersion = 1;
  
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String sessionsCollection = 'sessions';
  
  // Notification IDs
  static const int dailyReminderId = 1;
  static const int sessionCompleteId = 2;
  static const int streakMilestoneId = 3;
  
  // Platform Channel
  static const String platformChannel = 'shrex/platform';
  
  // SharedPreferences Keys
  static const String audioVolumeKey = 'audio_volume';
  static const String reminderTimeKey = 'reminder_time';
  static const String reminderHourKey = 'reminder_hour';
  static const String reminderMinuteKey = 'reminder_minute';
  static const String firebaseEnabledKey = 'firebase_enabled';
  static const String themeModeKey = 'theme_mode';
  static const String defaultDurationKey = 'default_duration';
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // UI Constants
  static const double borderRadius = 16.0;
  static const double smallBorderRadius = 8.0;
  static const double largeBorderRadius = 24.0;
  
  static const double padding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  
  // Focus Session Messages - MASSIVE COLLECTION
  static const List<String> motivationalMessages = [
    // POWER QUOTES
    'You\'ve got this! 💪', 'Stay focused! 🎯', 'You\'re doing great! 🌟', 'Keep going! 🚀',
    'Almost there! ⭐', 'You\'re unstoppable! 🔥', 'Focus mode activated! 🧠', 'Time to shine! ✨',
    'Deep focus! 🎪', 'Stay in the zone! 🌊', 'You\'re crushing it! 💎', 'Mind over matter! 🧘',
    'Stay committed! 🎭', 'You\'re a champion! 🏆', 'Keep pushing! 💨', 'Stay disciplined! ⚡',
    'You\'re on fire! 🔥', 'Stay determined! 🎨', 'You\'re unstoppable! 🚀', 'Stay motivated! 💫',
    'You\'re amazing! 🌈', 'Keep the momentum! 🎯', 'Stay strong! 💪', 'You\'re winning! 🏅',
    'Stay focused! 🎪', 'You\'re incredible! 🌟', 'Keep going strong! 💎', 'Stay in control! 🎭',
    'You\'re a legend! 👑', 'Stay persistent! ⚡', 'You\'re unstoppable! 🚀', 'Stay dedicated! 🎨',
    'You\'re phenomenal! 🌈', 'Keep the focus! 🎯', 'Stay committed! 💪', 'You\'re a warrior! ⚔️',
    'Stay disciplined! 🧘', 'You\'re brilliant! ✨', 'Keep pushing forward! 💨', 'Stay motivated! 🔥',
    'You\'re a champion! 🏆', 'Stay determined! 🎪', 'You\'re unstoppable! 🌟', 'Keep the energy! ⚡',
    'Stay focused! 🎯', 'You\'re incredible! 💎', 'Stay strong! 💪', 'You\'re amazing! 🌈',
    'Keep going! 🚀', 'Stay in the zone! 🌊', 'You\'re crushing it! 💎', 'Mind over matter! 🧘',
    
    // INSPIRATIONAL QUOTES
    'Success is your only option! 🎯', 'Every second counts! ⏰', 'You\'re building greatness! 🏗️',
    'Focus creates miracles! ✨', 'You\'re writing your destiny! 📝', 'Stay hungry for success! 🍽️',
    'You\'re the architect of your future! 🏛️', 'Excellence is your habit! 🎭', 'You\'re unstoppable! 🚀',
    'Greatness is in your DNA! 🧬', 'You\'re a force of nature! 🌪️', 'Stay relentless! 💪',
    'You\'re creating magic! 🪄', 'Focus is your superpower! 🦸', 'You\'re a success machine! 🤖',
    'Stay hungry, stay foolish! 🍎', 'You\'re the master of your fate! 👑', 'Excellence is not optional! ⭐',
    'You\'re building an empire! 🏰', 'Stay focused, stay winning! 🏆', 'You\'re a productivity beast! 🦁',
    'Success is your birthright! 👶', 'You\'re the CEO of your life! 💼', 'Stay committed to greatness! 🌟',
    'You\'re a focus warrior! ⚔️', 'Excellence is your standard! 📏', 'You\'re unstoppable! 🚀',
    'Stay hungry for more! 🍽️', 'You\'re a success magnet! 🧲', 'Focus is your weapon! 🗡️',
    'You\'re the hero of your story! 🦸', 'Stay relentless in pursuit! 🎯', 'You\'re a champion! 🏆',
    'Greatness is your destiny! 🌟', 'You\'re a focus machine! 🤖', 'Stay hungry for victory! 🍽️',
    'You\'re the master of focus! 🧘', 'Excellence is your legacy! 📜', 'You\'re unstoppable! 🚀',
    'Stay focused, stay successful! 💎', 'You\'re a productivity ninja! 🥷', 'Success is your habit! 🎭',
    'You\'re the king of focus! 👑', 'Stay hungry for excellence! 🍽️', 'You\'re a success warrior! ⚔️',
    'Focus is your secret weapon! 🗡️', 'You\'re a champion! 🏆', 'Stay relentless! 💪',
    'You\'re building your empire! 🏰', 'Excellence is your nature! 🌟', 'You\'re unstoppable! 🚀',
    
    // MOTIVATIONAL POWER PHRASES
    'You\'re a focus legend! 🏆', 'Stay hungry for greatness! 🍽️', 'You\'re a success beast! 🦁',
    'Focus is your superpower! 🦸', 'You\'re the master of time! ⏰', 'Stay relentless! 💪',
    'You\'re a productivity god! 👑', 'Excellence is your DNA! 🧬', 'You\'re unstoppable! 🚀',
    'Stay focused, stay winning! 🎯', 'You\'re a success machine! 🤖', 'Focus creates miracles! ✨',
    'You\'re the architect of success! 🏗️', 'Stay hungry for more! 🍽️', 'You\'re a champion! 🏆',
    'Greatness is your habit! 🎭', 'You\'re a focus warrior! ⚔️', 'Stay committed! 💪',
    'You\'re a productivity ninja! 🥷', 'Excellence is your standard! 📏', 'You\'re unstoppable! 🚀',
    'Stay focused, stay successful! 💎', 'You\'re a success magnet! 🧲', 'Focus is your weapon! 🗡️',
    'You\'re the hero of focus! 🦸', 'Stay relentless! 💪', 'You\'re a champion! 🏆',
    'Greatness is your destiny! 🌟', 'You\'re a focus machine! 🤖', 'Stay hungry for victory! 🍽️',
    'You\'re the master of excellence! 👑', 'Focus is your secret! 🗡️', 'You\'re unstoppable! 🚀',
    'Stay focused, stay great! 🌟', 'You\'re a productivity beast! 🦁', 'Success is your nature! 🎭',
    'You\'re the king of success! 👑', 'Stay hungry for more! 🍽️', 'You\'re a focus god! 🦸',
    'Excellence is your legacy! 📜', 'You\'re a success warrior! ⚔️', 'Focus is your power! ⚡',
    'You\'re a champion! 🏆', 'Stay relentless! 💪', 'You\'re unstoppable! 🚀',
    
    // ULTIMATE MOTIVATION
    'You\'re a focus legend! 🏆', 'Stay hungry for greatness! 🍽️', 'You\'re a success beast! 🦁',
    'Focus is your superpower! 🦸', 'You\'re the master of time! ⏰', 'Stay relentless! 💪',
    'You\'re a productivity god! 👑', 'Excellence is your DNA! 🧬', 'You\'re unstoppable! 🚀',
    'Stay focused, stay winning! 🎯', 'You\'re a success machine! 🤖', 'Focus creates miracles! ✨',
    'You\'re the architect of success! 🏗️', 'Stay hungry for more! 🍽️', 'You\'re a champion! 🏆',
    'Greatness is your habit! 🎭', 'You\'re a focus warrior! ⚔️', 'Stay committed! 💪',
    'You\'re a productivity ninja! 🥷', 'Excellence is your standard! 📏', 'You\'re unstoppable! 🚀',
    'Stay focused, stay successful! 💎', 'You\'re a success magnet! 🧲', 'Focus is your weapon! 🗡️',
    'You\'re the hero of focus! 🦸', 'Stay relentless! 💪', 'You\'re a champion! 🏆',
    'Greatness is your destiny! 🌟', 'You\'re a focus machine! 🤖', 'Stay hungry for victory! 🍽️',
    'You\'re the master of excellence! 👑', 'Focus is your secret! 🗡️', 'You\'re unstoppable! 🚀',
    'Stay focused, stay great! 🌟', 'You\'re a productivity beast! 🦁', 'Success is your nature! 🎭',
    'You\'re the king of success! 👑', 'Stay hungry for more! 🍽️', 'You\'re a focus god! 🦸',
    'Excellence is your legacy! 📜', 'You\'re a success warrior! ⚔️', 'Focus is your power! ⚡',
    'You\'re a champion! 🏆', 'Stay relentless! 💪', 'You\'re unstoppable! 🚀',
  ];
  
  static const List<String> completionMessages = [
    'Amazing work! 🎉',
    'You did it! 🏆',
    'Fantastic! 🌟',
    'Well done! 👏',
    'Incredible! 🚀',
    'Outstanding! ⭐',
    'Brilliant! 💎',
    'Perfect! 🎯',
  ];
}
