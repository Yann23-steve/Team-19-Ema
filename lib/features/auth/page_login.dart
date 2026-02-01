import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'registrieren_page.dart';
import '../navigation/navigation.dart';
import 'passwort_vergessen.dart';

class PageLogin extends StatefulWidget {
  const PageLogin({super.key});

  @override
  State<PageLogin> createState() => _PageLoginState();
}

class _PageLoginState extends State<PageLogin> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    try {
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final uid = cred.user!.uid;
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (!doc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No account found. Please create an account.")),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PageRegistrieren()),
        );
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Navigation()),
      );
    } on FirebaseAuthException catch (e) {
      String msg = "Email or password incorrect.";

      if (e.code == 'user-not-found') {
        msg = "No account found. Please create an account.";
      } else if (e.code == 'wrong-password') {
        msg = "Wrong password.";
      } else if (e.code == 'invalid-email') {
        msg = "Invalid email address.";
      } else if (e.code == 'invalid-credential') {
        msg = "No account found or wrong password. Please create an account.";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final fieldBg = isDark ? const Color(0xFF2A3140) : const Color(0xFFF5F6FA);
    final fieldText = isDark ? const Color(0xFFE8ECF3) : Colors.black87;
    final hintText = isDark ? const Color(0xFFB6C0D1) : Colors.grey;
    final iconColor = isDark ? const Color(0xFFB6C0D1) : Colors.grey;

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
                    height: 70,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          const Text(
                            'Job',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4B6BFB),
                            ),
                          ),
                          Text(
                            'Suche',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: isDark ? const Color(0xFFE8ECF3) : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              const Center(
                child: Text(
                  'Login here ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1D4ED8),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Center(
                child: Text(
                  "Welcome back you've \nbeen missed",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFFE8ECF3) : Colors.black87,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // Email
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                height: 55,
                decoration: BoxDecoration(
                  color: fieldBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF1D4ED8), width: 1.5),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _emailController,
                        style: TextStyle(color: fieldText),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Email",
                          hintStyle: TextStyle(color: hintText, fontSize: 16),
                        ),
                      ),
                    ),
                    Icon(Icons.person_outline, color: iconColor, size: 24),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // Password
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                height: 55,
                decoration: BoxDecoration(
                  color: fieldBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF1D4ED8), width: 1.5),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _passwordController,
                        obscureText: true,
                        style: TextStyle(color: fieldText),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Passwort",
                          hintStyle: TextStyle(color: hintText, fontSize: 16),
                        ),
                      ),
                    ),
                    Icon(Icons.lock_clock_outlined, color: iconColor, size: 24),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PasswortVergessen()),
                    );
                  },
                  child: const Text(
                    "Forgot your password?",
                    style: TextStyle(
                      color: Color(0xFF1D4ED8),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // Sign In Button
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4B6BFB).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: SizedBox(
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _signIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4B6BFB),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
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

              const SizedBox(height: 25),

              Align(
                alignment: Alignment.center,
                child: Text(
                  'Don\'t have an Account?',
                  style: TextStyle(
                    color: isDark ? const Color(0xFFB6C0D1) : Colors.blueGrey,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),

              Align(
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PageRegistrieren()),
                    );
                  },
                  child: const Text(
                    "Create new Account",
                    style: TextStyle(
                      color: Color(0xFF4B6BFB),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
