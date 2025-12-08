import 'package:flutter/material.dart';

class AppTextStyles {
  AppTextStyles._();

  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 16,
  );

  static TextTheme get textTheme {
    return const TextTheme(
      headlineLarge: headlineLarge,
      bodyMedium: bodyMedium,
    );
  }
}
