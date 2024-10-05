// ignore_for_file: file_names

import 'package:mymerchant/Database/databaseController.dart';
import 'package:mymerchant/Model/Customer.dart';
import 'package:mymerchant/Resources/constant.dart';
import 'package:mymerchant/Screens/UI/CustomerUI.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CustomerScreen extends StatefulWidget {
  const CustomerScreen({Key? key}) : super(key: key);
  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {

  List<Customer> customerList = [];
  bool isLoading = true;
  //Loading Screen
  Widget _buildLoadingScreen() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 7,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(5.0),
            child: Card(
              margin: const EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 0),
              elevation: 1.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: const SizedBox(height: 74),
            ),
          );
        },
      ),
    );
  }

  //Order List View
  Widget _buildOrderListView(List<Customer> customerList) {
    return customerList.isNotEmpty ? ListView.builder(
      itemCount: customerList.length,
      itemBuilder: (ctx, index) {
        return Column(
          children: [
            CustomerUI(
                index: index+1,
                customerName: customerList[index].name.toString(),)
          ],
        );
      },
    ) :
    Center(child: Text("No Customers ",style: TextStyle(color: appConstants.defaultColor, fontWeight: FontWeight.w600, fontFamily: appConstants.fontFamily,fontSize: 16)));
  }

  @override void initState() {
    super.initState();
    getData();
  }

  void getData() async{
    setState(() {
      isLoading = true;
    });
    customerList = await DbManager.getCustomerList();
    Future.delayed(const Duration(milliseconds: 1500),(){
      setState(() {
        isLoading = false;
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope( onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          // leading: IconButton(icon: const Icon(Icons.arrow_back_ios_outlined), onPressed: (){
          //   Navigator.pop(context);
          //   //Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=> bottomNavigation()), (route) => false);
          // },),
          centerTitle: true,
          title: Text(appConstants.appTitle,style: TextStyle(fontFamily: appConstants.fontFamily)),
          backgroundColor: appConstants.defaultColor,
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:[
                const SizedBox(height: 5),
                Card(
                    child: SizedBox(
                        height: MediaQuery.of(context).size.height*0.05,
                        width: MediaQuery.of(context).size.width,
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.people,color: appConstants.defaultColor),
                              Padding(
                                padding: const EdgeInsets.only(left: 5.0),
                                child: Text('Customers',style: TextStyle(color: appConstants.defaultColor, fontWeight: FontWeight.w600, fontFamily: appConstants.fontFamily,fontSize: 22)),
                              ),
                            ],
                          ),
                        )
                    )
                ),
                const SizedBox(height: 10),
                Card(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height*0.04,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 20.0),
                            child: Text('#',style: TextStyle(color: appConstants.defaultColor, fontWeight: FontWeight.w600, fontFamily: appConstants.fontFamily,fontSize: 16)),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 58.0),
                            child: Text('Customer Info',style: TextStyle(color: appConstants.defaultColor, fontWeight: FontWeight.w600, fontFamily: appConstants.fontFamily,fontSize: 16)),
                          ),
                        ]
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height*0.72,
                  width: MediaQuery.of(context).size.width,
                  child: isLoading? _buildLoadingScreen() : _buildOrderListView(customerList),
                ),
              ]
          ),
        ),
      ),
    );
  }
}