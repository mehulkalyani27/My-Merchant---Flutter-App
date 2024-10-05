// ignore_for_file: file_names, must_be_immutable

import 'package:mymerchant/Resources/constant.dart';
import 'package:mymerchant/Screens/HomeScreens/customerListScreen.dart';
import 'package:mymerchant/Screens/HomeScreens/homescreen.dart';
import 'package:mymerchant/Screens/HomeScreens/orderScreen.dart';
import 'package:mymerchant/Screens/HomeScreens/productListScreen.dart';
import 'package:mymerchant/Screens/HomeScreens/settingScreen.dart';
import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';


// ignore: camel_case_types
class bottomNavigation extends StatefulWidget {
  int selectedIndex;
  bottomNavigation({
    Key? key,
    required this.selectedIndex,
  }) : super(key: key);
  @override
  State<bottomNavigation> createState() => _bottomNavigationState();
}

// ignore: camel_case_types
class _bottomNavigationState extends State<bottomNavigation> {
  @override void initState(){
    super.initState();
    setState(() {
      selectedIndex = widget.selectedIndex;
    });
  }
  int selectedIndex = 0;
  final List<Widget> _pages = [ const HomeScreen(), const OrderScreen(), const CustomerScreen(), const ProductListScreen(), const SettingScreen()];
  @override
  Widget build(BuildContext context) {
    return WillPopScope( onWillPop: () async => false,
      child: Scaffold(
        body: _pages[selectedIndex],
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.only(left: 40.0,right: 40.0, bottom: 4.0),
          child: SalomonBottomBar(
            curve: Curves.linearToEaseOut,
            unselectedItemColor: appConstants.greyColor,
            currentIndex: selectedIndex,
            onTap: (i) => setState(() => selectedIndex = i),
            items: [
              SalomonBottomBarItem(
                icon: const Icon(Icons.home),
                title: Text("Home",style: TextStyle(fontFamily: appConstants.fontFamily),),
                selectedColor: appConstants.defaultColor,
              ),
              SalomonBottomBarItem(
                icon: const Icon(Icons.shopping_cart),
                title: Text("Invoice",style: TextStyle(fontFamily: appConstants.fontFamily),),
                selectedColor: appConstants.defaultColor,
              ),
              SalomonBottomBarItem(
                icon: const Icon(Icons.people),
                title: Text("Customers",style: TextStyle(fontFamily: appConstants.fontFamily),),
                selectedColor: appConstants.defaultColor,
              ),
              SalomonBottomBarItem(
                icon: SizedBox(
                  height: 28,
                  width: 28,
                    child: Image.asset("assets/images/productIcon.png",color: appConstants.greyColor),),
                title: Text("Products",style: TextStyle(fontFamily: appConstants.fontFamily),),
                selectedColor: appConstants.defaultColor,
              ),
              SalomonBottomBarItem(
                icon: const Icon(Icons.person),
                title: Text("Profile",style: TextStyle(fontFamily: appConstants.fontFamily),),
                selectedColor: appConstants.defaultColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}