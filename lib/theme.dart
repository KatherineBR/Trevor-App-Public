import 'package:flutter/material.dart';

// Create a Theme definition class to hold theme properties
class ThemeDefinition {
  final Color primaryColor;
  final Color secondaryColor;
  final Color backgroundColor;
  final Color textColor;
  final List<Color> buttonColors;

  const ThemeDefinition({
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundColor,
    required this.textColor,
    required this.buttonColors,
  });
}

class AppTheme {
  // Define font family constants
  static const String primaryFontFamily = 'Manrope';
  static const String secondaryFontFamily = 'Caveat';

  // Define themes
  static const ThemeDefinition defaultTheme = ThemeDefinition(
    primaryColor: Color(0xFF4B6FA6), // Blue
    secondaryColor: Color(0xFF7EAED5), // Light Blue
    backgroundColor: Color(0xFFF5F5F5), // Light Gray
    textColor: Color(0xFF000000), // Black
    buttonColors: [Color(0xFF4B6FA6)], // Single color for all buttons
  );

  static const ThemeDefinition alternativeTheme = ThemeDefinition(
    primaryColor: Color(0xFFFF5A3D),    // Tangerine
    secondaryColor: Color(0xFF7155FF),  // Indigo
    backgroundColor: Color(0xFFF5F5F5), // Light Gray
    textColor: Color(0xFF333333),       // Dark Gray
    buttonColors: [
      Color(0xFFFF5A3D),    // Tangerine
      Color(0xFF101066),    // Indigo
      Color(0xFF005E67),    // Blue Green
      Color(0xFF40009A),    // Purple
    ],
  );

  // Base shapes and dimensions
  static final _defaultBorderRadius = BorderRadius.circular(8);
  static final _cardBorderRadius = BorderRadius.circular(12);

  // Dynamic button style based on the current theme
  static ButtonStyle getLargeButtonStyle(BuildContext context, {int colorIndex = 0}) {
    final theme = Theme.of(context);
    final isDefaultTheme = theme.primaryColor == defaultTheme.primaryColor;
    final currentTheme = isDefaultTheme ? defaultTheme : alternativeTheme;

    // For default theme, always use primary color (index 0)
    // For alternative theme, use different colors based on index
    final buttonColor = isDefaultTheme
        ? currentTheme.buttonColors[0]  // Always use the first color for default theme
        : currentTheme.buttonColors[colorIndex % currentTheme.buttonColors.length];

    return ElevatedButton.styleFrom(
      backgroundColor: buttonColor,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: _defaultBorderRadius),
      minimumSize: Size(double.infinity, 60),
      textStyle: TextStyle(
        fontSize: 20,
        fontFamily: primaryFontFamily,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  static Color getButtonColor(BuildContext context, {int index = 0}) {
    final isDefaultTheme = Theme.of(context).primaryColor == defaultTheme.primaryColor;
    final currentTheme = isDefaultTheme ? defaultTheme : alternativeTheme;

    return isDefaultTheme
        ? currentTheme.primaryColor  // Always use primary color for default theme
        : currentTheme.buttonColors[index % currentTheme.buttonColors.length];
  }

  // For backward compatibility
  static final ButtonStyle largeButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: defaultTheme.primaryColor,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: _defaultBorderRadius),
    minimumSize: Size(double.infinity, 60),
    textStyle: TextStyle(
      fontSize: 24,
      fontFamily: primaryFontFamily,
      fontWeight: FontWeight.bold,
    ),
  );

  static final ButtonStyle accentButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: defaultTheme.secondaryColor,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: _defaultBorderRadius),
  );

  static final ButtonStyle dangerButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: Colors.red[700],
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: _defaultBorderRadius),
  );

  // Generate text styles based on theme
  static TextStyle headingStyle(ThemeDefinition theme) =>
      TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: theme.textColor,
        fontFamily: primaryFontFamily,
      );

  static TextStyle subheadingStyle(ThemeDefinition theme) =>
      TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: theme.textColor,
        fontFamily: primaryFontFamily,
      );

  static TextStyle bodyStyle(ThemeDefinition theme) =>
      TextStyle(
        fontSize: 16,
        color: theme.textColor,
        fontFamily: primaryFontFamily,
      );

  static TextStyle accentStyle(ThemeDefinition theme) =>
      TextStyle(
        fontSize: 18,
        color: theme.secondaryColor,
        fontFamily: secondaryFontFamily,
      );

  // Get complete theme data from a theme definition
  static ThemeData getThemeFromDefinition(ThemeDefinition theme) {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: theme.primaryColor,
        secondary: theme.secondaryColor,
      ),
      scaffoldBackgroundColor: theme.backgroundColor,
      primaryColor: theme.primaryColor,
      fontFamily: primaryFontFamily,  // Set default font family for entire app
      textTheme: TextTheme(
        displayLarge: headingStyle(theme),
        displayMedium: subheadingStyle(theme),
        bodyLarge: bodyStyle(theme),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: _cardBorderRadius),
        color: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: _defaultBorderRadius),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: theme.primaryColor.withAlpha(51),
        labelTextStyle: WidgetStateProperty.all(
          TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            fontFamily: primaryFontFamily,
          ),
        ),
      ),
    );
  }

  static InputDecoration getFormInputDecoration(BuildContext context, String labelText, {int colorIndex = 2}) {
  final color = getButtonColor(context, index: colorIndex);
  return InputDecoration(
    labelText: labelText,
    labelStyle: TextStyle(
      color: color,
      fontSize: 16,
      fontWeight: FontWeight.w500,
    ),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(
        color: color,
        width: 2.0,
      ),
    ),
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(
        color: color,
        width: 1.0,
      ),
    ),
  );
}

  // Public API methods
  static ThemeData getTheme() {
    return getThemeFromDefinition(defaultTheme);
  }

  static ThemeData getAlternativeTheme() {
    return getThemeFromDefinition(alternativeTheme);
  }
}