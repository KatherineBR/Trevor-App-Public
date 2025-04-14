import 'package:flutter/material.dart';

class AppTheme {
  // Core colors
  static const Color primaryColor = Color(0xFF4B6FA6);
  static const Color secondaryColor = Color(0xFF7EAED5);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color textColor = Color(0xFF000000);

  // Text styles
  static const _baseTextStyle = TextStyle(color: textColor);
  static const TextStyle headingStyle = TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor);
  static const TextStyle subheadingStyle = TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: textColor);
  static const TextStyle bodyStyle = TextStyle(fontSize: 16, color: textColor);

  // Base shapes and dimensions
  static final _defaultBorderRadius = BorderRadius.circular(8);
  static final _cardBorderRadius = BorderRadius.circular(12);

  // Button styles
  static final ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: _defaultBorderRadius),
  );

  // Derived button styles
  static ButtonStyle extendButtonStyle({
    Size? minimumSize,
    TextStyle? textStyle,
    Color? backgroundColor,
    Color? foregroundColor,
    BorderRadius? borderRadius,
    EdgeInsetsGeometry? padding,
  }) {
    return primaryButtonStyle.copyWith(
      minimumSize: minimumSize != null ? WidgetStateProperty.all(minimumSize) : null,
      textStyle: textStyle != null ? WidgetStateProperty.all(textStyle) : null,
      backgroundColor: backgroundColor != null ? WidgetStateProperty.all(backgroundColor) : null,
      foregroundColor: foregroundColor != null ? WidgetStateProperty.all(foregroundColor) : null,
      padding: padding != null ? WidgetStateProperty.all(padding) : null,
      shape: borderRadius != null ? WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: borderRadius)) : null,
    );
  }

  // Specialized button styles using the extension method
  static final ButtonStyle largeButtonStyle = extendButtonStyle(
    minimumSize: Size(double.infinity, 60),
    textStyle: TextStyle(fontSize: 24),
  );

  static final ButtonStyle accentButtonStyle = extendButtonStyle(
    backgroundColor: secondaryColor,
  );

  static final ButtonStyle dangerButtonStyle = extendButtonStyle(
    backgroundColor: Colors.red[700],
  );

  // Get the complete theme data
  static ThemeData getTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        secondary: secondaryColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      primaryColor: primaryColor,
      textTheme: const TextTheme(
        displayLarge: headingStyle,
        displayMedium: subheadingStyle,
        bodyLarge: bodyStyle,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: _cardBorderRadius),
        color: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: primaryButtonStyle,
      ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: primaryColor.withAlpha(51),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}