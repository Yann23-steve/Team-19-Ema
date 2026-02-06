import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'app/app_theme.dart';
import 'features/auth/landing_page.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );


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

            scaffoldBackgroundColor: const Color(0xFF1E2430),
            cardColor: const Color(0xFF2A3140),
            dividerColor: const Color(0xFF3A4356),

            iconTheme: const IconThemeData(
              color: Color(0xFFE8ECF3),
            ),

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
