import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import '../services/firebase_service.dart';
import '../services/notification_service.dart';
import '../services/audio_service.dart';
import '../services/db_service.dart';
import '../services/platform_service.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';
import '../widgets/app_logo.dart';
import '../widgets/animated_components.dart';

class SettingsScreen extends HookConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioVolume = useState(0.3);
    final reminderTime = useState<TimeOfDay?>(null);
    final firebaseEnabled = useState(false);
    final themeMode = useState(ThemeMode.system);
    final defaultDuration = useState(AppConstants.defaultDuration);
    final isLoading = useState(true);
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 2000),
    );

    useEffect(() {
      Future<void> _loadSettings() async {
        try {
          final prefs = await SharedPreferences.getInstance();
          
          audioVolume.value = prefs.getDouble(AppConstants.audioVolumeKey) ?? 0.3;
          firebaseEnabled.value = prefs.getBool(AppConstants.firebaseEnabledKey) ?? false;
          defaultDuration.value = prefs.getInt(AppConstants.defaultDurationKey) ?? AppConstants.defaultDuration;
          
          reminderTime.value = null;
          isLoading.value = false;
          animationController.forward();
        } catch (e) {
          debugPrint('Error loading settings: $e');
          isLoading.value = false;
        }
      }
      _loadSettings();
      return null;
    }, []);

    Future<void> _saveAudioVolume(double volume) async {
      audioVolume.value = volume;
      await AudioService.setVolume(volume);
    }

    Future<void> _saveReminderTime(TimeOfDay? time) async {
      reminderTime.value = time;
      if (time != null) {
        await NotificationService.scheduleDailyReminder(time);
      } else {
        await NotificationService.cancelDailyReminder();
      }
    }

    Future<void> _toggleFirebase(bool enabled) async {
      firebaseEnabled.value = enabled;
      await FirebaseService.setFirebaseEnabled(enabled);
      
      if (enabled && !FirebaseService.isSignedIn) {
        final user = await FirebaseService.signInWithGoogle();
        if (user == null) {
          firebaseEnabled.value = false;
          await FirebaseService.setFirebaseEnabled(false);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Failed to sign in with Google'),
                backgroundColor: ShrexTheme.errorColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
          }
        }
      }
    }

    Future<void> _saveDefaultDuration(int duration) async {
      defaultDuration.value = duration;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(AppConstants.defaultDurationKey, duration);
    }

    Future<void> _setEmergencyPassword() async {
      final passwordController = TextEditingController();
      final confirmController = TextEditingController();
      
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: ShrexTheme.deepSpaceGray,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: GlowText(
            'Set Emergency Password',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            glowColor: ShrexTheme.cyberBlue,
            isGlowing: true,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.1),
                      Colors.white.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    hintText: 'Enter emergency password',
                    labelStyle: TextStyle(color: ShrexTheme.cyberBlue),
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: ShrexTheme.cyberBlue.withOpacity(0.3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: ShrexTheme.cyberBlue.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: ShrexTheme.cyberBlue),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.1),
                      Colors.white.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: confirmController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    hintText: 'Confirm emergency password',
                    labelStyle: TextStyle(color: ShrexTheme.cyberBlue),
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: ShrexTheme.cyberBlue.withOpacity(0.3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: ShrexTheme.cyberBlue.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: ShrexTheme.cyberBlue),
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white.withOpacity(0.7),
              ),
              child: const Text('Cancel'),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: ShrexTheme.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextButton(
                onPressed: () {
                  if (passwordController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Password cannot be empty'),
                        backgroundColor: ShrexTheme.errorColor,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                    return;
                  }
                  if (passwordController.text != confirmController.text) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Passwords do not match'),
                        backgroundColor: ShrexTheme.errorColor,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                    return;
                  }
                  Navigator.pop(context, true);
                },
                child: const Text(
                  'Set Password',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      );

      if (result == true) {
        try {
          final success = await PlatformService.setEmergencyPassword(passwordController.text);
          if (success && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Emergency password set successfully'),
                backgroundColor: ShrexTheme.successColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
          } else if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Failed to set emergency password'),
                backgroundColor: ShrexTheme.errorColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
          }
        } catch (e) {
          debugPrint('Error setting emergency password: $e');
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Error setting emergency password'),
                backgroundColor: ShrexTheme.errorColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
          }
        }
      }
    }

    Future<void> _exportData() async {
      try {
        final sessions = await DbService.getAllSessions();
        final stats = await DbService.getUserStats();
        
        final exportData = {
          'app': 'Shrex Focus',
          'version': AppConstants.appVersion,
          'exportDate': DateTime.now().toIso8601String(),
          'stats': stats,
          'sessions': sessions.map((s) => s.toMap()).toList(),
        };
        
        final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);
        final tempDir = await getTemporaryDirectory();
        final fileName = 'shrex_export_${DateTime.now().millisecondsSinceEpoch}.json';
        final file = File('${tempDir.path}/$fileName');
        
        await file.writeAsString(jsonString);
        
        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Shrex Focus Data Export',
          subject: 'My Focus Session Data',
        );
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Data exported successfully'),
              backgroundColor: ShrexTheme.successColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      } catch (e) {
        debugPrint('Error exporting data: $e');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Failed to export data'),
              backgroundColor: ShrexTheme.errorColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    }

    Future<void> _clearData() async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: ShrexTheme.deepSpaceGray,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: GlowText(
            'Clear All Data',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: ShrexTheme.errorColor,
              fontWeight: FontWeight.bold,
            ),
            glowColor: ShrexTheme.errorColor,
            isGlowing: true,
          ),
          content: Text(
            'This will permanently delete all your sessions and statistics. This action cannot be undone.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white.withOpacity(0.7),
              ),
              child: const Text('Cancel'),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [ShrexTheme.errorColor, ShrexTheme.errorColor.withOpacity(0.7)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Clear Data',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        try {
          await DbService.clearAllData();
          
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('All data cleared'),
                backgroundColor: ShrexTheme.successColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
          }
        } catch (e) {
          debugPrint('Error clearing data: $e');
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Failed to clear data'),
                backgroundColor: ShrexTheme.errorColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
          }
        }
      }
    }

    if (isLoading.value) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: ShrexTheme.backgroundGradient,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AppLogoIcon(size: 80, isGlowing: true),
                const SizedBox(height: 24),
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(ShrexTheme.cyberBlue),
                  strokeWidth: 3,
                ),
                const SizedBox(height: 16),
                GlowText(
                  'Loading Settings...',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  glowColor: ShrexTheme.cyberBlue,
                  isGlowing: true,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: ShrexTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // REVOLUTIONARY HEADER
              Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.2),
                                  Colors.white.withOpacity(0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1.5,
                              ),
                            ),
                            child: Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        const Spacer(),
                        const AppLogoIcon(size: 50, isGlowing: true),
                        const Spacer(),
                        Container(
                          width: 50,
                          height: 50,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    GlowText(
                      'Settings',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                      glowColor: ShrexTheme.cyberBlue,
                      isGlowing: true,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Customize your focus experience',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              
              // STUNNING SCROLLABLE CONTENT
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      // SESSION SETTINGS - REVOLUTIONARY DESIGN
                      _buildRevolutionarySection(
                        context,
                        'Session Settings',
                        Icons.timer_outlined,
                        [
                          _buildDurationSelector(context, defaultDuration.value, _saveDefaultDuration),
                          const SizedBox(height: 24),
                          _buildAudioVolumeSlider(context, audioVolume.value, _saveAudioVolume),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // SECURITY SETTINGS - ULTRA MODERN
                      _buildRevolutionarySection(
                        context,
                        'Security Settings',
                        Icons.security_outlined,
                        [
                          _buildRevolutionaryActionButton(
                            context,
                            'Set Emergency Password',
                            'Set password for emergency unlock during sessions',
                            Icons.lock_outline,
                            _setEmergencyPassword,
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // NOTIFICATIONS - STUNNING DESIGN
                      _buildRevolutionarySection(
                        context,
                        'Notifications',
                        Icons.notifications_outlined,
                        [
                          _buildReminderTimeSelector(context, reminderTime.value, _saveReminderTime),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // CLOUD SYNC - REVOLUTIONARY
                      _buildRevolutionarySection(
                        context,
                        'Cloud Sync',
                        Icons.cloud_sync_outlined,
                        [
                          _buildFirebaseToggle(context, firebaseEnabled.value, _toggleFirebase),
                          if (firebaseEnabled.value && FirebaseService.currentUser != null)
                            _buildUserInfo(context, FirebaseService.currentUser!),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // DATA MANAGEMENT - ULTRA STUNNING
                      _buildRevolutionarySection(
                        context,
                        'Data Management',
                        Icons.storage_outlined,
                        [
                          _buildRevolutionaryActionButton(
                            context,
                            'Export Data',
                            'Export your sessions and statistics',
                            Icons.download_outlined,
                            _exportData,
                          ),
                          const SizedBox(height: 16),
                          _buildRevolutionaryActionButton(
                            context,
                            'Clear All Data',
                            'Permanently delete all data',
                            Icons.delete_forever_outlined,
                            _clearData,
                            isDestructive: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // APP INFO - FINAL TOUCH
                      _buildRevolutionarySection(
                        context,
                        'App Information',
                        Icons.info_outline,
                        [
                          _buildInfoRow(context, 'Version', AppConstants.appVersion),
                          _buildInfoRow(context, 'Build', '1.0.0+1'),
                        ],
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRevolutionarySection(BuildContext context, String title, IconData icon, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.08),
            Colors.white.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: ShrexTheme.cyberBlue.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: ShrexTheme.cyberBlue.withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: ShrexTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: ShrexTheme.cyberBlue.withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: GlowText(
                  title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                  glowColor: ShrexTheme.cyberBlue,
                  isGlowing: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDurationSelector(BuildContext context, int currentDuration, Function(int) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlowText(
          'Default Session Duration',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
          glowColor: ShrexTheme.cyberBlue,
          isGlowing: true,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: AppConstants.defaultDurations.map((duration) {
            final isSelected = duration == currentDuration;
            return GestureDetector(
              onTap: () => onChanged(duration),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOutCubic,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  gradient: isSelected 
                      ? ShrexTheme.primaryGradient
                      : LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.2),
                            Colors.white.withOpacity(0.1),
                          ],
                        ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected 
                        ? ShrexTheme.cyberBlue.withOpacity(0.8)
                        : Colors.white.withOpacity(0.3),
                    width: isSelected ? 2.5 : 1.5,
                  ),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: ShrexTheme.cyberBlue.withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ] : null,
                ),
                child: Text(
                  '${duration}m',
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAudioVolumeSlider(BuildContext context, double volume, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GlowText(
              'Audio Volume',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              glowColor: ShrexTheme.cyberBlue,
              isGlowing: true,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: ShrexTheme.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${(volume * 100).round()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          height: 60,
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: ShrexTheme.cyberBlue,
              inactiveTrackColor: Colors.white.withOpacity(0.3),
              thumbColor: Colors.white,
              overlayColor: ShrexTheme.cyberBlue.withOpacity(0.3),
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 20,
                elevation: 15,
              ),
              trackHeight: 12,
              trackShape: const RoundedRectSliderTrackShape(),
            ),
            child: Slider(
              value: volume,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReminderTimeSelector(BuildContext context, TimeOfDay? time, Function(TimeOfDay?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GlowText(
              'Daily Reminder',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              glowColor: ShrexTheme.cyberBlue,
              isGlowing: true,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: time != null ? ShrexTheme.primaryGradient : LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.2),
                    Colors.white.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Switch(
                value: time != null,
                onChanged: (enabled) {
                  if (enabled) {
                    _selectTime(context, onChanged);
                  } else {
                    onChanged(null);
                  }
                },
                activeColor: Colors.white,
                inactiveThumbColor: Colors.white.withOpacity(0.7),
                inactiveTrackColor: Colors.white.withOpacity(0.3),
              ),
            ),
          ],
        ),
        if (time != null) ...[
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => _selectTime(context, onChanged),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.2),
                    Colors.white.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: ShrexTheme.cyberBlue.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: ShrexTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.schedule,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _selectTime(BuildContext context, Function(TimeOfDay?) onChanged) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      onChanged(time);
    }
  }

  Widget _buildFirebaseToggle(BuildContext context, bool enabled, Function(bool) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlowText(
                'Cloud Sync',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
                glowColor: ShrexTheme.cyberBlue,
                isGlowing: true,
              ),
              const SizedBox(height: 4),
              Text(
                'Sync your data across devices',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: enabled ? ShrexTheme.primaryGradient : LinearGradient(
              colors: [
                Colors.white.withOpacity(0.2),
                Colors.white.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Switch(
            value: enabled,
            onChanged: onChanged,
            activeColor: Colors.white,
            inactiveThumbColor: Colors.white.withOpacity(0.7),
            inactiveTrackColor: Colors.white.withOpacity(0.3),
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfo(BuildContext context, dynamic user) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ShrexTheme.cyberBlue.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              gradient: ShrexTheme.primaryGradient,
              borderRadius: BorderRadius.circular(25),
            ),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: ShrexTheme.deepSpaceGray,
              backgroundImage: user.photoURL != null ? NetworkImage(user.photoURL!) : null,
              child: user.photoURL == null
                  ? Text(
                      user.displayName?.isNotEmpty == true 
                          ? user.displayName![0].toUpperCase() 
                          : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName ?? user.email ?? 'Anonymous',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  user.email ?? '',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ShrexTheme.errorColor.withOpacity(0.8),
                  ShrexTheme.errorColor.withOpacity(0.6),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextButton(
              onPressed: () => FirebaseService.signOut(),
              child: const Text(
                'Sign Out',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevolutionaryActionButton(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: isDestructive 
              ? LinearGradient(
                  colors: [
                    ShrexTheme.errorColor.withOpacity(0.3),
                    ShrexTheme.errorColor.withOpacity(0.1),
                  ],
                )
              : LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.15),
                    Colors.white.withOpacity(0.08),
                  ],
                ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDestructive 
                ? ShrexTheme.errorColor.withOpacity(0.5)
                : ShrexTheme.cyberBlue.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: isDestructive 
                    ? LinearGradient(
                        colors: [
                          ShrexTheme.errorColor,
                          ShrexTheme.errorColor.withOpacity(0.7),
                        ],
                      )
                    : ShrexTheme.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: isDestructive ? ShrexTheme.errorColor : Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: isDestructive ? ShrexTheme.errorColor : Colors.white.withOpacity(0.7),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: ShrexTheme.primaryGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
