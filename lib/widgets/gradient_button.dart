import 'package:flutter/material.dart';
import '../utils/theme.dart';

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Gradient? gradient;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final TextStyle? textStyle;
  final bool isLoading;

  const GradientButton({
    super.key,
    required this.text,
    this.onPressed,
    this.gradient,
    this.padding,
    this.borderRadius,
    this.textStyle,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonGradient = gradient ?? ShrexTheme.primaryGradient;
    final buttonPadding = padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
    final buttonBorderRadius = borderRadius ?? 12.0;

    return Container(
      decoration: BoxDecoration(
        gradient: onPressed != null ? buttonGradient : null,
        color: onPressed == null ? theme.colorScheme.surfaceVariant : null,
        borderRadius: BorderRadius.circular(buttonBorderRadius),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(buttonBorderRadius),
          child: Container(
            padding: buttonPadding,
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          onPressed != null ? Colors.white : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  : Text(
                      text,
                      style: textStyle ??
                          TextStyle(
                            color: onPressed != null ? Colors.white : theme.colorScheme.onSurfaceVariant,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
