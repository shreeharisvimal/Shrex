import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../utils/theme.dart';

class ParticleField extends StatefulWidget {
  final int particleCount;
  final Color? particleColor;
  final double particleSize;
  final Duration animationDuration;
  final bool isActive;

  const ParticleField({
    super.key,
    this.particleCount = 20,
    this.particleColor,
    this.particleSize = 2.0,
    this.animationDuration = const Duration(seconds: 3),
    this.isActive = true,
  });

  @override
  State<ParticleField> createState() => _ParticleFieldState();
}

class _ParticleFieldState extends State<ParticleField>
    with TickerProviderStateMixin {
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
  void didUpdateWidget(ParticleField oldWidget) {
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
        vx: (random.nextDouble() - 0.5) * 0.02,
        vy: (random.nextDouble() - 0.5) * 0.02,
        size: widget.particleSize + random.nextDouble() * 2,
        opacity: random.nextDouble() * 0.8 + 0.2,
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
          painter: ParticlePainter(
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

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double animationValue;

  ParticlePainter({
    required this.particles,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      particle.update();
      
      final paint = Paint()
        ..color = particle.color.withOpacity(
          particle.opacity * (0.5 + 0.5 * math.sin(animationValue * 2 * math.pi)),
        )
        ..style = PaintingStyle.fill;
      
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

class AuroraBackground extends StatefulWidget {
  final Widget child;
  final bool isActive;
  final bool enableParticles;

  const AuroraBackground({
    super.key,
    required this.child,
    this.isActive = true,
    this.enableParticles = true,
  });

  @override
  State<AuroraBackground> createState() => _AuroraBackgroundState();
}

class _AuroraBackgroundState extends State<AuroraBackground>
    with TickerProviderStateMixin {
  late AnimationController _auroraController;
  late Animation<double> _auroraAnimation;

  @override
  void initState() {
    super.initState();
    
    _auroraController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );
    
    _auroraAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _auroraController,
      curve: Curves.easeInOut,
    ));
    
    if (widget.isActive) {
      _auroraController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(AuroraBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive) {
      _auroraController.repeat(reverse: true);
    } else {
      _auroraController.stop();
    }
  }

  @override
  void dispose() {
    _auroraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _auroraAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                ShrexTheme.electricViolet.withOpacity(0.1 * _auroraAnimation.value),
                ShrexTheme.cyberBlue.withOpacity(0.1 * _auroraAnimation.value),
                ShrexTheme.neonMagenta.withOpacity(0.1 * _auroraAnimation.value),
                ShrexTheme.deepSpaceGray,
              ],
              stops: [
                0.0,
                0.3 * _auroraAnimation.value,
                0.7 * _auroraAnimation.value,
                1.0,
              ],
            ),
          ),
          child: Stack(
            children: [
              widget.child,
              if (widget.isActive && widget.enableParticles)
                Positioned.fill(
                  child: IgnorePointer(
                    child: ParticleField(
                      particleCount: 8, // Reduced for better performance
                      particleColor: ShrexTheme.cyberBlue,
                      particleSize: 1.2,
                      isActive: true,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
