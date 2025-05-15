import 'package:flutter/material.dart';
import 'package:voice_access_app/pages/voice_access_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

var kColorScheme = ColorScheme.fromSeed(
  seedColor: const Color.fromARGB(79, 37, 103, 255),
);
var kDarkColorScheme = ColorScheme.fromSeed(
  brightness: Brightness.dark,
  seedColor: const Color.fromARGB(255, 77, 155, 207),
);
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
    // print("API_BASE_URL: ${dotenv.env['API_BASE_URL']}");
  } catch (e) {
    // print('dotenv load error: $e');
  }
  runApp(App());
}

class App extends StatelessWidget {
  const App({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
              backgroundColor: kColorScheme.onSecondaryContainer,
              foregroundColor: kColorScheme.secondaryContainer)),
      themeMode: ThemeMode.system,
      home: VoiceAccessPage(),
    );
  }
}
