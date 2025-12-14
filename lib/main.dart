import 'package:flutter/material.dart'; // importe Flutter (les widgets)

// on importe notre page que l'on a créée dans features/auth
import 'features/auth/landing_page.dart';

// fonction main : point de départ de l'application
void main() {
  runApp(const MyApp()); // lance le widget racine MyApp
}

// MyApp : widget principal de l'application
class MyApp extends StatelessWidget {
  const MyApp({super.key}); // constructeur avec une "key" optionnelle

  @override
  Widget build(BuildContext context) {
    // build : décrit ce qu'on affiche à l'écran
    return MaterialApp(
      debugShowCheckedModeBanner: false, // enlève le petit bandeau "debug"
      title: 'Job Suche', // titre de l'application
      theme: ThemeData(
        // ici on met juste quelques réglages simples
        scaffoldBackgroundColor: Colors.white, // fond blanc pour les pages
        fontFamily: 'Roboto', // facultatif, si tu as ajouté cette police
      ),
      home:

      const LandingPage(), // première page affichée = notre LandingPage
    );
  }
}
