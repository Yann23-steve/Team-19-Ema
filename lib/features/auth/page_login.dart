import 'package:flutter/material.dart';
import 'registrieren_page.dart';

class PageLogin extends StatelessWidget {
  const PageLogin({super.key});

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
                      child: Text('Login here ' ,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1D4ED8),
                        ),
                      )
                  ),

                  const SizedBox(height: 10,),

                  Center(
                    child: Text("Welcome back you've \nbeen missed",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  //------------ Email ----------------

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    height: 55,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F6FA),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFF1D4ED8),
                        width: 1.5,
                      )
                    ),
                    child: Row(
                      children: [
                         Expanded(child: TextField(
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Email",
                            hintStyle: TextStyle(
                                color: Colors.grey,
                              fontSize: 16,
                            )
                          ),
                        )
                        ),
                        Icon(
                         Icons.person_outline,
                         color: Colors.grey,
                         size: 24,
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  //------------ Passwort ----------------

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    height: 55,
                    decoration: BoxDecoration(
                        color: const Color(0xFFF5F6FA),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFF1D4ED8),
                          width: 1.5,
                        )
                    ),
                    child: Row(
                      children: [
                        Expanded(child: TextField(
                          obscureText: true, //cacher le mot de passe quand on ecris
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Passwort",
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              )
                          ),
                        )
                        ),
                        Icon(
                          Icons.lock_clock_outlined,
                          color: Colors.grey,
                          size: 24,
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // Ici tu mettras la navigation vers la page "forgot password"
                        print("Forgot password clicked");
                      },
                      child: const Text(
                        "Forgot your password?",
                        style: TextStyle(
                          color: Color(0xFF1D4ED8), // bleu
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25,),

                  Container(
                    width: double.infinity, //prendre toute la largeur de la page
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
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () {
                          //ici on dois mettre ce qui dois nous emmener sur la page principale du site

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
                          "Sign In",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25,),

                  Align(
                    alignment: Alignment.center,
                    child: Text('Don\'t have an Account?',
                      style: TextStyle(
                          color: Colors.blueGrey,
                          fontWeight: FontWeight.bold,
                          fontSize: 14
                      ),
                    ),
                  ),

                  Align(
                    alignment: Alignment.center,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(context,
                          MaterialPageRoute(builder: (context) => const PageRegistrieren()),);

                      },
                      child: const Text(
                        "Create new Account",
                        style: TextStyle(
                          color: Color(0xFF4B6BFB), // bleu
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25,),

                  /*Align(
                    alignment: Alignment.center,
                    child: Text('Or continue with',
                      style: TextStyle(
                          color: Color(0xFF4B6BFB),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20,),*/


                ]
            ),
          ),
        )
    );
  }
}
