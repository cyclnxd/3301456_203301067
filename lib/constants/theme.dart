import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constants/project_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme => ThemeData.dark().copyWith(
        visualDensity: VisualDensity.standard,
        scaffoldBackgroundColor: ProjectColors.black,
        appBarTheme: const AppBarTheme().copyWith(
          color: ProjectColors.black,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          elevation: 1,
          shadowColor: ProjectColors.white,
        ),
        bottomAppBarTheme: const BottomAppBarTheme().copyWith(
          color: ProjectColors.black,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData().copyWith(
          backgroundColor: ProjectColors.black,
          selectedItemColor: ProjectColors.white,
          unselectedItemColor: ProjectColors.white,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
        snackBarTheme: const SnackBarThemeData().copyWith(
          elevation: 0,
          backgroundColor: ProjectColors.white,
          actionTextColor: ProjectColors.black,
        ),
        primaryColor: ProjectColors.black,
        colorScheme: const ColorScheme.dark().copyWith(
          primary: ProjectColors.white,
          secondary: ProjectColors.black,
        ),
        textTheme: GoogleFonts.ralewayTextTheme().copyWith().apply(
              displayColor: ProjectColors.white,
              bodyColor: ProjectColors.white,
            ),
        floatingActionButtonTheme:
            const FloatingActionButtonThemeData().copyWith(
          backgroundColor: ProjectColors.white,
          foregroundColor: ProjectColors.black,
          elevation: 2.0,
        ),
      );

  static ThemeData get lightTheme => ThemeData.light().copyWith(
        visualDensity: VisualDensity.standard,
        scaffoldBackgroundColor: ProjectColors.white,
        appBarTheme: const AppBarTheme().copyWith(
          foregroundColor: ProjectColors.black,
          color: ProjectColors.white,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          elevation: 1,
          shadowColor: ProjectColors.black,
        ),
        bottomAppBarTheme: const BottomAppBarTheme().copyWith(
          color: ProjectColors.white,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData().copyWith(
          backgroundColor: ProjectColors.white,
          selectedItemColor: ProjectColors.black,
          unselectedItemColor: ProjectColors.black,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
        snackBarTheme: const SnackBarThemeData().copyWith(
          elevation: 0,
          backgroundColor: ProjectColors.black,
          actionTextColor: ProjectColors.white,
        ),
        primaryColor: ProjectColors.white,
        colorScheme: const ColorScheme.light().copyWith(
          primary: ProjectColors.black,
          secondary: ProjectColors.white,
        ),
        textTheme: GoogleFonts.ralewayTextTheme().copyWith().apply(
              displayColor: ProjectColors.black,
              bodyColor: ProjectColors.black,
              decorationColor: ProjectColors.black,
            ),
        floatingActionButtonTheme:
            const FloatingActionButtonThemeData().copyWith(
          backgroundColor: ProjectColors.black,
          foregroundColor: ProjectColors.white,
          elevation: 2.0,
        ),
      );
}
