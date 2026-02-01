import 'package:flutter/material.dart';
import 'app/app_theme.dart';
import 'features/auth/landing_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadSavedTheme();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeMode,
      builder: (context, mode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Job Suche',

          themeMode: mode,

          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: Colors.white,
            fontFamily: 'Roboto',
          ),

          darkTheme: ThemeData(
            brightness: Brightness.dark,
            useMaterial3: true,

            // Fond doux (gris, pas noir)
            scaffoldBackgroundColor: const Color(0xFF1E2430),

            // Cartes un peu plus claires que le fond
            cardColor: const Color(0xFF2A3140),

            // Séparateurs / bordures
            dividerColor: const Color(0xFF3A4356),

            // Icônes
            iconTheme: const IconThemeData(
              color: Color(0xFFE8ECF3),
            ),

            // Texte lisible (blanc cassé)
            textTheme: const TextTheme(
              titleLarge: TextStyle(color: Color(0xFFF5F7FB)),
              titleMedium: TextStyle(color: Color(0xFFF5F7FB)),
              titleSmall: TextStyle(color: Color(0xFFE8ECF3)),
              bodyLarge: TextStyle(color: Color(0xFFE8ECF3)),
              bodyMedium: TextStyle(color: Color(0xFFE8ECF3)),
              bodySmall: TextStyle(color: Color(0xFFB6C0D1)),
            ),
          ),



          home: const LandingPage(),
        );
      },
    );
  }
}
