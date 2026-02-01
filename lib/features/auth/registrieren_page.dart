import 'package:flutter/material.dart';
import 'package:job_suche/features/auth/page_login.dart';
import 'package:job_suche/features/home/home.dart';
import 'package:job_suche/features/utils/fonction_verification.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../navigation/navigation.dart';

class PageRegistrieren extends StatefulWidget {
  const PageRegistrieren({super.key});

  @override
  State<PageRegistrieren> createState() => _PageRegistrierenState();
}

class _PageRegistrierenState extends State<PageRegistrieren> {

  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final List<String> _countries = [
    'Germany', 'France', 'Switzerland', 'Austria', 'Belgium',
    'Netherlands', 'Italy', 'Spain', 'Portugal', 'United Kingdom',
    'Cameroon', 'Canada', 'United States', 'Brazil', 'India', 'Cameroon'
  ];
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _postleitzahlController = TextEditingController();
  final TextEditingController _houseNummerController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();

  String? firstNameError;
  String? lastNameError;
  String? emailError;
  String? passwordError;
  String? postleitzahlError;
  String? houseNummerError;
  String? streetError;

  @override
  void dispose() {

    //--------------- date et pays ---------------
    _birthdayController.dispose();
    _countryController.dispose();
       //--------------- Verification  email ---------------
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    //--------------- Verification  adresse ---------------
    _postleitzahlController.dispose();
    _houseNummerController.dispose();
    _streetController.dispose();
    //--------------- Verification  nom et prenom ---------------
    _firstNameController.dispose();
    _lastNameController.dispose();

    super.dispose();
  }

  Future<void> _pickBirthday() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 20),
      firstDate: DateTime(1950),
      lastDate: now,
    );

    if (picked != null) {
      setState(() {
        _birthdayController.text =
        '${picked.day.toString().padLeft(2, '0')}.'
            '${picked.month.toString().padLeft(2, '0')}.'
            '${picked.year}';
      });
    }
  }
  void validateInputs(){
    setState(() {
      emailError = Validators.validateEmail(_emailController.text);
      passwordError = Validators.validatePasswords(_passwordController.text, _confirmPasswordController.text,);
      postleitzahlError = Validators.validatePostleitzahl(_postleitzahlController.text,);
      houseNummerError = Validators.validatePostleitzahl(_houseNummerController.text,);

    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
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
                          padding: const EdgeInsets.all(10), // espace interne
                          child: Row(
                            children: [
                              Text('Job',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4B6BFB),
                                ),),
                              Text('Suche',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  Center(
                    child: Text(
                      'Create Account ',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1D4ED8),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  Center(
                    child: Text(
                      ' Create an account so you can \n explore all the existing jobs! ',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  //------------ Prenom -------------
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    height: 55,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F6FA),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFF1D4ED8),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _firstNameController,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: "First Name",
                              hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
                            ),
                          ),

                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),
                  //---------- Name -----------
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    height: 55,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F6FA),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFF1D4ED8),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _lastNameController,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: "Last Name",
                              hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
                            ),
                          ),

                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),

// -------- Street + Number (side-by-side) --------

                  Row(
                    children: [
                      // Street Name
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          height: 55,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F6FA),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Color(0xFF1D4ED8),
                              width: 1.5,
                            ),
                          ),
                          child: TextField(
                            controller: _streetController,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: "Street name",
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 15),

                      // Street Number
                      Expanded(
                        flex: 1,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          height: 55,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F6FA),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Color(0xFF1D4ED8),
                              width: 1.5,
                            ),
                          ),
                          child: TextField(
                            controller: _postleitzahlController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "No.",
                              hintStyle: const TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                              errorText: postleitzahlError,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

// -------- Postal Code --------

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    height: 55,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F6FA),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Color(0xFF1D4ED8),
                        width: 1.5,
                      ),
                    ),
                    child:  TextField(
                      controller: _houseNummerController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Postal code",
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                        errorText: houseNummerError,
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

//------------ Country -------------
                  Autocomplete<String>(
                    optionsBuilder: (TextEditingValue value) {
                      if (value.text.isEmpty) {
                        return const Iterable<String>.empty();
                      }
                      return _countries.where((country) =>
                          country.toLowerCase().startsWith(value.text.toLowerCase()));
                    },
                    fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                      _countryController.text = controller.text;
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        height: 55,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F6FA),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFF1D4ED8),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: controller,
                                focusNode: focusNode,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Country",
                                  hintStyle: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.flag_outlined,
                              color: Colors.grey,
                              size: 24,
                            ),
                          ],
                        ),
                      );
                    },
                    onSelected: (selection) {
                      _countryController.text = selection;
                    },
                  ),

                  const SizedBox(height: 25),

