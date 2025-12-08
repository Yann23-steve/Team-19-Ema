//----------------  verifie si l'email est valable  ----------------
class Validators{
  static String? validateEmail(String email){
    email = email.trim();

    if (email.isEmpty){
      return 'Email is required';
    }
    if (!email.contains('@') || !email.contains('.')){
      return 'please enter a valid email address';
    }
    return null;
  }

  //------- compatibilité des mots de passes ----------------
static String? validatePasswords(String password, String confirmPassword){
    password = password.trim();
    confirmPassword = confirmPassword.trim();

    if(password.length < 6){
      return 'Password muss be at least 6 characters';
    }
    if(password != confirmPassword){
      return 'Passwords do not match';
    }

  return null;
}

//-------------- Postleitzahl ---------------
static String? validatePostleitzahl(String value){
    value = value.trim();
    if (value.isEmpty){
      return 'Postal code is required';
    }

    if(!RegExp(r'^[0-9]+$').hasMatch(value)){
      return 'Postal code muss contain only numbers';
    }
    if (value.length != 5){
      return 'Postal code must be exactly 5 numbers';
    }

  return null;


}
//------------- Numero maison---------------
static String? numeroMaison(String value){
    value = value.trim();

    if(!RegExp(r'^[0-9]+$').hasMatch(value)){
      return 'House number muss contain only numbers';
    }

    return null;
}

}