import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'constants.dart';
import 'providers/session_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GacadApp());
}

class GacadApp extends StatelessWidget {
  const GacadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SessionProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, preferences, _) {
          return ScreenUtilInit(
            designSize: const Size(390, 844),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (context, child) {
              return MaterialApp(
                title: 'Campus Connect',
                debugShowCheckedModeBanner: false,
                themeMode: preferences.themeMode,
                theme: _lightTheme,
                darkTheme: _darkTheme,
                home: child,
              );
            },
            child: const SplashScreen(),
          );
        },
      ),
    );
  }
}

final ThemeData _lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: facebookBlue,
    primary: facebookBlue,
    surface: Colors.white,
  ),
  scaffoldBackgroundColor: facebookBackground,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: Color(0xFF1C1E21),
    elevation: 0,
    scrolledUnderElevation: 1,
  ),
  cardTheme: const CardThemeData(
    color: Colors.white,
    margin: EdgeInsets.zero,
    elevation: 0,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFFF5F6F7),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFDADDE1)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFDADDE1)),
    ),
  ),
);

final ThemeData _darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF4599FF),
    brightness: Brightness.dark,
  ),
  scaffoldBackgroundColor: facebookDarkBackground,
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF242526),
    elevation: 0,
  ),
  cardTheme: const CardThemeData(
    color: Color(0xFF242526),
    margin: EdgeInsets.zero,
    elevation: 0,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF3A3B3C),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
  ),
);
