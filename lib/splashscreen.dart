// ignore_for_file: camel_case_types, library_private_types_in_public_api, use_build_context_synchronously

import 'dart:core';
import 'package:flutter/material.dart';
import 'package:mymerchant/Screens/HomeScreens/bottomNavigation.dart';




class splash_screen extends StatefulWidget {
  const splash_screen({super.key});

  @override
  _splash_screenState createState() => _splash_screenState();
}

class _splash_screenState extends State<splash_screen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 3000), () => checkUserIsLogged());
  }

  void checkUserIsLogged() async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => bottomNavigation(selectedIndex: 0)));
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // if (prefs.getBool("isLogin")==false && prefs.getInt("empID")!=0) {
    //   Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
    // }
    // else{
    //   Navigator.push(context, MaterialPageRoute(builder: (context) => const bottomNavigation()));
    // }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope( onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body:
        Padding(
          padding: const EdgeInsets.only(top: 60.0),
          child: Center(
            child: SizedBox(
                width: double.infinity,
                height: MediaQuery.of(context).size.height*0.6,
                child: Image.asset("assets/images/966650.jpg")
            ),
          ),
        ),
      ),
    );
  }
}