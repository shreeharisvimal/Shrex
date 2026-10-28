import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../utils/theme.dart';

class PerformanceOptimizedWidget extends StatefulWidget {
  final Widget child;
  final bool enableAnimations;
  final Duration animationDuration;

  const PerformanceOptimizedWidget({
    super.key,
    required this.child,
    this.enableAnimations = true,
    this.animationDuration = ShrexTheme.fastAnimation,
  });

  @override
  State<PerformanceOptimizedWidget> createState() => _PerformanceOptimizedWidgetState();
}

class _PerformanceOptimizedWidgetState extends State<PerformanceOptimizedWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    
    if (widget.enableAnimations) {
      _controller = AnimationController(
        duration: widget.animationDuration,
        vsync: this,
      );
      
      _animation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: ShrexTheme.smoothEase,
      ));
      
      // Use a microtask to avoid blocking the build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    if (widget.enableAnimations) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enableAnimations) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - _animation.value)),
            child: widget.child,
          ),
        );
      },
    );
  }
}

class OptimizedParticleField extends StatefulWidget {
  final int particleCount;
  final Color? particleColor;
  final double particleSize;
  final Duration animationDuration;
  final bool isActive;

  const OptimizedParticleField({
    super.key,
    this.particleCount = 10, // Reduced for better performance
    this.particleColor,
    this.particleSize = 1.5,
    this.animationDuration = const Duration(seconds: 4),
    this.isActive = true,
  });

  @override
  State<OptimizedParticleField> createState() => _OptimizedParticleFieldState();
}

class _OptimizedParticleFieldState extends State<OptimizedParticleField>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Particle> _particles;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _initializeParticles();
    
    if (widget.isActive) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(OptimizedParticleField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive) {
      _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  void _initializeParticles() {
    final random = math.Random();
    _particles = List.generate(widget.particleCount, (index) {
      return Particle(
        x: random.nextDouble(),
        y: random.nextDouble(),
        vx: (random.nextDouble() - 0.5) * 0.01, // Slower movement
        vy: (random.nextDouble() - 0.5) * 0.01,
        size: widget.particleSize + random.nextDouble(),
        opacity: random.nextDouble() * 0.6 + 0.2,
        color: widget.particleColor ?? ShrexTheme.cyberBlue,
      );
    });
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
        return CustomPaint(
          painter: OptimizedParticlePainter(
            particles: _particles,
            animationValue: _controller.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class Particle {
  double x;
  double y;
  double vx;
  double vy;
  double size;
  double opacity;
  Color color;

  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.opacity,
    required this.color,
  });

  void update() {
    x += vx;
    y += vy;
    
    // Wrap around screen
    if (x < 0) x = 1;
    if (x > 1) x = 0;
    if (y < 0) y = 1;
    if (y > 1) y = 0;
  }
}

class OptimizedParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double animationValue;

  OptimizedParticlePainter({
    required this.particles,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    for (final particle in particles) {
      particle.update();
      
      paint.color = particle.color.withOpacity(
        particle.opacity * (0.3 + 0.7 * math.sin(animationValue * 2 * math.pi)),
      );
      
      canvas.drawCircle(
        Offset(
          particle.x * size.width,
          particle.y * size.height,
        ),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
