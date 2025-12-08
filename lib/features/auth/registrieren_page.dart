import 'package:flutter/material.dart';

class PageRegistrieren extends StatelessWidget {
  const PageRegistrieren({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
        padding: const EdgeInsets.all(20),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 70,   // Taille contrôlée
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFF9CA3FF),
              shape: BoxShape.circle, // cercle parfait
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(10), // espace interne
              child: Image.asset(
                'lib/bilder/logo2.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),

      const SizedBox(height: 30),

      Center(
          child: Text('Konto erstellen ',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1D4ED8),
            ),
          )
      ),

      const SizedBox(height: 30),

      Center(
          child: Text(' Erstellt dein Konto, \n um alle jobs möglichkeiten zu sehen! ',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontStyle: FontStyle.italic,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          )
      ),

      const SizedBox(height: 30),

      SizedBox(
        width: 140,
        height: 50,
            child: Text('Name',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            )
        ),
    ]
      ),
      ),
    )
    );
  }
}
