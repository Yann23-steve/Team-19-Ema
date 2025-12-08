import 'package:flutter/material.dart';
import 'package:job_suche/features/auth/page_login.dart';
import 'package:job_suche/features/utils/fonction_verification.dart';

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
  String? emailError;
  String? passwordError;
  String? postleitzahlError;
  String? houseNummerError;

  @override
  void dispose() {

    //--------------- date et pays ---------------
    _birthdayController.dispose();
    _countryController.dispose();
       //--------------- Verification  email ---------------
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    //--------------- Verification  email ---------------
    _postleitzahlController.dispose();
    _houseNummerController.dispose();
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
                        width: 70, // Taille contrôlée
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
                      children: const [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "First Name",
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
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
                          child: const TextField(
                            decoration: InputDecoration(
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
                        onPressed: () {
                          validateInputs();
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
