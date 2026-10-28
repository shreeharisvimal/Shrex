import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/theme.dart';
// Removed unused import

class UltraModernBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const UltraModernBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<UltraModernBottomNavBar> createState() => _UltraModernBottomNavBarState();
}

class _UltraModernBottomNavBarState extends State<UltraModernBottomNavBar>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late List<AnimationController> _itemControllers;
  late List<Animation<double>> _itemAnimations;

  final List<NavItem> _navItems = [
    NavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'Home',
      color: ShrexTheme.electricViolet,
    ),
    NavItem(
      icon: Icons.analytics_outlined,
      activeIcon: Icons.analytics,
      label: 'Analytics',
      color: ShrexTheme.cyberBlue,
    ),
    NavItem(
      icon: Icons.emoji_events_outlined,
      activeIcon: Icons.emoji_events,
      label: 'Rewards',
      color: ShrexTheme.neonMagenta,
    ),
    NavItem(
      icon: Icons.leaderboard_outlined,
      activeIcon: Icons.leaderboard,
      label: 'Leaderboard',
      color: ShrexTheme.rewardMode,
    ),
    NavItem(
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings,
      label: 'Settings',
      color: ShrexTheme.accentColor,
    ),
  ];

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: ShrexTheme.fastAnimation,
      vsync: this,
    );
    
    _itemControllers = List.generate(
      _navItems.length,
      (index) => AnimationController(
        duration: ShrexTheme.microAnimation,
        vsync: this,
      ),
    );
    
    _itemAnimations = _itemControllers.map((controller) {
      return Tween<double>(
        begin: 1.0,
        end: 1.2,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: ShrexTheme.smoothEase,
      ));
    }).toList();
  }

  @override
  void didUpdateWidget(UltraModernBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _itemControllers[oldWidget.currentIndex].reverse();
      _itemControllers[widget.currentIndex].forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    for (final controller in _itemControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Container(
      // Use dynamic padding instead of fixed height to avoid clipping
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.8),
            Colors.black.withOpacity(0.95),
          ],
        ),
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 8,
            // Ensure visibility above gesture/navigation bars
            bottom: 8 + (bottomInset > 0 ? bottomInset * 0.4 : 8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _navItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isActive = widget.currentIndex == index;
              
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  widget.onTap(index);
                },
                child: AnimatedBuilder(
                  animation: _itemAnimations[index],
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _itemAnimations[index].value,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          gradient: isActive
                              ? LinearGradient(
                                  colors: [
                                    item.color.withOpacity(0.2),
                                    item.color.withOpacity(0.1),
                                  ],
                                )
                              : null,
                          borderRadius: BorderRadius.circular(16),
                          border: isActive
                              ? Border.all(
                                  color: item.color.withOpacity(0.3),
                                  width: 1,
                                )
                              : null,
                          boxShadow: isActive
                              ? [
                                  BoxShadow(
                                    color: item.color.withOpacity(0.2),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isActive ? item.activeIcon : item.icon,
                              color: isActive ? item.color : Colors.white.withOpacity(0.6),
                              size: 20,
                            ),
                            const SizedBox(height: 4),
                            Flexible(
                              child: Text(
                                item.label,
                                style: TextStyle(
                                  color: isActive ? item.color : Colors.white.withOpacity(0.6),
                                  fontSize: 11,
                                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Color color;

  const NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.color,
  });
}
