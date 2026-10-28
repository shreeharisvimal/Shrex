import 'package:flutter/material.dart';

class ShrexTheme {
  // 🎨 ELEGANT PROFESSIONAL COLOR PALETTE
  static const Color primaryDark = Color(0xFF1a1a2e);
  static const Color secondaryDark = Color(0xFF16213e);
  static const Color accentDark = Color(0xFF0f3460);
  static const Color elegantGray = Color(0xFF2d3748);
  static const Color subtleGray = Color(0xFF4a5568);
  static const Color lightGray = Color(0xFF718096);
  static const Color elegantWhite = Color(0xFFf8fafc);
  static const Color softWhite = Color(0xFFe2e8f0);
  
  // 🎯 PROFESSIONAL ACCENT COLORS
  static const Color focusBlue = Color(0xFF6366f1);
  static const Color accentPurple = Color(0xFF8b5cf6);
  static const Color successGreen = Color(0xFF10b981);
  static const Color warningAmber = Color(0xFFf59e0b);
  static const Color errorRed = Color(0xFFef4444);
  
  // 🌈 CYBER THEME COLORS (for compatibility)
  static const Color electricViolet = Color(0xFF8B5CF6);
  static const Color cyberBlue = Color(0xFF6366F1);
  static const Color neonMagenta = Color(0xFFEC4899);
  static const Color deepSpaceGray = Color(0xFF1F2937);
  static const Color accentColor = focusBlue;
  static const Color primaryColor = focusBlue;
  static const Color secondaryColor = accentPurple;
  static const Color successColor = successGreen;
  static const Color warningColor = warningAmber;
  static const Color errorColor = errorRed;
  
  // 🎯 FOCUS MODE COLORS
  static const Color focusMode = Color(0xFF10B981);
  static const Color rewardMode = Color(0xFFF59E0B);
  static const Color relaxMode = Color(0xFF8B5CF6);
  
  // 🎨 ELEGANT GRADIENTS
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      primaryDark,
      secondaryDark,
      accentDark,
    ],
    stops: [0.0, 0.5, 1.0],
  );
  
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      focusBlue,
      accentPurple,
    ],
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      elegantGray,
      subtleGray,
    ],
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      focusBlue,
      accentPurple,
    ],
  );
  
  // 🌟 ELEGANT DECORATIONS
  static BoxDecoration elegantCardDecoration = BoxDecoration(
    gradient: cardGradient,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: elegantWhite.withOpacity(0.1),
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.2),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ],
  );
  
  static BoxDecoration primaryCardDecoration = BoxDecoration(
    gradient: primaryGradient,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: focusBlue.withOpacity(0.3),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ],
  );
  
  // 🎬 ANIMATION DURATIONS
  static const Duration microAnimation = Duration(milliseconds: 150);
  static const Duration fastAnimation = Duration(milliseconds: 300);
  static const Duration mediumAnimation = Duration(milliseconds: 500);
  static const Duration slowAnimation = Duration(milliseconds: 800);
  
  // 🎯 BORDER RADIUS
  static const double smallRadius = 8.0;
  static const double mediumRadius = 12.0;
  static const double largeRadius = 16.0;
  static const double extraLargeRadius = 24.0;
  
  // 📏 SPACING
  static const double microSpacing = 4.0;
  static const double smallSpacing = 8.0;
  static const double mediumSpacing = 16.0;
  static const double largeSpacing = 24.0;
  static const double extraLargeSpacing = 32.0;
  static const double megaSpacing = 48.0;
  
  // 🎨 EASING CURVES
  static const Curve smoothEase = Curves.easeInOutCubic;
  static const Curve springEase = Curves.elasticOut;
  
  // 🎭 PROFESSIONAL THEME DATA
  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: focusBlue,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: primaryDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: elegantWhite,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: elegantGray,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: focusBlue,
          foregroundColor: elegantWhite,
          elevation: 8,
          shadowColor: focusBlue.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: elegantWhite,
          fontSize: 48,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.0,
          height: 1.1,
        ),
        displayMedium: TextStyle(
          color: elegantWhite,
          fontSize: 36,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          height: 1.2,
        ),
        displaySmall: TextStyle(
          color: elegantWhite,
          fontSize: 28,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          height: 1.3,
        ),
        headlineLarge: TextStyle(
          color: elegantWhite,
          fontSize: 32,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
          height: 1.2,
        ),
        headlineMedium: TextStyle(
          color: elegantWhite,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.25,
          height: 1.3,
        ),
        headlineSmall: TextStyle(
          color: elegantWhite,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
          height: 1.4,
        ),
        titleLarge: TextStyle(
          color: elegantWhite,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
          height: 1.4,
        ),
        titleMedium: TextStyle(
          color: elegantWhite,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          height: 1.5,
        ),
        titleSmall: TextStyle(
          color: elegantWhite,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          height: 1.5,
        ),
        bodyLarge: TextStyle(
          color: softWhite,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.15,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          color: lightGray,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          color: lightGray,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.4,
          height: 1.4,
        ),
        labelLarge: TextStyle(
          color: elegantWhite,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          height: 1.4,
        ),
        labelMedium: TextStyle(
          color: elegantWhite,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          height: 1.3,
        ),
        labelSmall: TextStyle(
          color: lightGray,
          fontSize: 10,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          height: 1.3,
        ),
      ),
    );
  }
  
  // 🌟 LIGHT THEME (for compatibility)
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: focusBlue,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: elegantWhite,
    );
  }
  
  // 🎨 GRADIENT HELPERS
  static LinearGradient getGradientForState(String state) {
    switch (state.toLowerCase()) {
      case 'focus':
        return const LinearGradient(
          colors: [focusBlue, accentPurple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'reward':
        return const LinearGradient(
          colors: [successGreen, warningAmber],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'relax':
        return const LinearGradient(
          colors: [accentPurple, neonMagenta],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return primaryGradient;
    }
  }
  
  // 🎨 COLOR HELPERS
  static Color getColorForState(String state) {
    switch (state.toLowerCase()) {
      case 'focus':
        return focusBlue;
      case 'reward':
        return successGreen;
      case 'relax':
        return accentPurple;
      default:
        return accentColor;
    }
  }
}