//------------ Birthday -------------
                  GestureDetector(
                    onTap: _pickBirthday,
                    child: AbsorbPointer(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        height: 55,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F6FA),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFF1D4ED8),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _birthdayController,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Birthday",
                                  hintStyle: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.calendar_today_outlined,
                              color: Colors.grey,
                              size: 22,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),


                  const SizedBox(height: 25),

                  //------------ Email -------------
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    height: 55,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F6FA),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFF1D4ED8),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Email",
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                              errorText: emailError,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.person_outline,
                          color: Colors.grey,
                          size: 24,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  //------------ Password -------------
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    height: 55,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F6FA),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFF1D4ED8),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Passwort",
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                              errorText: passwordError,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.lock_clock_outlined,
                          color: Colors.grey,
                          size: 24,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  //------------ Confirm Password -------------
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    height: 55,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F6FA),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFF1D4ED8),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _confirmPasswordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Confirm Password ",
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                              errorText: passwordError,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.lock_clock_outlined,
                          color: Colors.grey,
                          size: 24,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 35),


                  //----------- Sign Up_Button -----------
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
                        onPressed: () async {
                          validateInputs();

                          if (emailError != null ||
                              passwordError != null ||
                              postleitzahlError != null ||
                              houseNummerError != null) {
                            return;
                          }

                          try {
                            // 1) Créer le compte Auth
                            final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                              email: _emailController.text.trim(),
                              password: _passwordController.text.trim(),
                            );

                            final uid = cred.user!.uid;

                            // 2) Enregistrer TOUTES les infos dans Firestore (users/{uid})
                            await FirebaseFirestore.instance.collection('users').doc(uid).set({
                              'uid': uid,
                              'email': _emailController.text.trim(),

                              'firstName': _firstNameController.text.trim(),
                              'lastName': _lastNameController.text.trim(),

                              'street': _streetController.text.trim(),
                              'streetNumber': _postleitzahlController.text.trim(), // chez toi c’est "No."
                              'postalCode': _houseNummerController.text.trim(),    // chez toi c’est "Postal code"

                              'country': _countryController.text.trim(),
                              'birthday': _birthdayController.text.trim(),

                              'createdAt': FieldValue.serverTimestamp(),
                            });

                            // 3) Aller vers l'app
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const Navigation()),
                            );
                          } on FirebaseAuthException catch (e) {
                            String msg = "Registration failed";

                            if (e.code == 'email-already-in-use') {
                              msg = "This email is already used. Please login.";
                            } else if (e.code == 'invalid-email') {
                              msg = "Invalid email address.";
                            } else if (e.code == 'weak-password') {
                              msg = "Password is too weak.";
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(msg)),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("An error occurred. Please try again.")),
                            );
                          }
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
                          "Sign Up",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15,),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already have an Account ?',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      ),
                      TextButton(onPressed: (){
                       Navigator.push(context, MaterialPageRoute(builder: (context) => const PageLogin()),);
                      },
                          child: const Text('Sign In',
                            style: TextStyle(
                              color: Color(0xFF1D4ED8),
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                      ),
                    ],
                  )

                ]
            ),
          ),
        ),
      ),
    );
  }
}
