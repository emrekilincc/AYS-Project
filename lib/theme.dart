import 'package:flutter/material.dart';

final ThemeData appTheme = ThemeData(
  primaryColor: const Color(0xFF2E7D32), // Ana yeşil
  scaffoldBackgroundColor: const Color(0xFFECF0F1), // Genel arka plan
  cardColor: Colors.white,
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF2E7D32),
    elevation: 0,
    titleTextStyle: TextStyle(
        fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFF2E7D32),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xFF2E7D32),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
  ),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: Color(0xFF263238)),
    titleMedium: TextStyle(
        fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF263238)),
  ),
);
