import 'package:flutter/material.dart';

class AppColors {
  static const Color darkBlue = Color(0xFF1a237e);
  static const Color mediumBlue = Color(0xFF0d47a1);
  static const Color lightBlue = Color(0xFF42a5f5);
  static const Color amber = Color(0xFFff6f00);
  static const Color success = Color(0xFF2e7d32);
  static const Color danger = Color(0xFFc62828);
  static const Color background = Color(0xFFf5f6fa);
  static const Color cardDark = Color(0xFF1e1e2f);
  static const Color backgroundDark = Color(0xFF121212);
}

class AppConstants {
  static const String appName = 'AH Transport Gujranwala';
  static const String dbName = 'ah_transport.db';
  static const int dbVersion = 1;

  static const List<String> vehicleTypes = [
    'Truck',
    'Trailer',
    'Tanker',
    'Container',
    'Mazda',
    'Other',
  ];

  static const List<String> ownershipTypes = ['Owned', 'Partnership'];

  static const List<String> salaryTypes = ['Daily', 'Weekly', 'Monthly'];

  static const List<String> tripStatuses = [
    'Active',
    'Completed',
    'Cancelled',
  ];

  static const List<String> expenseCategories = [
    'Fuel',
    'Toll Tax',
    'Loading/Unloading',
    'Driver Salary',
    'Food',
    'Repair',
    'Other',
  ];
}

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.darkBlue,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.mediumBlue,
        primary: AppColors.darkBlue,
        secondary: AppColors.amber,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.amber,
        foregroundColor: Colors.white,
      ),
      useMaterial3: true,
    );
  }

  static ThemeData dark() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.darkBlue,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.mediumBlue,
        primary: AppColors.lightBlue,
        secondary: AppColors.amber,
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0d0d1a),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        elevation: 3,
        color: AppColors.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.amber,
        foregroundColor: Colors.white,
      ),
      useMaterial3: true,
    );
  }
}
