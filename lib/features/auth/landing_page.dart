// TODO Implement this library.
import 'package:flutter/material.dart'; // on a besoin des widgets Material

// On crée un widget pour notre page d'accueil.
// StatelessWidget = la page ne change pas toute seule (pas d'état).
class LandingPage extends StatelessWidget {
  const LandingPage({super.key}); // constructeur basique

  @override
  Widget build(BuildContext context) {
    // build : ici on décrit tous les widgets qui composent la page
    return Scaffold(
      // Scaffold = structure de base d'une page (fond, appbar, body, etc.)
      body: SafeArea(
        // SafeArea = évite que le contenu soit sous la barre de statut (heure, batterie)
        child: Padding(
          // Padding = marge intérieure autour de la page
          padding: const EdgeInsets.symmetric(
            horizontal: 24, // 24 pixels à gauche et à droite
            vertical: 16, // 16 pixels en haut et en bas
          ),
          child: Column(
            // Column = on place les éléments les uns sous les autres
            crossAxisAlignment: CrossAxisAlignment.start, // aligne à gauche
            children: [
              // --------- LIGNE DU HAUT : placeholder pour le logo ----------
              Row(
                // Row = widgets alignés à l'horizontale
                mainAxisAlignment: MainAxisAlignment.end, // tout à droite
                children: [
                  Container(
                    // Container = boîte rectangulaire (couleur, bord, padding)
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ), // marge interne du rectangle
                    decoration: BoxDecoration(
                      color: const Color(0xFF4B6BFB), // fond bleu
                      borderRadius: BorderRadius.circular(16), // bords arrondis
                      boxShadow: [
                        // petite ombre pour ressembler au Figma
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'lib/bilder/logo.png',
                      width: 40,   // largeur du logo
                      height: 40,  // hauteur du logo
                    ),

                  ),
                ],
              ),

              const SizedBox(height: 16), // espace vertical de 16 px

              // --------- GRANDE ILLUSTRATION ---------
              Container(
                height: 260, // hauteur fixe
                width: double.infinity, // prend toute la largeur
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6), // gris clair
                  borderRadius: BorderRadius.circular(24), // bords arrondis
                  border: Border.all(
                    color: const Color(0xFFE5E7EB), // bordure très légère
                  ),
                ),
                child: Center(
                  // Center = centre son enfant
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.asset(
                      'lib/bilder/accueil1.png',
                      fit: BoxFit.cover,   // l’image remplit tout le bloc
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24), // espace sous l'illustration

              // --------- TITRE PRINCIPAL ---------
              Center(
                child: const Text(
                  'Finde hier\nDeinen Traumjob',
                  style: TextStyle(
                    fontSize: 40, // grande taille
                    fontWeight: FontWeight.w700, // très gras
                    color: Color(0xFF1D4ED8), // bleu un peu foncé
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // --------- TEXTE EXPLICATIF ---------
              Center(
                child: const Text(
                  'Erkunden Sie alle bestehenden Jobrollen basierend \n'
                      'auf Ihren Interessen und studieren Sie das Hauptfach',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.2, // espace entre les lignes
                    color: Color(0xFF6B7280), // gris
                  ),
                ),
              ),

              const Spacer(), // pousse ce qui vient après vers le bas de l'écran

              // --------- BOUTONS EN BAS ---------
              Row(
                children: [
                  // BOUTON LOGIN (bleu)
                  Expanded(
                    // Expanded = le bouton prend le maximum de largeur disponible
                    child: Container(
                      // Container juste pour ajouter une ombre plus jolie
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4B6BFB).withOpacity(0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          // plus tard : navigation vers la page de login
                          // pour l'instant on laisse vide
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4B6BFB), // bleu
                          foregroundColor: Colors.white, // texte blanc
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ), // hauteur du bouton
                          elevation: 0, // l'ombre vient du Container
                        ),
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 32), // espace entre Login et Register

                  // TEXTE REGISTER (cliquable plus tard)
                  TextButton(
                    onPressed: () {
                      // plus tard : navigation vers la page d'inscription
                    },
                    child: const Text(
                      'Register',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24), // petit espace en bas
            ],
          ),
        ),
      ),
    );
  }
}
