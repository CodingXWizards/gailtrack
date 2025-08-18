import 'package:flutter/material.dart';
import 'package:gailtrack/constants/colors.dart';

class AppTheme {
  // Light Theme
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColorsLight.primary,
    focusColor: AppColorsDark.textPrimary,

    dividerColor: const Color.fromARGB(255, 255, 255, 255),
    fontFamily: "Inter",

    scaffoldBackgroundColor: AppColorsLight.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColorsLight.surface,
      titleTextStyle: TextStyle(color: AppColorsLight.textPrimary),
    ),
    colorScheme: const ColorScheme.light(
      primary: AppColorsLight.primary,
      secondary: AppColorsLight.secondary,
      surface: AppColorsLight.surface,
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: AppColorsLight.surface,
      contentTextStyle: TextStyle(color: AppColorsLight.background),
    ),
    //* Elevated Button Styling
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor:
            const WidgetStatePropertyAll<Color>(AppColorsLight.primary),
        foregroundColor: const WidgetStatePropertyAll<Color>(Colors.white),
        padding: const WidgetStatePropertyAll<EdgeInsets>(
            EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
        shape: WidgetStatePropertyAll<OutlinedBorder>(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    ),
    textTheme: const TextTheme(
      //* Text Styles for Large Headings
      titleLarge: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w900,
        color: Color.fromARGB(255, 49, 49, 49),
      ),
      titleMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Color.fromARGB(255, 44, 44, 44),
      ),
      titleSmall: TextStyle(
        fontSize: 20,
        color: Color.fromARGB(255, 50, 50, 50),
      ),

      //* Text Style for Normal Headings
      labelLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColorsLight.textPrimary,
      ),
      labelMedium: TextStyle(
        fontSize: 14,
        color: AppColorsLight.textPrimary,
      ),
      labelSmall: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColorsLight.textSecondary,
      ),

      //* Text Style for Descriptions
      bodyLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColorsLight.textPrimary,
      ),
      bodyMedium: TextStyle(
        fontSize: 16,
        color: Color.fromARGB(255, 51, 51, 51),
      ),
      bodySmall: TextStyle(
        fontSize: 14,
        color: AppColorsLight.textPrimaryMuted,
      ),
    ),
  );

  // Dark Theme
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColorsDark.primary,
    dividerColor: AppColorsDark.border,
    scaffoldBackgroundColor: AppColorsDark.background,
    focusColor: AppColorsDark.textPrimary,
    fontFamily: "Inter",
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColorsDark.primary,
      titleTextStyle: TextStyle(color: AppColorsDark.textPrimary),
    ),
    colorScheme: const ColorScheme.dark(
      primary: AppColorsDark.primary,
      secondary: AppColorsDark.secondary,
      surface: AppColorsDark.surface,
    ),

    //* Elevated Button Styling
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor:
            const WidgetStatePropertyAll<Color>(AppColorsDark.surface),
        foregroundColor:
            const WidgetStatePropertyAll<Color>(AppColorsDark.textPrimary),
        padding: const WidgetStatePropertyAll<EdgeInsets>(
            EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
        shape: WidgetStatePropertyAll<OutlinedBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    ),
    textTheme: const TextTheme(
      //* Text Styles for Large Headings
      titleLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w900,
        color: AppColorsDark.textPrimary,
      ),
      titleMedium: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: AppColorsDark.textPrimary,
      ),
      titleSmall: TextStyle(
        fontSize: 18,
        color: AppColorsDark.textPrimary,
      ),

      //* Text Style for Normal Headings
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColorsDark.textPrimary,
      ),
      labelMedium: TextStyle(
        fontSize: 14,
        color: AppColorsDark.textPrimary,
      ),
      labelSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColorsDark.textSecondary,
      ),

      //* Text Style for Descriptions
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColorsDark.textPrimary,
      ),
      bodyMedium: TextStyle(
        fontSize: 16,
        color: AppColorsDark.textPrimaryMuted,
      ),
      bodySmall: TextStyle(
        fontSize: 14,
        color: AppColorsDark.textPrimaryMuted,
      ),
    ),
  );
}
