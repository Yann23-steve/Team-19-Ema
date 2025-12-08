import 'package:flutter/material.dart';
import 'page_login.dart';
import 'registrieren_page.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ---------------- LOGO ----------------
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: 70,
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

              // ---------------- ILLUSTRATION ----------------
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'lib/bilder/accueil1.png',
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              //---------------- TEXTE ----------------
              const SizedBox(height: 30),

              Center(
                child: Text('Deine Zukunft beginnt ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 33,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1D4ED8),
                  ),
                )
              ),
              Center(
                  child: Text('heute',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1D4ED8),
                    ),
                  )
              ),

              const SizedBox(height: 25),

              Center(
                  child: Text('Entdecke Jobmöglichkeiten, die zu deinen Interessen und Stärken passen – schnell, einfach und persönlich',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 16,
                      height: 1.4,
                      color: Colors.black,
                    ),
                  )
              ),

              const SizedBox(height: 60),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4B6BFB).withOpacity(0.3), // ombre bleue
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      width: 140,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                            Navigator.push(context,
                              MaterialPageRoute(builder: (context) => const PageLogin()),);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4B6BFB), // bleu
                          foregroundColor: Colors.white,           // texte blanc
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30), // arrondi comme l’image
                          ),
                          elevation: 0, // on enlève l’ombre native
                        ),
                        child: const Text(
                          "Login",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 20),

                  SizedBox(
                    width: 140,
                    height: 50,
                    child: ElevatedButton(onPressed: (){
                      Navigator.push(context,
                        MaterialPageRoute(builder: (context) => const PageRegistrieren()
                        ),
                      );
                    },
                        child: Text('Registrieren',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                    ),
                  ),


                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
