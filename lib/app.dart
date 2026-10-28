import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'screens/home_screen.dart';
import 'screens/lock_screen.dart';
import 'screens/rewards_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/leaderboard_screen.dart';
import 'screens/settings_screen.dart';
import 'utils/theme.dart';
import 'widgets/app_logo.dart';
import 'services/app_services.dart';

class ShrexApp extends ConsumerWidget {
  const ShrexApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Shrex Focus',
      theme: ShrexTheme.light(),
      darkTheme: ShrexTheme.dark(),
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/home': (context) => const MainNavigationWrapper(),
        '/lock': (context) => const LockScreen(),
        '/rewards': (context) => const RewardsScreen(),
        '/analytics': (context) => const AnalyticsScreen(),
        '/leaderboard': (context) => const LeaderboardScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}

class MainNavigationWrapper extends HookConsumerWidget {
  const MainNavigationWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = useState(0);

    final screens = [
      const HomeScreen(),
      const AnalyticsScreen(),
      const LeaderboardScreen(),
      const RewardsScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: currentIndex.value,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF1A1A2E).withOpacity(0.95),
              const Color(0xFF16213E).withOpacity(0.95),
              const Color(0xFF0F1419).withOpacity(0.95),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          border: Border(
            top: BorderSide(
              color: ShrexTheme.cyberBlue.withOpacity(0.3),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  context,
                  currentIndex,
                  0,
                  Icons.home_rounded,
                  'Focus',
                  ShrexTheme.cyberBlue,
                ),
                _buildNavItem(
                  context,
                  currentIndex,
                  1,
                  Icons.analytics_rounded,
                  'Analytics',
                  ShrexTheme.electricViolet,
                ),
                _buildNavItem(
                  context,
                  currentIndex,
                  2,
                  Icons.leaderboard_rounded,
                  'Leaderboard',
                  ShrexTheme.neonMagenta,
                ),
                _buildNavItem(
                  context,
                  currentIndex,
                  3,
                  Icons.card_giftcard_rounded,
                  'Rewards',
                  ShrexTheme.accentColor,
                ),
                _buildNavItem(
                  context,
                  currentIndex,
                  4,
                  Icons.settings_rounded,
                  'Settings',
                  Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    ValueNotifier<int> currentIndex,
    int index,
    IconData icon,
    String label,
    Color activeColor,
  ) {
    final isSelected = currentIndex.value == index;

    return GestureDetector(
      onTap: () {
        // Add haptic feedback for better interaction
        // HapticFeedback.lightImpact();
        currentIndex.value = index;
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    activeColor.withOpacity(0.3),
                    activeColor.withOpacity(0.1),
                    activeColor.withOpacity(0.05),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.5, 1.0],
                )
              : null,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(
                  color: activeColor.withOpacity(0.6),
                  width: 2,
                )
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: activeColor.withOpacity(0.2),
                    blurRadius: 40,
                    offset: const Offset(0, 16),
                    spreadRadius: 4,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOutCubic,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [
                          activeColor,
                          activeColor.withOpacity(0.8),
                          activeColor.withOpacity(0.6),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        stops: const [0.0, 0.5, 1.0],
                      )
                    : LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.1),
                          Colors.white.withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: activeColor.withOpacity(0.5),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                          spreadRadius: 1,
                        ),
                        BoxShadow(
                          color: activeColor.withOpacity(0.3),
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                          spreadRadius: 2,
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: AnimatedScale(
                scale: isSelected ? 1.1 : 1.0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOutCubic,
                child: Icon(
                  icon,
                  color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
                  size: 22,
                ),
              ),
            ),
            const SizedBox(height: 6),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isSelected ? activeColor : Colors.white.withOpacity(0.6),
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                fontSize: 11,
                letterSpacing: 0.5,
              ) ?? const TextStyle(),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

