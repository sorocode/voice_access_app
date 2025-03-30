import 'package:flutter/material.dart';
import 'package:voice_access_app/voice_access.dart';

var kColorScheme = ColorScheme.fromSeed(
  seedColor: const Color.fromARGB(255, 159, 222, 204),
);
var kDarkColorScheme = ColorScheme.fromSeed(
  brightness: Brightness.dark,
  seedColor: const Color.fromARGB(255, 5, 77, 125),
);
void main() {
  runApp(MaterialApp(
    darkTheme: ThemeData.dark().copyWith(
      colorScheme: kDarkColorScheme,
      // cardTheme: const CardTheme().copyWith(
      //   color: kDarkColorScheme.secondaryContainer,
      //   margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      // ),
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
              backgroundColor: kDarkColorScheme.primaryContainer,
              foregroundColor: kDarkColorScheme.onPrimaryContainer)),
    ),
    theme: ThemeData().copyWith(
        colorScheme: kColorScheme,
        // cardTheme: const CardTheme().copyWith(
        //   color: kColorScheme.secondaryContainer,
        //   margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        // ),
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
          backgroundColor: kColorScheme.primaryContainer,
        )),
        textTheme: ThemeData().textTheme.copyWith(
              titleLarge: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: kColorScheme.onSecondaryContainer,
                  fontSize: 16),
            ),
        appBarTheme: const AppBarTheme().copyWith(
            backgroundColor: kColorScheme.onPrimaryContainer,
            foregroundColor: kColorScheme.primaryContainer)),
    themeMode: ThemeMode.system,
    home: VoiceAccess(),
  ));
}
