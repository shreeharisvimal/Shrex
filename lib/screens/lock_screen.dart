import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../services/timer_service.dart';
import '../widgets/progress_ring.dart';
import '../widgets/gradient_button.dart';
import '../widgets/confetti_widget.dart';
import '../widgets/particle_effects.dart';
import '../widgets/audio_visual_effects.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';
import 'emergency_unlock_screen.dart';
import 'home_screen.dart';
import '../providers/timer_provider.dart';
import '../widgets/app_logo.dart';

class LockScreen extends HookConsumerWidget {
  const LockScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerService = ref.watch(timerServiceProvider);
    final showConfetti = useState(false);
    final motivationalMessage = useState(AppConstants.motivationalMessages[0]);
    final emergencyAttempts = useState(0);
    
    // Animation controller for pulsing effect
    final animationController = useAnimationController(
      duration: const Duration(seconds: 2),
    );
    
    // Start pulsing animation
    useEffect(() {
      if (timerService.isRunning) {
        animationController.repeat(reverse: true);
      } else {
        animationController.stop();
      }
      return null;
    }, [timerService.isRunning]);

    // Update motivational message more frequently for better engagement
    useEffect(() {
      if (timerService.isRunning) {
        debugPrint('Starting motivational message timer');
        final interval = Timer.periodic(const Duration(seconds: 10), (timer) {
          if (timerService.isRunning) {
            final random = Random();
            final newMessage = AppConstants.motivationalMessages[
              random.nextInt(AppConstants.motivationalMessages.length)
            ];
            debugPrint('Changing motivational message to: $newMessage');
            motivationalMessage.value = newMessage;
          } else {
            debugPrint('Timer stopped, canceling motivational message timer');
            timer.cancel();
          }
        });
        return () {
          debugPrint('Cleaning up motivational message timer');
          interval.cancel();
        };
      }
      return null;
    }, [timerService.isRunning]);

    // Show confetti when session completes and auto-redirect
    useEffect(() {
      if (timerService.isComplete) {
        debugPrint('Session completed! Showing celebration...');
        showConfetti.value = true;
        
        // Auto-redirect after 3 seconds
        Timer(const Duration(seconds: 3), () {
          if (context.mounted) {
            debugPrint('Auto-redirecting to home screen...');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          }
        });
        
        // Hide confetti after 5 seconds
        Timer(const Duration(seconds: 5), () {
          showConfetti.value = false;
          debugPrint('Confetti animation ended');
        });
      }
      return null;
    }, [timerService.isComplete]);

