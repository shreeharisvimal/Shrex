import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../services/db_service.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';

class RewardsScreen extends HookConsumerWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userStats = useState<Map<String, dynamic>>({});
    final isLoading = useState(true);
    
    // ANIMATION CONTROLLERS
    final mainController = useAnimationController(
      duration: const Duration(milliseconds: 1500),
    );
    final glowController = useAnimationController(
      duration: const Duration(milliseconds: 2000),
    );
    final pulseController = useAnimationController(
      duration: const Duration(milliseconds: 1200),
    );

    // ANIMATIONS
    final mainAnimation = useAnimation(Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: mainController, curve: Curves.easeOutCubic),
    ));
    final glowAnimation = useAnimation(Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: glowController, curve: Curves.easeInOut),
    ));
    final pulseAnimation = useAnimation(Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: pulseController, curve: Curves.easeInOut),
    ));

    useEffect(() {
      Future<void> _loadUserStats() async {
        try {
          final stats = await DbService.getUserStats();
          userStats.value = stats;
          isLoading.value = false;
          
          // Start animations
          mainController.forward();
          glowController.repeat(reverse: true);
          pulseController.repeat(reverse: true);
        } catch (e) {
          debugPrint('Error loading user stats: $e');
          isLoading.value = false;
        }
      }
      _loadUserStats();
      return null;
    }, []);

    if (isLoading.value) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: ShrexTheme.backgroundGradient,
          ),
          child: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(ShrexTheme.cyberBlue),
            ),
          ),
        ),
      );
    }

    final currentStreak = userStats.value['current_streak'] ?? 0;
    final totalSessions = userStats.value['total_sessions'] ?? 0;
    final totalMinutes = userStats.value['total_minutes'] ?? 0;

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
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    
                    // AWESOME HEADER
                    AnimatedBuilder(
                      animation: mainController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, 30 * (1 - mainAnimation)),
                          child: Opacity(
                            opacity: mainAnimation,
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        ShrexTheme.cyberBlue,
                                        ShrexTheme.electricViolet,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: ShrexTheme.cyberBlue.withOpacity(0.4),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.emoji_events_rounded,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Your Achievements',
                                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Track your progress and unlock rewards',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: Colors.white.withOpacity(0.7),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32),

                    // ULTIMATE LEVEL CARD
                    AnimatedBuilder(
                      animation: Listenable.merge([mainController, glowController, pulseController]),
                      builder: (context, child) {
                        final level = _calculateLevel(currentStreak, totalSessions);
                        final nextLevelProgress = _calculateNextLevelProgress(currentStreak, totalSessions);
                        
                        return Transform.scale(
                          scale: pulseAnimation,
                          child: Transform.translate(
                            offset: Offset(0, 20 * (1 - mainAnimation)),
                            child: Opacity(
                              opacity: mainAnimation,
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(isTablet ? 28 : 24),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      ShrexTheme.cyberBlue.withOpacity(0.3),
                                      ShrexTheme.electricViolet.withOpacity(0.2),
                                      ShrexTheme.neonMagenta.withOpacity(0.1),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    stops: const [0.0, 0.5, 1.0],
                                  ),
                                  borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
                                  border: Border.all(
                                    color: ShrexTheme.cyberBlue.withOpacity(0.4),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 30,
                                      offset: const Offset(0, 15),
                                    ),
                                    BoxShadow(
                                      color: ShrexTheme.cyberBlue.withOpacity(0.3 * glowAnimation),
                                      blurRadius: 40,
                                      offset: const Offset(0, 20),
                                      spreadRadius: 3,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    // LEVEL ICON
                                    Container(
                                      width: isTablet ? 80 : 70,
                                      height: isTablet ? 80 : 70,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            ShrexTheme.cyberBlue,
                                            ShrexTheme.electricViolet,
                                            ShrexTheme.neonMagenta,
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(isTablet ? 40 : 35),
                                        boxShadow: [
                                          BoxShadow(
                                            color: ShrexTheme.cyberBlue.withOpacity(0.5 * glowAnimation),
                                            blurRadius: 25,
                                            offset: const Offset(0, 10),
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          '$level',
                                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w900,
                                            fontSize: isTablet ? 36 : 32,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    
                                    Text(
                                      'Level $level',
                                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Focus Master',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: Colors.white.withOpacity(0.8),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    
                                    // PROGRESS BAR
                                    Container(
                                      height: isTablet ? 12 : 10,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(isTablet ? 6 : 5),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.2),
                                          width: 1,
                                        ),
                                      ),
                                      child: Stack(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.05),
                                              borderRadius: BorderRadius.circular(isTablet ? 6 : 5),
                                            ),
                                          ),
                                          AnimatedBuilder(
                                            animation: glowController,
                                            builder: (context, child) {
                                              return Container(
                                                width: (MediaQuery.of(context).size.width * 0.8 * nextLevelProgress).clamp(0.0, MediaQuery.of(context).size.width * 0.8),
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      ShrexTheme.cyberBlue.withOpacity(0.9 * glowAnimation),
                                                      ShrexTheme.electricViolet.withOpacity(0.7 * glowAnimation),
                                                      ShrexTheme.neonMagenta.withOpacity(0.5 * glowAnimation),
                                                    ],
                                                    begin: Alignment.centerLeft,
                                                    end: Alignment.centerRight,
                                                  ),
                                                  borderRadius: BorderRadius.circular(isTablet ? 6 : 5),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: ShrexTheme.cyberBlue.withOpacity(0.6 * glowAnimation),
                                                      blurRadius: 15,
                                                      offset: const Offset(0, 3),
                                                      spreadRadius: 1,
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      '${(nextLevelProgress * 100).round()}% to next level',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Colors.white.withOpacity(0.8),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // AWESOME STATS GRID
                    AnimatedBuilder(
                      animation: mainController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, 20 * (1 - mainAnimation)),
                          child: Opacity(
                            opacity: mainAnimation,
                            child: Row(
                              children: [
                                Expanded(
                                  child: _buildStatCard(
                                    context,
                                    'Current Streak',
                                    '$currentStreak',
                                    Icons.local_fire_department_rounded,
                                    const Color(0xFFFF6B35),
                                    isTablet,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildStatCard(
                                    context,
                                    'Total Sessions',
                                    '$totalSessions',
                                    Icons.play_circle_outline_rounded,
                                    ShrexTheme.cyberBlue,
                                    isTablet,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildStatCard(
                                    context,
                                    'Minutes Focused',
                                    '$totalMinutes',
                                    Icons.access_time_rounded,
                                    ShrexTheme.electricViolet,
                                    isTablet,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // ACHIEVEMENT BADGES
                    AnimatedBuilder(
                      animation: mainController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, 20 * (1 - mainAnimation)),
                          child: Opacity(
                            opacity: mainAnimation,
                            child: Container(
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
                                borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              ShrexTheme.neonMagenta,
                                              ShrexTheme.electricViolet,
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: ShrexTheme.neonMagenta.withOpacity(0.3),
                                              blurRadius: 10,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.stars_rounded,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Achievement Badges',
                                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  
                                  GridView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: isTablet ? 4 : 3,
                                      crossAxisSpacing: isTablet ? 16 : 12,
                                      mainAxisSpacing: isTablet ? 16 : 12,
                                      childAspectRatio: isTablet ? 1.1 : 1.0,
                                    ),
                                    itemCount: _getAchievementBadges(totalSessions, totalMinutes).length,
                                    itemBuilder: (context, index) {
                                      final badge = _getAchievementBadges(totalSessions, totalMinutes)[index];
                                      return _buildBadgeCard(context, badge, isTablet);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // MOTIVATIONAL QUOTE
                    AnimatedBuilder(
                      animation: mainController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, 20 * (1 - mainAnimation)),
                          child: Opacity(
                            opacity: mainAnimation,
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(isTablet ? 24 : 20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    ShrexTheme.electricViolet.withOpacity(0.2),
                                    ShrexTheme.cyberBlue.withOpacity(0.1),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                                border: Border.all(
                                  color: ShrexTheme.electricViolet.withOpacity(0.3),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: ShrexTheme.electricViolet.withOpacity(0.2),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          ShrexTheme.electricViolet,
                                          ShrexTheme.neonMagenta,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.format_quote_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _getMotivationalQuote(currentStreak),
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: Colors.white.withOpacity(0.9),
                                      fontWeight: FontWeight.w600,
                                      height: 1.5,
                                      fontSize: isTablet ? 16 : 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color, bool isTablet) {
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
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
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
        ],
      ),
    );
  }

  Widget _buildBadgeCard(BuildContext context, AchievementBadge badge, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 16 : 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: badge.isAchieved
              ? [
                  badge.color.withOpacity(0.3),
                  badge.color.withOpacity(0.1),
                ]
              : [
                  Colors.white.withOpacity(0.05),
                  Colors.white.withOpacity(0.02),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        border: Border.all(
          color: badge.isAchieved
              ? badge.color.withOpacity(0.5)
              : Colors.white.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: badge.isAchieved
                ? badge.color.withOpacity(0.2)
                : Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(isTablet ? 12 : 8),
            decoration: BoxDecoration(
              gradient: badge.isAchieved
                  ? LinearGradient(
                      colors: [badge.color, badge.color.withOpacity(0.8)],
                    )
                  : LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.1),
                        Colors.white.withOpacity(0.05),
                      ],
                    ),
              borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
              boxShadow: badge.isAchieved
                  ? [
                      BoxShadow(
                        color: badge.color.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              badge.icon,
              color: badge.isAchieved ? Colors.white : Colors.white.withOpacity(0.4),
              size: isTablet ? 24 : 20,
            ),
          ),
          SizedBox(height: isTablet ? 8 : 6),
          Text(
            badge.title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: badge.isAchieved ? Colors.white : Colors.white.withOpacity(0.6),
              fontWeight: FontWeight.w600,
              fontSize: isTablet ? 12 : 10,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  int _calculateLevel(int streak, int sessions) {
    return ((streak * 0.3) + (sessions * 0.1)).floor() + 1;
  }

  double _calculateNextLevelProgress(int streak, int sessions) {
    final currentLevel = _calculateLevel(streak, sessions);
    final currentLevelPoints = ((currentLevel - 1) * 10).toDouble();
    final currentPoints = (streak * 0.3) + (sessions * 0.1);
    final nextLevelPoints = (currentLevel * 10).toDouble();
    
    return ((currentPoints - currentLevelPoints) / (nextLevelPoints - currentLevelPoints)).clamp(0.0, 1.0);
  }

  List<AchievementBadge> _getAchievementBadges(int sessions, int minutes) {
    return [
      AchievementBadge(
        title: 'First Session',
        icon: Icons.play_arrow_rounded,
        color: const Color(0xFF4CAF50),
        isAchieved: sessions >= 1,
      ),
      AchievementBadge(
        title: '10 Sessions',
        icon: Icons.star_rounded,
        color: const Color(0xFF2196F3),
        isAchieved: sessions >= 10,
      ),
      AchievementBadge(
        title: '50 Sessions',
        icon: Icons.star_half_rounded,
        color: const Color(0xFFFF9800),
        isAchieved: sessions >= 50,
      ),
      AchievementBadge(
        title: '100 Sessions',
        icon: Icons.stars_rounded,
        color: const Color(0xFF9C27B0),
        isAchieved: sessions >= 100,
      ),
      AchievementBadge(
        title: '1 Hour Total',
        icon: Icons.timer_rounded,
        color: const Color(0xFF00BCD4),
        isAchieved: minutes >= 60,
      ),
      AchievementBadge(
        title: '10 Hours Total',
        icon: Icons.timer_10_rounded,
        color: const Color(0xFF795548),
        isAchieved: minutes >= 600,
      ),
      AchievementBadge(
        title: '50 Hours Total',
        icon: Icons.timer_3_rounded,
        color: const Color(0xFF607D8B),
        isAchieved: minutes >= 3000,
      ),
      AchievementBadge(
        title: 'Focus Master',
        icon: Icons.emoji_events_rounded,
        color: const Color(0xFFFFD700),
        isAchieved: sessions >= 200,
      ),
    ];
  }

  String _getMotivationalQuote(int streak) {
    final quotes = [
      "Every expert was once a beginner. Every pro was once an amateur.",
      "The only impossible journey is the one you never begin.",
      "Success is not final, failure is not fatal: it is the courage to continue that counts.",
      "The future belongs to those who believe in the beauty of their dreams.",
      "Don't watch the clock; do what it does. Keep going.",
      "The secret of getting ahead is getting started.",
      "Great things never come from comfort zones.",
      "Dream it. Wish it. Do it.",
      "Success doesn't just find you. You have to go out and get it.",
      "The harder you work for something, the greater you'll feel when you achieve it.",
    ];
    
    return quotes[streak % quotes.length];
  }
}

class AchievementBadge {
  final String title;
  final IconData icon;
  final Color color;
  final bool isAchieved;

  AchievementBadge({
    required this.title,
    required this.icon,
    required this.color,
    required this.isAchieved,
  });
}