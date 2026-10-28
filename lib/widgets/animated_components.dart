import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/theme.dart';

class AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Gradient? gradient;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final bool enableHapticFeedback;
  final Duration animationDuration;

  const AnimatedButton({
    super.key,
    required this.child,
    this.onPressed,
    this.isLoading = false,
    this.gradient,
    this.padding,
    this.borderRadius,
    this.enableHapticFeedback = true,
    this.animationDuration = ShrexTheme.microAnimation,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _glowController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    
    _scaleController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: ShrexTheme.smoothEase,
    ));
    
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: ShrexTheme.smoothEase,
    ));
    
    if (widget.onPressed != null && !widget.isLoading) {
      _glowController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(AnimatedButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.onPressed != null && !widget.isLoading) {
      _glowController.repeat(reverse: true);
    } else {
      _glowController.stop();
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onPressed != null && !widget.isLoading
          ? (_) {
              if (widget.enableHapticFeedback) {
                HapticFeedback.lightImpact();
              }
              _scaleController.forward();
            }
          : null,
      onTapUp: widget.onPressed != null && !widget.isLoading
          ? (_) {
              _scaleController.reverse();
              widget.onPressed?.call();
            }
          : null,
      onTapCancel: widget.onPressed != null && !widget.isLoading
          ? () => _scaleController.reverse()
          : null,
      child: AnimatedBuilder(
        animation: Listenable.merge([_scaleAnimation, _glowAnimation]),
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                gradient: widget.gradient ?? ShrexTheme.primaryGradient,
                borderRadius: BorderRadius.circular(
                  widget.borderRadius ?? ShrexTheme.mediumRadius,
                ),
                boxShadow: widget.onPressed != null && !widget.isLoading
                    ? [
                        BoxShadow(
                          color: ShrexTheme.electricViolet.withOpacity(
                            0.3 * _glowAnimation.value,
                          ),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                        BoxShadow(
                          color: ShrexTheme.cyberBlue.withOpacity(
                            0.2 * _glowAnimation.value,
                          ),
                          blurRadius: 40,
                          offset: const Offset(0, 20),
                        ),
                      ]
                    : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(
                    widget.borderRadius ?? ShrexTheme.mediumRadius,
                  ),
                  onTap: widget.onPressed,
                  child: Container(
                    padding: widget.padding ?? const EdgeInsets.symmetric(
                      horizontal: ShrexTheme.largeSpacing,
                      vertical: ShrexTheme.mediumSpacing,
                    ),
                    child: widget.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : widget.child,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class PulseCard extends StatefulWidget {
  final Widget child;
  final bool isActive;
  final Color? pulseColor;
  final Duration pulseDuration;

  const PulseCard({
    super.key,
    required this.child,
    this.isActive = false,
    this.pulseColor,
    this.pulseDuration = const Duration(milliseconds: 1500),
  });

  @override
  State<PulseCard> createState() => _PulseCardState();
}

class _PulseCardState extends State<PulseCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: widget.pulseDuration,
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: ShrexTheme.smoothEase,
    ));
    
    if (widget.isActive) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(PulseCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive) {
      _pulseController.repeat(reverse: true);
    } else {
      _pulseController.stop();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(ShrexTheme.largeRadius),
              border: Border.all(
                color: widget.isActive
                    ? (widget.pulseColor ?? ShrexTheme.accentColor)
                    : Colors.white.withOpacity(0.2),
                width: widget.isActive ? 2 : 1,
              ),
              boxShadow: widget.isActive
                  ? [
                      BoxShadow(
                        color: (widget.pulseColor ?? ShrexTheme.accentColor)
                            .withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
            ),
            child: widget.child,
          ),
        );
      },
    );
  }
}

class GlowText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Color? glowColor;
  final double glowRadius;
  final bool isGlowing;
  final IconData? icon;

  const GlowText(
    this.text, {
    super.key,
    this.style,
    this.glowColor,
    this.glowRadius = 10.0,
    this.isGlowing = false,
    this.icon,
  });

  @override
  State<GlowText> createState() => _GlowTextState();
}

class _GlowTextState extends State<GlowText>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: ShrexTheme.smoothEase,
    ));
    
    if (widget.isGlowing) {
      _glowController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(GlowText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isGlowing) {
      _glowController.repeat(reverse: true);
    } else {
      _glowController.stop();
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                widget.style?.color ?? Colors.white,
                (widget.glowColor ?? ShrexTheme.accentColor)
                    .withOpacity(_glowAnimation.value),
              ],
            ).createShader(bounds);
          },
          child: Text(
            widget.text,
            style: widget.style?.copyWith(
              shadows: widget.isGlowing
                  ? [
                      Shadow(
                        color: (widget.glowColor ?? ShrexTheme.accentColor)
                            .withOpacity(0.5 * _glowAnimation.value),
                        blurRadius: widget.glowRadius,
                      ),
                    ]
                  : null,
            ),
          ),
        );
      },
    );
  }
}
