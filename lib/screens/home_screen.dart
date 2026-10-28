import 'package:flutter/material.dart';
// Removed unused direct flutter_riverpod import; using hooks_riverpod
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
// Removed unused imports
import '../utils/theme.dart';
import '../widgets/session_time_selector.dart';
// Removed unused import
import '../providers/timer_provider.dart';
import 'lock_screen.dart';
// Removed unused import

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = useState(false);
    final selectedDuration = useState(25.0);
    final userStats = useState<Map<String, dynamic>>({});

    // ENHANCED INTERACTIVE ANIMATION CONTROLLERS
    final timeChangeController = useAnimationController(
      duration: const Duration(milliseconds: 400),
    );
    final pulseController = useAnimationController(
      duration: const Duration(milliseconds: 1800),
    );
    final glowController = useAnimationController(
      duration: const Duration(milliseconds: 2500),
    );
    final inspirationController = useAnimationController(
      duration: const Duration(milliseconds: 2200),
    );
    final quoteSlideController = useAnimationController(
      duration: const Duration(milliseconds: 1000),
    );
    final quoteFadeController = useAnimationController(
      duration: const Duration(milliseconds: 800),
    );
    final statsController = useAnimationController(
      duration: const Duration(milliseconds: 1500),
    );
    final buttonController = useAnimationController(
      duration: const Duration(milliseconds: 1200),
    );
    final headerController = useAnimationController(
      duration: const Duration(milliseconds: 1000),
    );

    // ENHANCED INTERACTIVE ANIMATIONS
    final timeChangeScale = useAnimation(Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: timeChangeController, curve: Curves.elasticOut),
    ));
    final pulseAnimation = useAnimation(Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: pulseController, curve: Curves.easeInOut),
    ));
    final glowAnimation = useAnimation(Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: glowController, curve: Curves.easeInOut),
    ));
    final inspirationScale = useAnimation(Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: inspirationController, curve: Curves.elasticOut),
    ));
    final quoteSlide = useAnimation(Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(
      CurvedAnimation(parent: quoteSlideController, curve: Curves.easeOutCubic),
    ));
    final quoteFade = useAnimation(Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: quoteFadeController, curve: Curves.easeIn),
    ));
    // Removed unused animations

    // MOTIVATIONAL QUOTES
    final motivationalQuotes = [
      "The future belongs to those who believe in the beauty of their dreams.",
      "Success is not final, failure is not fatal: it is the courage to continue that counts.",
      "The only way to do great work is to love what you do.",
      "Don't watch the clock; do what it does. Keep going.",
      "The secret of getting ahead is getting started.",
      "Your limitation—it's only your imagination.",
      "Great things never come from comfort zones.",
      "Dream it. Wish it. Do it.",
      "Success doesn't just find you. You have to go out and get it.",
      "The harder you work for something, the greater you'll feel when you achieve it.",
      "Dream bigger. Do bigger.",
      "Don't stop when you're tired. Stop when you're done.",
      "Wake up with determination. Go to bed with satisfaction.",
      "Do something today that your future self will thank you for.",
      "Little things make big days.",
      "It's going to be hard, but hard does not mean impossible.",
      "Don't wait for opportunity. Create it.",
      "Sometimes we're tested not to show our weaknesses, but to discover our strengths.",
      "The key to success is to focus on goals, not obstacles.",
      "Dream it. Believe it. Build it.",
    ];

    // Start optimized animations
    useEffect(() {
      pulseController.repeat(reverse: true);
      glowController.repeat(reverse: true);
      
      // Start inspiration animations
      Future.delayed(const Duration(milliseconds: 500), () {
        inspirationController.forward();
      });
      Future.delayed(const Duration(milliseconds: 800), () {
        quoteSlideController.forward();
        quoteFadeController.forward();
      });
      
      return null;
    }, []);

    // Load user stats
    useEffect(() {
      Future<void> _loadUserStats() async {
        try {
          final prefs = await SharedPreferences.getInstance();
          final statsJson = prefs.getString('user_stats');
          if (statsJson != null) {
            userStats.value = Map<String, dynamic>.from(json.decode(statsJson));
          }
        } catch (e) {
          debugPrint('Error loading user stats: $e');
        }
      }
      _loadUserStats();
      return null;
    }, []);

    String _getGreeting() {
      final hour = DateTime.now().hour;
      if (hour >= 5 && hour < 12) return 'Morning';
      if (hour >= 12 && hour < 17) return 'Afternoon';
      if (hour >= 17 && hour < 21) return 'Evening';
      return 'Night';
    }

    // DYNAMIC COLOR BASED ON DURATION
    Color _getDurationColor(double duration) {
      if (duration <= 15) {
        return const Color(0xFF4CAF50); // Green for short sessions
      } else if (duration <= 30) {
        return const Color(0xFF2196F3); // Blue for medium sessions
      } else if (duration <= 60) {
        return const Color(0xFFFF9800); // Orange for long sessions
      } else {
        return const Color(0xFFF44336); // Red for very long sessions
      }
    }

    String _getDurationLabel(double duration) {
      if (duration <= 15) {
        return 'Quick Focus';
      } else if (duration <= 30) {
        return 'Standard Focus';
      } else if (duration <= 60) {
        return 'Deep Focus';
      } else {
        return 'Marathon Focus';
      }
    }

    Future<void> _startSession() async {
      if (isLoading.value) return;
      
      isLoading.value = true;
      try {
        // Get the timer service and start the session with the selected duration
        final timerService = ref.read(timerServiceProvider);
        final durationInSeconds = (selectedDuration.value * 60).toInt(); // Convert minutes to seconds
        
        debugPrint('Starting session with ${selectedDuration.value} minutes (${durationInSeconds} seconds)');
        
        // Start the actual timer session
        final success = await timerService.startSession(durationInSeconds);
        
        if (success && context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LockScreen(),
            ),
          );
        } else if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Failed to start session'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      } catch (e) {
        debugPrint('Error starting session: $e');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to start session: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      } finally {
        isLoading.value = false;
      }
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: ShrexTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isTablet = constraints.maxWidth > 600;
              final horizontalPadding = isTablet ? 32.0 : 20.0;
              
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    // Leave room for the bottom nav bar to prevent last section being obscured
                    minHeight: constraints.maxHeight - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom + 96,
                  ),
          child: Column(
            children: [
                      const SizedBox(height: 24),
                      
                      // ULTRA CLASSY HEADER
                    Row(
                      children: [
                          Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                                Text(
                                  'Good ${_getGreeting()}',
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                              ),
                            ),
                                const SizedBox(height: 4),
                            Text(
                                  'Ready to unlock your potential?',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.white.withOpacity(0.7),
                                    fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                    ),
                          // PROFILE AVATAR
                    Container(
                          width: 50,
                          height: 50,
                      decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  ShrexTheme.cyberBlue,
                                  ShrexTheme.electricViolet,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 2,
                              ),
                        boxShadow: [
                          BoxShadow(
                                  color: ShrexTheme.cyberBlue.withOpacity(0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                            child: const Center(
                              child: Icon(
                                Icons.person_rounded,
                          color: Colors.white,
                                size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
                      const SizedBox(height: 32),

                      // ULTIMATE STATS DASHBOARD
                      Container(
                        width: double.infinity,
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
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
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
                                        color: ShrexTheme.cyberBlue.withOpacity(0.3),
                                        blurRadius: 10,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.trending_up_rounded,
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
                                        'Today\'s Progress',
                                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Keep the momentum going!',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: Colors.white.withOpacity(0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            
                            // SUPER DUPER PROGRESS STATS GRID
                            Row(
                              children: [
                                Expanded(
                                  child: _buildSuperStatsCard(
                                    context,
                                    'Sessions',
                                    '${userStats.value['total_sessions'] ?? 0}',
                                    Icons.play_circle_outline_rounded,
                                    ShrexTheme.cyberBlue,
                                    isTablet,
                                    (userStats.value['total_sessions'] ?? 0) / 100.0,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildSuperStatsCard(
                                    context,
                                    'Minutes',
                                    '${userStats.value['total_minutes'] ?? 0}',
                                    Icons.access_time_rounded,
                                    ShrexTheme.electricViolet,
                                    isTablet,
                                    (userStats.value['total_minutes'] ?? 0) / 1000.0,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildSuperStatsCard(
                                    context,
                                    'Streak',
                                    '${userStats.value['current_streak'] ?? 0}',
                                    Icons.local_fire_department_rounded,
                                    ShrexTheme.neonMagenta,
                                    isTablet,
                                    (userStats.value['current_streak'] ?? 0) / 30.0,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ANIMATED DAILY INSPIRATION SECTION
                      AnimatedBuilder(
                        animation: inspirationController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: inspirationScale,
                                  child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 20, vertical: isTablet ? 22 : 18),
                                    decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.12),
                                    Colors.white.withOpacity(0.06),
                                    Colors.white.withOpacity(0.03),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  stops: const [0.0, 0.5, 1.0],
                                ),
                                borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1.5,
                                ),
                                      boxShadow: [
                                        BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                  BoxShadow(
                                    color: ShrexTheme.cyberBlue.withOpacity(0.1 * glowAnimation),
                                    blurRadius: 30,
                                    offset: const Offset(0, 15),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // ANIMATED HEADER
                                  AnimatedBuilder(
                                    animation: Listenable.merge([glowController, pulseController]),
                                    builder: (context, child) {
                                      return Transform.scale(
                                        scale: pulseAnimation,
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    ShrexTheme.cyberBlue.withOpacity(0.9 * glowAnimation),
                                                    ShrexTheme.electricViolet.withOpacity(0.7 * glowAnimation),
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                borderRadius: BorderRadius.circular(16),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: ShrexTheme.cyberBlue.withOpacity(0.4 * glowAnimation),
                                          blurRadius: 15,
                                                    offset: const Offset(0, 5),
                                                    spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                              child: Icon(
                                                Icons.auto_awesome_rounded,
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
                                                    'Daily Inspiration',
                                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                            color: Colors.white,
                                                      fontWeight: FontWeight.w800,
                                                      letterSpacing: 0.5,
                                          ),
                                        ),
                                                  const SizedBox(height: 4),
                                        Text(
                                                    'Fuel your motivation',
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                      color: Colors.white.withOpacity(0.7),
                                                      fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                            // ANIMATED SPARKLE EFFECT
                                            AnimatedBuilder(
                                              animation: glowController,
                                              builder: (context, child) {
                                                return Opacity(
                                                  opacity: glowAnimation,
                                  child: Container(
                                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: [
                                                          ShrexTheme.electricViolet.withOpacity(0.3),
                                                          ShrexTheme.neonMagenta.withOpacity(0.2),
                                                        ],
                                                      ),
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    child: Icon(
                                                      Icons.star_rounded,
                                                      color: Colors.white,
                                                      size: 16,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  
                                  // ANIMATED QUOTE DISPLAY
                                  AnimatedBuilder(
                                    animation: Listenable.merge([quoteSlideController, quoteFadeController]),
                                    builder: (context, child) {
                                      return Transform.translate(
                                        offset: Offset(0, 20 * (1 - quoteSlide.dy)),
                                        child: Opacity(
                                          opacity: quoteFade,
                                          child: Container(
                                            padding: EdgeInsets.symmetric(horizontal: isTablet ? 20 : 16, vertical: isTablet ? 18 : 14),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.white.withOpacity(0.08),
                                                  Colors.white.withOpacity(0.04),
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                                              border: Border.all(
                                                color: Colors.white.withOpacity(0.15),
                                                width: 1,
                                              ),
                                    ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.stretch,
                                              children: [
                                                // QUOTE ICON
                                                Container(
                                                  padding: const EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        ShrexTheme.electricViolet.withOpacity(0.3),
                                                        ShrexTheme.neonMagenta.withOpacity(0.2),
                                                      ],
                                                    ),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Icon(
                                                    Icons.format_quote_rounded,
                                                    color: Colors.white.withOpacity(0.8),
                                                    size: 20,
                                                  ),
                                                ),
                                                const SizedBox(height: 12),
                                                
                                                // QUOTE TEXT
                                        Text(
                                                  motivationalQuotes[DateTime.now().day % motivationalQuotes.length],
                                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                                    color: Colors.white.withOpacity(0.95),
                                            fontWeight: FontWeight.w600,
                                                    height: 1.6,
                                                    fontSize: isTablet ? 16 : 14,
                                                    letterSpacing: 0.3,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                                
                                                const SizedBox(height: 12),
                                                
                                                // ANIMATED DIVIDER
                                                AnimatedBuilder(
                                                  animation: glowController,
                                                  builder: (context, child) {
                                                    return Container(
                                                      height: 2,
                                                      decoration: BoxDecoration(
                                                        gradient: LinearGradient(
                                                          colors: [
                                                            Colors.transparent,
                                                            ShrexTheme.cyberBlue.withOpacity(0.6 * glowAnimation),
                                                            ShrexTheme.electricViolet.withOpacity(0.4 * glowAnimation),
                                                            Colors.transparent,
                                                          ],
                                                          stops: const [0.0, 0.3, 0.7, 1.0],
                                                        ),
                                                        borderRadius: BorderRadius.circular(1),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                            ),
                          ],
                        ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),

                      // ULTIMATE SESSION DURATION SELECTOR
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(isTablet ? 24 : 20),
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
                          borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
                          border: Border.all(
                            color: ShrexTheme.accentColor.withOpacity(0.3),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: ShrexTheme.accentColor.withOpacity(0.2),
                              blurRadius: 30,
                              offset: const Offset(0, 15),
                            ),
                          ],
                        ),
                        child: Column(
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
                                    Icons.schedule_outlined,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    'Session Duration',
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                          color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            
                            // DYNAMIC COLORED TIME DISPLAY
                            AnimatedBuilder(
                              animation: timeChangeController,
                              builder: (context, child) {
                                final durationColor = _getDurationColor(selectedDuration.value);
                                return Transform.scale(
                                  scale: timeChangeScale,
                                  child: Column(
                                    children: [
                                      // ANIMATED TIMER NUMBER WITH DYNAMIC COLOR
                                      AnimatedBuilder(
                                        animation: glowController,
                                        builder: (context, child) {
                                          return Container(
                                            padding: EdgeInsets.all(isTablet ? 16 : 12),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  durationColor.withOpacity(0.2 * glowAnimation),
                                                  durationColor.withOpacity(0.1 * glowAnimation),
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                                              border: Border.all(
                                                color: durationColor.withOpacity(0.4 * glowAnimation),
                                                width: 2,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: durationColor.withOpacity(0.3 * glowAnimation),
                                                  blurRadius: 20,
                                                  offset: const Offset(0, 8),
                                                  spreadRadius: 2,
                                                ),
                                              ],
                                            ),
                                            child: Text(
                                              '${selectedDuration.value.toInt()}',
                                              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                                color: durationColor,
                                                fontWeight: FontWeight.w900,
                                                fontSize: isTablet ? 48 : 40,
                                                letterSpacing: 1.0,
                                                shadows: [
                                                  Shadow(
                                                    color: durationColor.withOpacity(0.5),
                                                    offset: const Offset(0, 3),
                                                    blurRadius: 6,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 12),
                                      
                                      // DYNAMIC LABEL
                                      Text(
                                        _getDurationLabel(selectedDuration.value),
                                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          color: _getDurationColor(selectedDuration.value),
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Minutes',
                                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                          color: Colors.white.withOpacity(0.8),
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                                );
                              },
                            ),
                            const SizedBox(height: 24),
                            
                            // DYNAMIC COLORED QUICK SELECT GRID
                            SessionTimeSelector(
                              initialDuration: selectedDuration.value.toInt(),
                              onDurationChanged: (duration) {
                                selectedDuration.value = duration.toDouble();
                                timeChangeController.forward().then((_) {
                                  timeChangeController.reverse();
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // DYNAMIC COLORED FOCUS SESSION BUTTON
                      AnimatedBuilder(
                        animation: pulseController,
                        builder: (context, child) {
                          final durationColor = _getDurationColor(selectedDuration.value);
                          return Transform.scale(
                            scale: pulseAnimation,
                            child: Container(
                        width: double.infinity,
                              height: isTablet ? 70 : 60,
                        decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    durationColor.withOpacity(0.2),
                                    durationColor.withOpacity(0.1),
                                    durationColor.withOpacity(0.05),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                                border: Border.all(
                                  color: durationColor.withOpacity(0.4),
                                  width: 1.5,
                                ),
                          boxShadow: [
                            BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                  BoxShadow(
                                    color: durationColor.withOpacity(0.3 * glowAnimation),
                                    blurRadius: 30,
                                    offset: const Offset(0, 15),
                                    spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                                  onTap: isLoading.value ? null : _startSession,
                                  borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                                  splashColor: durationColor.withOpacity(0.2),
                                  highlightColor: durationColor.withOpacity(0.1),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: isTablet ? 32 : 24),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                        // DYNAMIC COLORED ICON
                                        Container(
                                          width: isTablet ? 40 : 36,
                                          height: isTablet ? 40 : 36,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                durationColor,
                                                durationColor.withOpacity(0.8),
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            borderRadius: BorderRadius.circular(isTablet ? 20 : 18),
                                            boxShadow: [
                                              BoxShadow(
                                                color: durationColor.withOpacity(0.5),
                                                blurRadius: 15,
                                                offset: const Offset(0, 5),
                                                spreadRadius: 1,
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: Icon(
                                              isLoading.value ? Icons.hourglass_empty : Icons.timer_outlined,
                                        color: Colors.white,
                                              size: isTablet ? 20 : 18,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: isTablet ? 20 : 16),
                                        
                                        // DYNAMIC TEXT DESIGN
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                    Text(
                                                isLoading.value ? 'Starting Session...' : 'Begin Focus Session',
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        color: Colors.white,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: isTablet ? 18 : 16,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                              if (!isLoading.value) ...[
                                                SizedBox(height: isTablet ? 4 : 2),
                                                Text(
                                                  '${selectedDuration.value.toInt()} minutes • ${_getDurationLabel(selectedDuration.value)}',
                                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                    color: durationColor.withOpacity(0.9),
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: isTablet ? 14 : 12,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                                        
                                        // DYNAMIC LOADING SPINNER
                                        if (isLoading.value) ...[
                                          SizedBox(width: isTablet ? 20 : 16),
                                          SizedBox(
                                            width: isTablet ? 20 : 18,
                                            height: isTablet ? 20 : 18,
                                            child: CircularProgressIndicator(
                                              valueColor: AlwaysStoppedAnimation<Color>(durationColor),
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSuperStatsCard(BuildContext context, String title, String value, IconData icon, Color color, bool isTablet, double progress) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.2),
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: isTablet ? 24 : 20,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: isTablet ? 24 : 20,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w600,
              fontSize: isTablet ? 14 : 12,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Container(
            height: isTablet ? 8 : 6,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(isTablet ? 4 : 3),
            ),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(isTablet ? 4 : 3),
                  ),
                ),
                Container(
                  width: (MediaQuery.of(context).size.width * 0.25 * progress.clamp(0.0, 1.0)),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withOpacity(0.8)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(isTablet ? 4 : 3),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.5),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}