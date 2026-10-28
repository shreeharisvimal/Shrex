import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../utils/theme.dart';

class AudioVisualizer extends StatefulWidget {
  final bool isActive;
  final Color? barColor;
  final int barCount;
  final double maxHeight;
  final Duration animationDuration;

  const AudioVisualizer({
    super.key,
    this.isActive = false,
    this.barColor,
    this.barCount = 8,
    this.maxHeight = 60.0,
    this.animationDuration = const Duration(milliseconds: 150),
  });

  @override
  State<AudioVisualizer> createState() => _AudioVisualizerState();
}

class _AudioVisualizerState extends State<AudioVisualizer>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<AnimationController> _barControllers;
  late List<Animation<double>> _barAnimations;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _barControllers = List.generate(
      widget.barCount,
      (index) => AnimationController(
        duration: Duration(
          milliseconds: 200 + (index * 50),
        ),
        vsync: this,
      ),
    );
    
    _barAnimations = _barControllers.map((controller) {
      return Tween<double>(
        begin: 0.1,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ));
    }).toList();
    
    if (widget.isActive) {
      _startAnimation();
    }
  }

  @override
  void didUpdateWidget(AudioVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive) {
      _startAnimation();
    } else {
      _stopAnimation();
    }
  }

  void _startAnimation() {
    _controller.repeat(reverse: true);
    for (final barController in _barControllers) {
      barController.repeat(reverse: true);
    }
  }

  void _stopAnimation() {
    _controller.stop();
    for (final barController in _barControllers) {
      barController.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    for (final barController in _barControllers) {
      barController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(widget.barCount, (index) {
            return AnimatedBuilder(
              animation: _barAnimations[index],
              builder: (context, child) {
                final height = widget.maxHeight * _barAnimations[index].value;
                final color = widget.barColor ?? ShrexTheme.accentColor;
                
                return Container(
                  width: 4,
                  height: height,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        color.withOpacity(0.3),
                        color,
                        color.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.5),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                );
              },
            );
          }),
        );
      },
    );
  }
}

class PulseRing extends StatefulWidget {
  final double size;
  final Color? color;
  final bool isActive;
  final Duration duration;

  const PulseRing({
    super.key,
    this.size = 200.0,
    this.color,
    this.isActive = false,
    this.duration = const Duration(seconds: 2),
  });

  @override
  State<PulseRing> createState() => _PulseRingState();
}

class _PulseRingState extends State<PulseRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    
    if (widget.isActive) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(PulseRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive) {
      _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: (widget.color ?? ShrexTheme.accentColor)
                      .withOpacity(0.6),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (widget.color ?? ShrexTheme.accentColor)
                        .withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class GlowEffect extends StatefulWidget {
  final Widget child;
  final Color? glowColor;
  final double glowRadius;
  final bool isActive;
  final Duration duration;

  const GlowEffect({
    super.key,
    required this.child,
    this.glowColor,
    this.glowRadius = 20.0,
    this.isActive = false,
    this.duration = const Duration(seconds: 2),
  });

  @override
  State<GlowEffect> createState() => _GlowEffectState();
}

class _GlowEffectState extends State<GlowEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    if (widget.isActive) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(GlowEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive) {
      _controller.repeat(reverse: true);
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.glowRadius),
            boxShadow: [
              BoxShadow(
                color: (widget.glowColor ?? ShrexTheme.accentColor)
                    .withOpacity(0.3 * _glowAnimation.value),
                blurRadius: widget.glowRadius * _glowAnimation.value,
                spreadRadius: 5 * _glowAnimation.value,
              ),
            ],
          ),
          child: widget.child,
        );
      },
    );
  }
}
