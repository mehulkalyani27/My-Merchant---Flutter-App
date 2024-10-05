import 'dart:ui';

// ignore: camel_case_types
class appConstants {
  static Color cirightBlue = const Color(0xFF003087);
  static Color tealColor = const Color(0xFF008080);
  static Color defaultColor = const Color(0xFF003087);
  static Color errorColor = const Color(0xFFF44336);
  static Color whiteColor = const Color(0xFFFFFFFF);
  static Color greyColor = const Color(0xFF9E9E9E);
  static Color blackColor = const Color(0xFF000000);
  static Color indexColor = const Color(0xFF964B00);
  static Color lightGreyColor = const Color(0xFFc6c6c6);
  static Color circularProgressColor = const Color(0xFF0066FF);
  static Color circularBackgroundColor = const Color(0xFF96C0FF);
  static String fontFamily = 'Avenir';
  static String appTitle = 'My Merchant';


  static String? validateProductName(String? text){
    Pattern whitespacePattern = r'^\s';
    RegExp regex = RegExp(whitespacePattern as String);
    if (text == null || text.isEmpty) {
      return "Please Enter Product Name";
    }
    else if(regex.hasMatch(text)){
      return "Whitespace not allowed";
    }
    return null;
  }

  static String? validateProductNameNon(String? text){
    Pattern whitespacePattern = r'^\s';
    RegExp regex = RegExp(whitespacePattern as String);
    if (text == null || text.isEmpty) {
      return "";
    }
    else if(regex.hasMatch(text)){
      return "";
    }
    return null;
  }

  static String? validateInvoiceNumber(String? text){
    Pattern whitespacePattern = r'^\s';
    RegExp regex = RegExp(whitespacePattern as String);
    if (text == null || text.isEmpty) {
      return "Please Enter Invoice Number";
    }
    else if(regex.hasMatch(text)){
      return "Whitespace not allowed";
    }
    return null;
  }

  static String? validateNumericNotEmptyDouble(String? text){
    RegExp regex = RegExp(r"^\d*\.?\d*$|^-\d*\.?\d*$");
    // RegExp regex = RegExp(numericPattern as String);
    if (text!.isEmpty || regex.hasMatch(text)==false) {
      return '';
    }
    return null;
  }

  static String? validateNumericNotEmptyInteger(String? text){
    Pattern numericPattern = r'[0-9]';

    RegExp regex = RegExp(numericPattern as String);
    if (text!.isEmpty || regex.hasMatch(text)==false ) {
      return '';
    }
    else if(int.parse(text) < 0){
      return '';
    }
    return null;
  }


  static String? validateUsername(String? text){
    Pattern whitespacePattern = r'^\s';
    RegExp regex = RegExp(whitespacePattern as String);
    if (text == null || text.isEmpty) {
      return "Please Enter Username";
    }
    else if(regex.hasMatch(text)){
      return "Whitespace not allowed";
    }
    return null;
  }

  static String? validatePhoneNumber(String? text) {
    String pattern =  r'(^(?:[+91])?[0-9]{10,13}$)';
    RegExp regExp = RegExp(pattern);
    if (text == null || text.isEmpty) {
      return "Please Enter Phone Number";
    } else if (!regExp.hasMatch(text)) {
      return "Invalid Phone Number";
    }
    return null;
  }

  static String? validateName(String? text){
    Pattern whitespacePattern = r'^\s';
    RegExp regex = RegExp(whitespacePattern as String);
    if (text == null || text.isEmpty) {
      return "Please Enter Name";
    }
    else if(regex.hasMatch(text)){
      return "Whitespace not allowed";
    }
    return null;
  }

  static String? validateEmail(String? text){
    Pattern whitespacePattern = r'^\s';
    RegExp email = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    RegExp regex = RegExp(whitespacePattern as String);
    if (text == null || text.isEmpty) {
      return "Please Enter Email";
    }
    else if(regex.hasMatch(text)){
      return "Whitespace not allowed";
    }
    else if(email.hasMatch(text)){
      return null;
    }
    else{
      return "Invalid Email";
    }
  }

  static String? validateNewPassword(String? text) {
    Pattern whitespacePattern = r'^\s';
    RegExp whiteSpace = RegExp(whitespacePattern as String);
    RegExp regex = RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#$&*~]).{8,}$');
    if (text == null || text.isEmpty) {
      return 'Please Enter password';
    }else if(whiteSpace.hasMatch(text)){
      return "Whitespace not allowed";
    }
    else {
      if (!regex.hasMatch(text)) {
        return 'Create strong password';
      } else {
        return null;
      }
    }
  }


  static String? validateOldPassword(String? text) {
    if (text == null || text.isEmpty) {
      return "Enter Current password";
    }
    return null;
  }

  static String? validatePassword(String? text) {
    Pattern whitespacePattern = r'^\s';
    RegExp whiteSpace = RegExp(whitespacePattern as String);
    if (text == null || text.isEmpty) {
      return "Please Enter Password";
    }else if(whiteSpace.hasMatch(text)){
      return "Whitespace not allowed";
    }
    return null;
  }


}
