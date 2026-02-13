import 'package:flutter/material.dart';

const _gold = Color(0xFFD4AF37);
const _black = Color(0xFF000000);
const _white = Color(0xFFFFFFFF);

/// Dark theme: black background with gold accents.
final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: _black,
  colorScheme: ColorScheme.dark(
    primary: _gold,
    onPrimary: _black,
    secondary: _gold.withValues(alpha: 0.8),
    onSecondary: _black,
    surface: _black,
    onSurface: _white.withValues(alpha: 0.6),
    error: Colors.redAccent,
    onError: _white,
  ),
  iconTheme: IconThemeData(
    color: _white.withValues(alpha: 0.7)
  )
);

/// Light theme: white background with gold accents.
final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  scaffoldBackgroundColor: _white,
  colorScheme: ColorScheme.light(
    primary: _gold,
    onPrimary: _black,
    secondary: _gold.withValues(alpha: 0.9),
    onSecondary: _white,
    surface: _white,
    onSurface: _black,
    error: Colors.redAccent,
    onError: _white,
  ),
  iconTheme: IconThemeData(
    color: _black.withValues(alpha: 0.7)
  )
);
