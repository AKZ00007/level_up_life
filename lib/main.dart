//lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/user_data_provider.dart';
import 'screens/auth_gate.dart';
import 'utils/sound_manager.dart';

// --- Global Navigator Key ---
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await SoundManager.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, UserDataProvider>(
          create: (_) => UserDataProvider(null, navigatorKey), // Pass key here
          update: (_, authProvider, previousUserDataProvider) =>
              UserDataProvider(authProvider.user?.uid, navigatorKey)
                ..loadInitialDataIfNeeded(previousUserDataProvider),
        ),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey, // Assign key to MaterialApp
        title: 'Level Up Life (Prototype)',
        theme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: const Color(0xFF121212), // Existing dark background
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
            ),
          ),
          progressIndicatorTheme: const ProgressIndicatorThemeData(
            color: Colors.blueAccent,
          ),
          textTheme: const TextTheme( // Apply DEM-MOMono to default text styles
            bodyLarge: TextStyle(color: Colors.white, fontFamily: 'DEM-MOMono'),
            bodyMedium: TextStyle(color: Colors.white70, fontFamily: 'DEM-MOMono'),
            titleLarge: TextStyle(color: Colors.white, fontFamily: 'DEM-MOMono'),
            // You might want to define more styles here if needed
            displayLarge: TextStyle(fontFamily: 'DEM-MOMono'),
            displayMedium: TextStyle(fontFamily: 'DEM-MOMono'),
            displaySmall: TextStyle(fontFamily: 'DEM-MOMono'),
            headlineLarge: TextStyle(fontFamily: 'DEM-MOMono'),
            headlineMedium: TextStyle(fontFamily: 'DEM-MOMono'),
            headlineSmall: TextStyle(fontFamily: 'DEM-MOMono'),
            titleMedium: TextStyle(fontFamily: 'DEM-MOMono'),
            titleSmall: TextStyle(fontFamily: 'DEM-MOMono'),
            bodySmall: TextStyle(fontFamily: 'DEM-MOMono'),
            labelLarge: TextStyle(fontFamily: 'DEM-MOMono'),
            labelMedium: TextStyle(fontFamily: 'DEM-MOMono'),
            labelSmall: TextStyle(fontFamily: 'DEM-MOMono'),
          ).apply( // Ensure all text styles inherit the font if not specified
              bodyColor: Colors.white.withOpacity(0.9),
              displayColor: Colors.white,
              fontFamily: 'DEM-MOMono',
          ),
          fontFamily: 'DEM-MOMono', // <<< SET DEFAULT FONT FAMILY HERE
        ),
        home: const AuthGate(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}