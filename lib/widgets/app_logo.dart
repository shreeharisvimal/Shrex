import 'package:flutter/material.dart';
import '../utils/theme.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final Color? color;
  final bool isGlowing;

  const AppLogo({
    super.key,
    this.size = 50,
    this.showText = true,
    this.color,
    this.isGlowing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo Icon
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: ShrexTheme.primaryGradient,
            borderRadius: BorderRadius.circular(size * 0.3),
            boxShadow: isGlowing ? [
              BoxShadow(
                color: ShrexTheme.electricViolet.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ] : [
              BoxShadow(
                color: ShrexTheme.electricViolet.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Icon(
            Icons.psychology_outlined,
            color: color ?? Colors.white,
            size: size * 0.6,
          ),
        ),
        
        if (showText) ...[
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Shrex',
                style: TextStyle(
                  color: color ?? Colors.white,
                  fontSize: size * 0.4,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              Text(
                'Focus',
                style: TextStyle(
                  color: (color ?? Colors.white).withOpacity(0.7),
                  fontSize: size * 0.25,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class AppLogoIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final bool isGlowing;

  const AppLogoIcon({
    super.key,
    this.size = 50,
    this.color,
    this.isGlowing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: ShrexTheme.primaryGradient,
        borderRadius: BorderRadius.circular(size * 0.3),
        boxShadow: isGlowing ? [
          BoxShadow(
            color: ShrexTheme.electricViolet.withOpacity(0.5),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ] : [
          BoxShadow(
            color: ShrexTheme.electricViolet.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Icon(
        Icons.psychology_outlined,
        color: color ?? Colors.white,
        size: size * 0.6,
      ),
    );
  }
}
