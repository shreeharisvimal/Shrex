import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/theme.dart';
import 'animated_components.dart';

class FloatingStartButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final String text;
  final IconData icon;
  final bool isEnabled;
  final String? state; // 'focus', 'reward', 'relax'

  const FloatingStartButton({
    super.key,
    required this.onPressed,
    required this.text,
    required this.icon,
    this.isLoading = false,
    this.isEnabled = true,
    this.state,
  });

  @override
  State<FloatingStartButton> createState() => _FloatingStartButtonState();
}

class _FloatingStartButtonState extends State<FloatingStartButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _scaleController;
  late AnimationController _glowController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: ShrexTheme.fastAnimation,
      vsync: this,
    );
    
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: ShrexTheme.smoothEase,
    ));
    
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
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: ShrexTheme.smoothEase,
    ));
    
    if (widget.isEnabled && !widget.isLoading) {
      _pulseController.repeat(reverse: true);
      _glowController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(FloatingStartButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isEnabled && !widget.isLoading) {
      _pulseController.repeat(reverse: true);
      _glowController.repeat(reverse: true);
    } else {
      _pulseController.stop();
      _glowController.stop();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scaleController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  Gradient _getGradientForState() {
    if (widget.state != null) {
      return ShrexTheme.getGradientForState(widget.state!);
    }
    return widget.isEnabled && !widget.isLoading
        ? ShrexTheme.primaryGradient
        : LinearGradient(
            colors: [
              Colors.grey.withOpacity(0.3),
              Colors.grey.withOpacity(0.2),
            ],
          );
  }

  List<BoxShadow> _getShadowsForState() {
    if (!widget.isEnabled || widget.isLoading) return [];
    
    final stateColor = widget.state != null 
        ? ShrexTheme.getColorForState(widget.state!)
        : ShrexTheme.electricViolet;
    
    return [
      BoxShadow(
        color: stateColor.withOpacity(0.4),
        blurRadius: 25,
        offset: const Offset(0, 12),
      ),
      BoxShadow(
        color: stateColor.withOpacity(0.2),
        blurRadius: 50,
        offset: const Offset(0, 25),
      ),
      BoxShadow(
        color: stateColor.withOpacity(0.1),
        blurRadius: 75,
        offset: const Offset(0, 40),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.isEnabled && !widget.isLoading
          ? (_) {
              HapticFeedback.mediumImpact();
              _scaleController.forward();
            }
          : null,
      onTapUp: widget.isEnabled && !widget.isLoading
          ? (_) {
              _scaleController.reverse();
              widget.onPressed?.call();
            }
          : null,
      onTapCancel: widget.isEnabled && !widget.isLoading
          ? () => _scaleController.reverse()
          : null,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _pulseAnimation, 
          _scaleAnimation, 
          _glowAnimation,
          _rotationAnimation,
        ]),
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value,
              child: Container(
                width: double.infinity,
                height: 80,
                decoration: BoxDecoration(
                  gradient: _getGradientForState(),
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: _getShadowsForState(),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(40),
                    onTap: widget.isEnabled && !widget.isLoading
                        ? widget.onPressed
                        : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.isLoading) ...[
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                          ] else ...[
                            Transform.scale(
                              scale: _pulseAnimation.value,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  widget.icon,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                          ],
                          GlowText(
                            widget.text,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                            isGlowing: widget.isEnabled && !widget.isLoading,
                            glowColor: widget.state != null 
                                ? ShrexTheme.getColorForState(widget.state!)
                                : ShrexTheme.cyberBlue,
                          ),
                        ],
                      ),
                    ),
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