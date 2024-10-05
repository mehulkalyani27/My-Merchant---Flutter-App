// ignore_for_file: file_names, depend_on_referenced_packages, use_build_context_synchronously

// import 'dart:convert';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mymerchant/Model/Invoice.dart';
import 'package:mymerchant/Model/OrderResponse.dart';
import 'package:mymerchant/Resources/constant.dart';
import 'package:flutter/services.dart';
import 'package:flutter_usb_printer/flutter_usb_printer.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';





// ignore: must_be_immutable
class WarrantyScreen extends StatefulWidget {
  Invoice invoiceData;

  WarrantyScreen({Key? key ,
    required this.invoiceData,

  }) : super(key: key);
  @override
  State<WarrantyScreen> createState() => WarrantyScreenState();
}

class WarrantyScreenState extends State<WarrantyScreen> {

  List<OrderItem> productList = [];
  List<String> productNameList = [];
  int mrpTotal = 0;
  int totalSaving = 0;
  bool isLoading = true;
  DateTime date = DateTime.now();
  FlutterUsbPrinter flutterUsbPrinter = FlutterUsbPrinter();
  bool printerConnected = false;
  int index = 1;
  String selectWPro = '';
  String selectWPer = '';
  //bool isLastPage = true;


  @override
  void dispose() {
    super.dispose();
  }

  @override void initState() {
    super.initState();
    initializeData();
  }

  void printWarrantySticker() async{
    try {
      await flutterUsbPrinter.write(Uint8List.fromList([27, 64]));
      await flutterUsbPrinter.write(Uint8List.fromList(utf8.encode('\x1B\x61\x01\x1B\x21\x20Toy Bytes\n')));
      await flutterUsbPrinter.write(Uint8List.fromList(utf8.encode('\x1B\x61\x01\x1B\x21\x20Warranty Card\n')));
      await flutterUsbPrinter.write(Uint8List.fromList(utf8.encode('\x01\x1B\x21\x00Model No: ${selectWPro.toString()}\n')));
      await flutterUsbPrinter.write(Uint8List.fromList(utf8.encode('\x01\x1B\x21\x00Invoice No: ${widget.invoiceData.invoiceNumber}\n')));
      await flutterUsbPrinter.write(Uint8List.fromList(utf8.encode('\x01\x1B\x21\x00Purchase Date: ${widget.invoiceData.invoiceDate.toString().replaceAll("/", ":")}\n')));
      await flutterUsbPrinter.write(Uint8List.fromList(utf8.encode('\x01\x1B\x21\x00Warranty Period: $selectWPer\n')));
      await flutterUsbPrinter.write(Uint8List.fromList(utf8.encode('\x01\x1B\x21\x00Terms & Condition Apply.\n\n\n')));
    } on PlatformException {
      showTopSnackBar(
        context,
        const CustomSnackBar.error(
          message: 'Printer Error',
        ),
      );
    }
  }


  void initializeData() async{
    setState(() {
      isLoading = true;
      productNameList.clear();
    });
    for (var element in widget.invoiceData.invoiceListProduct!) {
      productNameList.add(element.itemName.toString());
    }
    setState(() {
      selectWPer = '6 Months';
      selectWPro = productNameList[0];
    });
    connectPrinter();
    Future.delayed(const Duration(milliseconds: 1000),(){
      setState(() {
        isLoading = false;
      });
    });
  }

  void connectPrinter() async {
    bool? returned = false;
    try {
      returned = await flutterUsbPrinter.connect(1046, 20497);
      debugPrint(returned.toString());
    } on PlatformException {
      showTopSnackBar(
        context,
        const CustomSnackBar.error(
          message: 'Printer Not Connected',
        ),
      );
    }catch (error){
      showTopSnackBar(
        context,
        const CustomSnackBar.error(
          message: 'Printer Error',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_outlined), onPressed: (){
            Navigator.pop(context);
          },),
          centerTitle: true,
          title: Text(appConstants.appTitle,style: TextStyle(fontFamily: appConstants.fontFamily)),
          backgroundColor: appConstants.defaultColor,
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 40.0,right: 40.0,top: 20),
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height*0.02),
                isLoading? const Center(
                  child: CircularProgressIndicator(),
                ) : Column(
                  children: [
                    const SizedBox(height: 15),
                    Text('Select Product',style: TextStyle(fontFamily: appConstants.fontFamily)),
                    DropdownButton<String>(
                      underline: const SizedBox(),
                      value: selectWPro,
                      isExpanded: true,
                      elevation: 0,
                      items: productNameList.map<DropdownMenuItem<String>>(
                              (String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value,
                                style: TextStyle(
                                    fontSize: 18,
                                    color: appConstants.blackColor,
                                    fontWeight: FontWeight.w700,
                                    fontFamily:
                                    appConstants.fontFamily),
                              ),
                            );
                          }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectWPro = newValue.toString();
                        });
                      },
                    ),
                    Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text('Select Warranty Period',style: TextStyle(fontFamily: appConstants.fontFamily))),
                    DropdownButton<String>(
                      underline: const SizedBox(),
                      value: selectWPer,
                      isExpanded: true,
                      elevation: 0,
                      items: <String>[
                        '3 Months',
                        '6 Months',
                        '12 Months',
                      ].map<DropdownMenuItem<String>>(
                              (String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: TextStyle(
                                    fontSize: 18,
                                    color: appConstants.blackColor,
                                    fontWeight: FontWeight.w700,
                                    fontFamily:
                                    appConstants.fontFamily),
                              ),
                            );
                          }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectWPer = newValue.toString();
                        });
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: SizedBox(
                        height: 40,
                        width: 100,
                        child: ElevatedButton(
                            onPressed: () async {
                              printWarrantySticker();
                              Navigator.of(context).pop();
                            },
                            style: ButtonStyle(
                              backgroundColor:
                              MaterialStateProperty.all<Color>(
                                  appConstants.cirightBlue),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(20.0),
                                ),
                              ),
                            ),
                            child: const Text('Print')),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
