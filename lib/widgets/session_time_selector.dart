import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/theme.dart';
// Removed unused import

class SessionTimeSelector extends StatefulWidget {
  final int initialDuration;
  final ValueChanged<int> onDurationChanged;
  final bool isEnabled;

  const SessionTimeSelector({
    super.key,
    required this.initialDuration,
    required this.onDurationChanged,
    this.isEnabled = true,
  });

  @override
  State<SessionTimeSelector> createState() => _SessionTimeSelectorState();
}

class _SessionTimeSelectorState extends State<SessionTimeSelector>
    with TickerProviderStateMixin {
  late int _selectedDuration;
  late AnimationController _animationController;
  late AnimationController _glowController;
  late AnimationController _buttonAnimationController;
  // Removed unused animations
  late Animation<double> _buttonScaleAnimation;

  // Predefined duration options (in minutes)
  static const List<DurationOption> _durationOptions = [
    DurationOption(label: '5 min', minutes: 5, emoji: '⚡', color: ShrexTheme.electricViolet),
    DurationOption(label: '15 min', minutes: 15, emoji: '🚀', color: ShrexTheme.cyberBlue),
    DurationOption(label: '25 min', minutes: 25, emoji: '🍅', color: ShrexTheme.neonMagenta),
    DurationOption(label: '45 min', minutes: 45, emoji: '💪', color: ShrexTheme.focusMode),
    DurationOption(label: '1 hour', minutes: 60, emoji: '🎯', color: ShrexTheme.rewardMode),
    DurationOption(label: '2 hours', minutes: 120, emoji: '🔥', color: ShrexTheme.relaxMode),
    DurationOption(label: '3 hours', minutes: 180, emoji: '⚡', color: ShrexTheme.electricViolet),
    DurationOption(label: '5 hours', minutes: 300, emoji: '🏆', color: ShrexTheme.accentColor),
  ];

  @override
  void initState() {
    super.initState();
    _selectedDuration = widget.initialDuration;
    
    _animationController = AnimationController(
      duration: ShrexTheme.fastAnimation,
      vsync: this,
    );
    
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    // Removed creation of unused animations
    
    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _buttonAnimationController, curve: Curves.easeInOut),
    );
    
    _animationController.forward();
    _glowController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _glowController.dispose();
    _buttonAnimationController.dispose();
    super.dispose();
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) {
      return '${minutes}m';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '${hours}h';
      } else {
        return '${hours}h ${remainingMinutes}m';
      }
    }
  }

  DurationOption? _getClosestOption(int minutes) {
    DurationOption? closest;
    int minDifference = 999999; // Use a large number instead of infinity
    
    for (final option in _durationOptions) {
      final difference = (option.minutes - minutes).abs();
      if (difference < minDifference) {
        minDifference = difference;
        closest = option;
      }
    }
    
    return closest;
  }

  @override
  Widget build(BuildContext context) {
    final closestOption = _getClosestOption(_selectedDuration);
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > 600;
        
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(isTablet ? 24 : 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.15),
                Colors.white.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
            border: Border.all(
              color: ShrexTheme.accentColor.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: ShrexTheme.accentColor.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              // SLIDER SECTION - REVOLUTIONARY DESIGN
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '1m',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.8),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '5h',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.8),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 60,
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: ShrexTheme.accentColor,
                          inactiveTrackColor: Colors.white.withOpacity(0.3),
                          thumbColor: Colors.white,
                          overlayColor: ShrexTheme.accentColor.withOpacity(0.3),
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 20,
                            elevation: 15,
                          ),
                          trackHeight: 12,
                          trackShape: const RoundedRectSliderTrackShape(),
                        ),
                        child: Slider(
                          value: _selectedDuration.toDouble(),
                          min: 1,
                          max: 300,
                          divisions: 299,
                          onChanged: widget.isEnabled ? (value) {
                            setState(() {
                              _selectedDuration = value.round();
                            });
                            widget.onDurationChanged(_selectedDuration);
                            HapticFeedback.lightImpact();
                          } : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Quick Selection Buttons - ULTRA STUNNING & PERFECTLY ALIGNED
              Container(
                padding: EdgeInsets.all(isTablet ? 20 : 16),
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
                    color: ShrexTheme.accentColor.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Quick Select',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: isTablet ? 16 : 12),
                    
                    // STUNNING GRID LAYOUT - FIXED OVERFLOW
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final crossAxisCount = constraints.maxWidth > 520
                            ? 4
                            : constraints.maxWidth > 380
                                ? 3
                                : 2;
                        // Slightly taller tiles on smaller widths to avoid text clipping
                        final childAspectRatio = constraints.maxWidth > 520
                            ? 1.9
                            : constraints.maxWidth > 380
                                ? 2.1
                                : 2.4;
                        
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: isTablet ? 12 : 8,
                            mainAxisSpacing: isTablet ? 12 : 8,
                            childAspectRatio: childAspectRatio,
                          ),
                          itemCount: _durationOptions.length,
                          itemBuilder: (context, index) {
                            final option = _durationOptions[index];
                            final isSelected = _selectedDuration == option.minutes;
                            
                            return GestureDetector(
                              onTap: widget.isEnabled ? () {
                                setState(() {
                                  _selectedDuration = option.minutes;
                                });
                                widget.onDurationChanged(_selectedDuration);
                                HapticFeedback.mediumImpact();
                                
                                // Trigger button animation
                                _buttonAnimationController.forward().then((_) {
                                  _buttonAnimationController.reverse();
                                });
                              } : null,
                              child: AnimatedBuilder(
                                animation: _buttonScaleAnimation,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: isSelected ? _buttonScaleAnimation.value : 1.0,
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeInOutCubic,
                                      padding: EdgeInsets.all(isTablet ? 14 : 10),
                                      decoration: BoxDecoration(
                                        gradient: isSelected
                                            ? LinearGradient(
                                                colors: [
                                                  option.color.withOpacity(0.4),
                                                  option.color.withOpacity(0.2),
                                                  option.color.withOpacity(0.1),
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                stops: const [0.0, 0.5, 1.0],
                                              )
                                            : LinearGradient(
                                                colors: [
                                                  Colors.white.withOpacity(0.15),
                                                  Colors.white.withOpacity(0.08),
                                                  Colors.white.withOpacity(0.05),
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                stops: const [0.0, 0.5, 1.0],
                                              ),
                                        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                                        border: Border.all(
                                          color: isSelected
                                              ? option.color.withOpacity(0.6)
                                              : Colors.white.withOpacity(0.3),
                                          width: isSelected ? 2.5 : 1.5,
                                        ),
                                        boxShadow: isSelected ? [
                                          BoxShadow(
                                            color: option.color.withOpacity(0.4),
                                            blurRadius: 15,
                                            offset: const Offset(0, 5),
                                          ),
                                        ] : null,
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(isTablet ? 8 : 6),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // EMOJI CONTAINER
                                            Container(
                                              width: isTablet ? 22 : 18,
                                              height: isTablet ? 22 : 18,
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(isTablet ? 6 : 4),
                                                border: Border.all(
                                                  color: Colors.white.withOpacity(0.3),
                                                  width: 1,
                                                ),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  option.emoji,
                                                  style: TextStyle(
                                                    fontSize: isTablet ? 11 : 9,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: isTablet ? 6 : 4),
                                            
                                            // TEXT CONTAINER
                                            Flexible(
                                              child: Text(
                                                option.label,
                                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: isTablet ? 10 : 9,
                                                ),
                                                textAlign: TextAlign.center,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            
                                            // SELECTION INDICATOR
                                            if (isSelected) ...[
                                              SizedBox(height: isTablet ? 2 : 1),
                                              Container(
                                                width: isTablet ? 12 : 10,
                                                height: isTablet ? 12 : 10,
                                                decoration: BoxDecoration(
                                                  gradient: ShrexTheme.primaryGradient,
                                                  borderRadius: BorderRadius.circular(isTablet ? 6 : 5),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: ShrexTheme.cyberBlue.withOpacity(0.6),
                                                      blurRadius: 4,
                                                      offset: const Offset(0, 1),
                                                    ),
                                                  ],
                                                ),
                                                child: Icon(
                                                  Icons.check,
                                                  color: Colors.white,
                                                  size: isTablet ? 8 : 6,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class DurationOption {
  final String label;
  final int minutes;
  final String emoji;
  final Color color;

  const DurationOption({
    required this.label,
    required this.minutes,
    required this.emoji,
    required this.color,
  });
}