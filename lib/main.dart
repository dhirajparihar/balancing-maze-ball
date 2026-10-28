/// Climbing Ball Maze — "BALANCING MAZE"
/// Complete production-grade mobile arcade balancing puzzle game.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/providers/game_providers.dart';
import 'core/services/game_service.dart';
import 'features/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to vertical portrait orientation matching the arcade reference design
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Immersive edge-to-edge system chrome
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  final gameService = GameService();

  runApp(
    ProviderScope(
      overrides: [
        gameServiceProvider.overrideWithValue(gameService),
      ],
      child: BalancingMazeApp(gameService: gameService),
    ),
  );
}

class BalancingMazeApp extends StatelessWidget {
  final GameService gameService;

  const BalancingMazeApp({super.key, required this.gameService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Balance Runner',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF061019),
        primaryColor: const Color(0xFF00E5FF),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00E5FF),
          secondary: Color(0xFFFFB74D),
          surface: Color(0xFF0A1826),
        ),
        fontFamily: 'sans-serif',
      ),
      home: SplashScreen(gameService: gameService),
    );
  }
}
