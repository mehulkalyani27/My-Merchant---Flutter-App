// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:mymerchant/Resources/constant.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import '../HomeScreens/bottomNavigation.dart';

// ignore: camel_case_types
class changePasswordScreen extends StatefulWidget {
  const changePasswordScreen({Key? key,}) : super(key: key);
  @override
  State<changePasswordScreen> createState() => _changePasswordScreenState();
}

// ignore: camel_case_types
class _changePasswordScreenState extends State<changePasswordScreen> {
  bool visible1 = true;
  bool visible2 = true;
  bool visible3 = true;
  TextEditingController oldPasswordTE=TextEditingController();
  TextEditingController newPasswordTE =TextEditingController();
  TextEditingController confirmPasswordTE=TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  GlobalKey<FormState> formKey = GlobalKey();
  bool background=false;

  String? validateConfirmPassword(String? text) {
    if (text == null || text.isEmpty) {
      return "Please Enter Confirm password";
    } else if (text != newPasswordTE.text) {
      return "Both passwords are not same";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_outlined), onPressed: (){
          Navigator. of(context). pop();
        },),
        backgroundColor: appConstants.defaultColor,
        title: Text('Change Password',style: TextStyle(color: appConstants.whiteColor, fontFamily: appConstants.fontFamily, fontWeight: FontWeight.w600))),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                const SizedBox(height: 30,),
                Container(
                  padding: const EdgeInsets.all(10),
                  child: TextFormField(
                    style: TextStyle(color: appConstants.defaultColor,fontFamily: appConstants.fontFamily),
                    controller: oldPasswordTE,
                    obscureText: visible1,
                    validator: appConstants.validateOldPassword,
                    decoration:  InputDecoration(
                      labelStyle: TextStyle(color: appConstants.defaultColor,fontFamily: appConstants.fontFamily),
                      labelText: 'Old Password',
                      prefixIcon: Icon(Icons.lock,size: 28,color: appConstants.defaultColor),
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: appConstants.defaultColor),borderRadius: BorderRadius.circular(14)),
                      focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide(color: appConstants.errorColor),borderRadius: BorderRadius.circular(14)),
                      errorBorder: OutlineInputBorder(borderSide: BorderSide(color: appConstants.errorColor),borderRadius: BorderRadius.circular(14)),
                      enabledBorder:OutlineInputBorder(borderSide: BorderSide(color: appConstants.defaultColor),borderRadius: BorderRadius.circular(14)),
                      suffixIcon: IconButton(onPressed: (){
                        setState(() {
                          if(visible1){
                            visible1 = false;
                          }else{
                            visible1 = true;
                          }
                        });},
                          icon: Icon(visible1? Icons.visibility : Icons.visibility_off, color: appConstants.defaultColor)),
                    ),
                  ),
                ),
                const SizedBox(height: 10,),
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: TextFormField(
                    style: TextStyle(color: appConstants.defaultColor,fontFamily: appConstants.fontFamily),
                    controller: newPasswordTE,
                    obscureText: visible2,
                    validator: appConstants.validateNewPassword,
                    decoration: InputDecoration(
                      labelStyle: TextStyle(color: appConstants.defaultColor,fontFamily: appConstants.fontFamily),
                      labelText: 'New Password',
                      prefixIcon: Icon(Icons.lock,size: 28,color: appConstants.defaultColor),
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: appConstants.defaultColor),borderRadius: BorderRadius.circular(14)),
                      focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide(color: appConstants.errorColor),borderRadius: BorderRadius.circular(14)),
                      errorBorder: OutlineInputBorder(borderSide: BorderSide(color: appConstants.errorColor),borderRadius: BorderRadius.circular(14)),
                      enabledBorder:OutlineInputBorder(borderSide: BorderSide(color: appConstants.defaultColor),borderRadius: BorderRadius.circular(14)),
                      suffixIcon: IconButton(onPressed: (){
                        setState(() {
                          if(visible2){
                            visible2 = false;
                          }else{
                            visible2 = true;
                          }
                        });},
                          icon: Icon(visible2? Icons.visibility : Icons.visibility_off, color: appConstants.defaultColor)),
                    ),
                  ),
                ),
                const SizedBox(height: 20,),
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: TextFormField(
                    //initialValue: emailController.text,
                    style: TextStyle(color: appConstants.defaultColor,fontFamily: appConstants.fontFamily),
                    controller: confirmPasswordTE,
                    obscureText: visible3,
                    validator: validateConfirmPassword,
                    decoration: InputDecoration(
                      labelStyle: TextStyle(color: appConstants.defaultColor,fontFamily: appConstants.fontFamily),
                      labelText: 'Confirm Password',
                      prefixIcon: Icon(Icons.lock,size: 28,color: appConstants.defaultColor),
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: appConstants.defaultColor),borderRadius: BorderRadius.circular(14)),
                      focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide(color: appConstants.errorColor),borderRadius: BorderRadius.circular(14)),
                      errorBorder: OutlineInputBorder(borderSide: BorderSide(color: appConstants.errorColor),borderRadius: BorderRadius.circular(14)),
                      enabledBorder:OutlineInputBorder(borderSide: BorderSide(color: appConstants.defaultColor),borderRadius: BorderRadius.circular(14)),
                      suffixIcon: IconButton(onPressed: (){
                        setState(() {
                          if(visible3){
                            visible3 = false;
                          }else{
                            visible3 = true;
                          }
                        });},
                          icon: Icon(visible3? Icons.visibility : Icons.visibility_off, color: appConstants.defaultColor)),
                    ),
                  ),
                ),
                const SizedBox(height: 50,),
                Container(
                    height: 50,
                    width: 200,
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    decoration: BoxDecoration(color: appConstants.defaultColor, borderRadius: BorderRadius.circular(10)),
                    child: MaterialButton(
                      child: const Text('Change Password',style: TextStyle(color: Colors.white,fontWeight: FontWeight.w500,fontSize: 17),),
                      onPressed: () async{
                        if (formKey.currentState!.validate()) {
                          String message = 'test';
                          // ChangePasswordAPI changePasswordAPI = ChangePasswordAPI();
                          // String message = await changePasswordAPI.changePassword(oldPasswordTE.text, newPasswordTE.text);
                          if(message=='success'){

                            // ignore: use_build_context_synchronously
                            showTopSnackBar(
                              context,
                              const CustomSnackBar.success(
                                message: 'Password updated Successfully!',
                              ),
                            );
                            // ignore: use_build_context_synchronously
                            Navigator.of(context).push(MaterialPageRoute(builder: (context) => bottomNavigation(selectedIndex: 0)));
                          }
                          else{
                            // ignore: use_build_context_synchronously
                            showTopSnackBar(
                             context,
                              CustomSnackBar.error(
                                message: message.toString(),
                              ),
                            );
                          }
                        }
                      },
                    )
                )
              ],
            ),
          ),
        ),), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}