    // Handle emergency unlock
    void _handleEmergencyUnlock() async {
      emergencyAttempts.value++;
      
      if (emergencyAttempts.value >= 3) {
        // After 3 attempts, show emergency unlock screen
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EmergencyUnlockScreen(),
            ),
          );
        }
      } else {
        // Show warning for first 2 attempts
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Emergency unlock attempt ${emergencyAttempts.value}/3. ${3 - emergencyAttempts.value} attempts remaining.',
              ),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    }

    // FULL TRAP MODE - Disable all gestures and navigation
    return PopScope(
      canPop: false, // Block back button completely
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black,
                ShrexTheme.electricViolet.withOpacity(0.1),
                Colors.black,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                // Main content - Show different content based on completion status
                Center(
                  child: timerService.isComplete 
                    ? _buildCompletionScreen(context, animationController)
                    : _buildActiveSessionScreen(context, timerService, motivationalMessage, animationController, emergencyAttempts, _handleEmergencyUnlock),
                ),

                // Emergency unlock button - ONLY WAY TO ESCAPE
                Positioned(
                  bottom: 50,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: 200,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.red.withOpacity(0.8),
                            Colors.orange.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(25),
                          onTap: _handleEmergencyUnlock,
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.emergency,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'EMERGENCY UNLOCK',
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Confetti overlay
                if (showConfetti.value)
                  ConfettiWidget(
                    isActive: true,
                    child: Container(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompletionScreen(BuildContext context, AnimationController animationController) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isTablet = screenWidth > 600;
        final horizontalPadding = isTablet ? 48.0 : 24.0;
        
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isTablet ? 800 : double.infinity,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: isTablet ? 60 : 40),
                
                // Success logo with animation - RESPONSIVE
                AnimatedBuilder(
                  animation: animationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + (animationController.value * 0.1),
                      child: Container(
                        width: isTablet ? 180 : 150,
                        height: isTablet ? 180 : 150,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.green,
                              Colors.lightGreen,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(isTablet ? 90 : 75),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.5),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const AppLogoIcon(
                          size: 80,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: isTablet ? 40 : 32),

                // Success message - IMPROVED TYPOGRAPHY
                Text(
                  '🎉 SESSION COMPLETE! 🎉',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: isTablet ? 24 : 20),

                // Congratulations message - IMPROVED
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 32 : 24,
                    vertical: isTablet ? 24 : 20,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.green.withOpacity(0.3),
                        Colors.lightGreen.withOpacity(0.3),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(isTablet ? 28 : 25),
                    border: Border.all(
                      color: Colors.green.withOpacity(0.5),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.3),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Text(
                    'Amazing work! You stayed focused and completed your session! 🌟',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: isTablet ? 40 : 32),

                // Return button - IMPROVED
                Container(
                  width: double.infinity,
                  height: isTablet ? 64 : 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.green,
                        Colors.lightGreen,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(isTablet ? 28 : 25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.4),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(isTablet ? 28 : 25),
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const HomeScreen()),
                        );
                      },
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.home_outlined,
                              color: Colors.white,
                              size: isTablet ? 28 : 24,
                            ),
                            SizedBox(width: isTablet ? 16 : 12),
                            Text(
                              'Return to Home',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: isTablet ? 40 : 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActiveSessionScreen(BuildContext context, TimerService timerService, ValueNotifier<String> motivationalMessage, AnimationController animationController, ValueNotifier<int> emergencyAttempts, VoidCallback onEmergencyUnlock) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isTablet = screenWidth > 600;
        final horizontalPadding = isTablet ? 48.0 : 24.0;
        
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isTablet ? 800 : double.infinity,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: isTablet ? 60 : 40),
                
                // App Logo with animation - RESPONSIVE
                AnimatedBuilder(
                  animation: animationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + (animationController.value * 0.05),
                      child: AppLogoIcon(
                        size: isTablet ? 140 : 120,
                        isGlowing: true,
                      ),
                    );
                  },
                ),
                SizedBox(height: isTablet ? 40 : 32),

                // Focus session title - IMPROVED TYPOGRAPHY
                Text(
                  'FOCUS SESSION ACTIVE',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: isTablet ? 24 : 20),

                // Progress ring with timer - RESPONSIVE & ANIMATED
                AnimatedBuilder(
                  animation: animationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + (animationController.value * 0.05),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: ShrexTheme.accentColor.withOpacity(0.3),
                              blurRadius: 20 + (animationController.value * 10),
                              spreadRadius: 5 + (animationController.value * 5),
                            ),
                          ],
                        ),
                        child: ProgressRing(
                          progress: timerService.progress,
                          size: isTablet ? 240 : 200,
                          strokeWidth: isTablet ? 14 : 12,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          color: ShrexTheme.accentColor,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                timerService.formattedTime,
                                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              SizedBox(height: isTablet ? 8 : 6),
                              Text(
                                'remaining',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.white.withOpacity(0.7),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: isTablet ? 40 : 32),

                // Motivational message with animation - IMPROVED
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: Container(
                    key: ValueKey(motivationalMessage.value),
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 32 : 24,
                      vertical: isTablet ? 20 : 16,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          ShrexTheme.electricViolet.withOpacity(0.3),
                          ShrexTheme.cyberBlue.withOpacity(0.3),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(isTablet ? 28 : 25),
                      border: Border.all(
                        color: ShrexTheme.accentColor.withOpacity(0.5),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: ShrexTheme.accentColor.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Text(
                      motivationalMessage.value,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                SizedBox(height: isTablet ? 40 : 32),

                // Session info - IMPROVED
                Container(
                  padding: EdgeInsets.all(isTablet ? 24 : 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.1),
                        Colors.white.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Session Duration: ${_formatDuration(timerService.sessionDuration ~/ 60)}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: isTablet ? 12 : 8),
                      Text(
                        'Started: ${_formatTime(timerService.sessionStartTime)}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withOpacity(0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isTablet ? 40 : 32),

                // Emergency unlock button - IMPROVED
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: isTablet ? 48 : 40),
                  child: ElevatedButton(
                    onPressed: onEmergencyUnlock,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.withOpacity(0.8),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: isTablet ? 20 : 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(isTablet ? 28 : 25),
                      ),
                      elevation: 8,
                      shadowColor: Colors.red.withOpacity(0.3),
                    ),
                    child: Text(
                      'Emergency Unlock (${emergencyAttempts.value}/3)',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: isTablet ? 40 : 32),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m ${secs}s';
    } else if (minutes > 0) {
      return '${minutes}m ${secs}s';
    } else {
      return '${secs}s';
    }
  }

  String _formatTime(DateTime? time) {
    if (time == null) return 'Unknown';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}