class SplashScreen extends HookConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // FAST INTERACTIVE ANIMATION CONTROLLERS
    final logoController = useAnimationController(
      duration: const Duration(milliseconds: 800),
    );
    final textController = useAnimationController(
      duration: const Duration(milliseconds: 600),
    );
    final glowController = useAnimationController(
      duration: const Duration(milliseconds: 1500),
    );
    final fadeController = useAnimationController(
      duration: const Duration(milliseconds: 500),
    );
    final particleController = useAnimationController(
      duration: const Duration(milliseconds: 2000),
    );
    final rotationController = useAnimationController(
      duration: const Duration(milliseconds: 1000),
    );

    // INTERACTIVE ANIMATIONS
    final logoScale = useAnimation(Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: logoController, curve: Curves.elasticOut),
    ));
    final logoOpacity = useAnimation(Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: logoController, curve: Curves.easeIn),
    ));
    final logoRotation = useAnimation(Tween<double>(begin: 0.0, end: 0.1).animate(
      CurvedAnimation(parent: rotationController, curve: Curves.easeInOut),
    ));
    final textSlide = useAnimation(Tween<Offset>(begin: const Offset(0, 0.8), end: Offset.zero).animate(
      CurvedAnimation(parent: textController, curve: Curves.easeOutBack),
    ));
    final textOpacity = useAnimation(Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: textController, curve: Curves.easeIn),
    ));
    final glowAnimation = useAnimation(Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: glowController, curve: Curves.easeInOut),
    ));
    final fadeAnimation = useAnimation(Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: fadeController, curve: Curves.easeIn),
    ));
    final particleAnimation = useAnimation(Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: particleController, curve: Curves.easeInOut),
    ));

    // Initialize app services and start animations
    useEffect(() {
      Future<void> _initializeApp() async {
        try {
          // Start logo animation immediately with bounce effect
          logoController.forward();
          
          // Start particle animation for background effects
          particleController.repeat(reverse: true);
          
          // Start glow animation with pulsing effect
          glowController.repeat(reverse: true);
          
          // Start subtle rotation animation
          rotationController.repeat(reverse: true);
          
          // Wait a bit then start text animation with bounce
          await Future.delayed(const Duration(milliseconds: 300));
          textController.forward();
          
          // Initialize app services
          await Future.delayed(const Duration(milliseconds: 200));
          
          // Wait for animations to complete
          await Future.delayed(const Duration(milliseconds: 800));
          
          // Start fade out animation
          fadeController.forward();
          
          // Wait for fade out to complete
          await Future.delayed(const Duration(milliseconds: 500));
          
          // Navigate to home screen
          if (context.mounted) {
            Navigator.of(context).pushReplacementNamed('/home');
          }
        } catch (e) {
          print('Error initializing app: $e');
          // Navigate to home screen even if there's an error
          if (context.mounted) {
            Navigator.of(context).pushReplacementNamed('/home');
          }
        }
      }
      
      _initializeApp();
      return null;
    }, []);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF1A1A2E),
              const Color(0xFF16213E),
              const Color(0xFF0F1419),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // INTERACTIVE PARTICLE BACKGROUND
            ...List.generate(15, (index) {
              return Positioned(
                left: (index * 80.0) % MediaQuery.of(context).size.width,
                top: (index * 120.0) % MediaQuery.of(context).size.height,
                child: AnimatedBuilder(
                  animation: particleController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: particleAnimation,
                      child: Opacity(
                        opacity: particleAnimation,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: ShrexTheme.cyberBlue.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(3),
                            boxShadow: [
                              BoxShadow(
                                color: ShrexTheme.cyberBlue.withOpacity(0.8),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
            
            // MAIN CONTENT
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // INTERACTIVE LOGO ANIMATION
                  AnimatedBuilder(
                    animation: Listenable.merge([logoController, glowController, rotationController]),
                    builder: (context, child) {
                      return Transform.scale(
                        scale: logoScale,
                        child: Transform.rotate(
                          angle: logoRotation,
                          child: Opacity(
                            opacity: logoOpacity,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    ShrexTheme.cyberBlue.withOpacity(0.9 * glowAnimation),
                                    ShrexTheme.electricViolet.withOpacity(0.7 * glowAnimation),
                                    ShrexTheme.neonMagenta.withOpacity(0.5 * glowAnimation),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(60),
                                border: Border.all(
                                  color: ShrexTheme.cyberBlue.withOpacity(0.8 * glowAnimation),
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: ShrexTheme.cyberBlue.withOpacity(0.6 * glowAnimation),
                                    blurRadius: 40,
                                    offset: const Offset(0, 20),
                                    spreadRadius: 5,
                                  ),
                                  BoxShadow(
                                    color: ShrexTheme.electricViolet.withOpacity(0.4 * glowAnimation),
                                    blurRadius: 60,
                                    offset: const Offset(0, 30),
                                    spreadRadius: 8,
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: AppLogoIcon(
                                  size: 60,
                                  isGlowing: true,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // INTERACTIVE TEXT ANIMATION
                  AnimatedBuilder(
                    animation: Listenable.merge([textController, glowController]),
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, 30 * (1 - textSlide.dy)),
                        child: Opacity(
                          opacity: textOpacity,
                          child: Column(
                            children: [
                              ShaderMask(
                                shaderCallback: (bounds) {
                                  return LinearGradient(
                                    colors: [
                                      Colors.white,
                                      ShrexTheme.cyberBlue.withOpacity(glowAnimation),
                                      ShrexTheme.electricViolet.withOpacity(glowAnimation),
                                    ],
                                    stops: [0.0, 0.5, 1.0],
                                  ).createShader(bounds);
                                },
                                child: Text(
                                  'Shrex Focus',
                                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.5,
                                    fontSize: 32,
                                    shadows: [
                                      Shadow(
                                        color: ShrexTheme.cyberBlue.withOpacity(0.5),
                                        offset: const Offset(0, 4),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Professional Focus Sessions',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.white.withOpacity(0.8),
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // INTERACTIVE LOADING INDICATOR
                  AnimatedBuilder(
                    animation: Listenable.merge([fadeController, glowController]),
                    builder: (context, child) {
                      return Opacity(
                        opacity: fadeAnimation,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                ShrexTheme.cyberBlue.withOpacity(glowAnimation),
                                ShrexTheme.electricViolet.withOpacity(glowAnimation),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: ShrexTheme.cyberBlue.withOpacity(0.4 * glowAnimation),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                strokeWidth: 3,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}