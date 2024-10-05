// ignore_for_file: file_names, use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_usb_printer/flutter_usb_printer.dart';
import 'package:mymerchant/Model/Product.dart';
import 'package:mymerchant/Resources/constant.dart';
import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'EditProductUI.dart';

// ignore_for_file: camel_case_types
//ignore_for_file: must_be_immutable
class productUI extends StatefulWidget {
  int index;
  Product product;

  productUI(
      {Key? key,
        required this.index,
        required this.product,
      })
      : super(key: key);

  @override
  State<productUI> createState() => _productUIState();
}

class _productUIState extends State<productUI> {

  FlutterUsbPrinter flutterUsbPrinter = FlutterUsbPrinter();
  bool printerConnected = false;

  void printBarcode(String data) async {
    try {
      await flutterUsbPrinter.write(Uint8List.fromList([27, 64]));
      await flutterUsbPrinter.write(Uint8List.fromList(utf8.encode('\x1B\x61\x01\x1B\x21\x20Toy Bytes\n')));
      String productName = '';
      setState(() {
        productName = '\x1B\x61\x01\x1B\x21\x00Product : ${widget.product.productName.toString()}\n';
      });
      await flutterUsbPrinter.write(Uint8List.fromList(utf8.encode(productName.toString().padRight(18,' '))));
      var productMrp = Uint8List.fromList(utf8.encode('\x1B\x61\x01\x1B\x21\x00MRP : ${widget.product.productMrp.toString()}\n'));
      await flutterUsbPrinter.write(productMrp);
      var productPrice = Uint8List.fromList(utf8.encode('\x1B\x61\x01\x1B\x21\x00Price : ${widget.product.productPrice.toString()}\n'));
      await flutterUsbPrinter.write(productPrice);
      List<int> barcodeSize = [0x1d, 0x68, 0x80, 0x1d, 0x77, 0x02];
      List<int> barcodeFont = [0x1d, 0x66, 0x00];
      List<int> barcode = utf8.encode(data);
      List<int> printBarcode = [0x1d, 0x6b, 0x45, barcode.length];
      printBarcode.addAll(barcode);
      await flutterUsbPrinter.write(Uint8List.fromList(barcodeSize));
      await flutterUsbPrinter.write(Uint8List.fromList(barcodeFont));
      await flutterUsbPrinter.write(Uint8List.fromList(printBarcode));
      await flutterUsbPrinter.write(Uint8List.fromList(utf8.encode('\x1B\x61\x01\x1B\x21\x00${data.toString()}\n\n\n')));
      //await flutterUsbPrinter.write(Uint8List.fromList([29, 86, 66, 0]));
      // Uint8List feedAndCut = Uint8List.fromList([0x1B, 0x64, 0x03, 0x1D, 0x56, 0x42, 0x00]);
      // await flutterUsbPrinter.write(feedAndCut);
    } on PlatformException {
      showTopSnackBar(
        context,
        const CustomSnackBar.error(
          message: 'Printer Error',
        ),
      );
    }
  }

  void connectPrinter() async {
    bool? returned = false;
    try {
      returned = await flutterUsbPrinter.connect(19267, 14384);
    } on PlatformException {
      showTopSnackBar(
        context,
        const CustomSnackBar.error(
          message: 'Printer Not Connected',
        ),
      );
    }
    if (returned!) {
      setState(() {
        printerConnected = true;
      });
    }
  }

  @override void initState() {
    super.initState();
    connectPrinter();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => EditProductUI(product: widget.product)));
      },
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(7),
            boxShadow: [
              BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 6),
            ]
        ),
        margin: const EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 0),
        child: SizedBox(
          height: 44,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 80,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Text("${widget.index.toString()}.",style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, fontFamily: appConstants.fontFamily,color: appConstants.indexColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.start),
                ),
              ),
              const SizedBox(width: 30),
              Image.asset('assets/images/productIcon.png'),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Text(widget.product.productName.toString(),
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, fontFamily: appConstants.fontFamily, color: appConstants.cirightBlue),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.start,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 180.0),
                child: Text(widget.product.productMrp.toString(),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, fontFamily: appConstants.fontFamily, color: appConstants.cirightBlue),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.start,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 40.0,right: 40),
                child: Text(widget.product.productPrice.toString(),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, fontFamily: appConstants.fontFamily, color: appConstants.cirightBlue),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.start,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0,right: 30),
                child: Text(widget.product.quantity.toString(),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, fontFamily: appConstants.fontFamily, color: appConstants.cirightBlue),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.start,
                ),
              ),
              IconButton(onPressed: (){
                if(widget.product.productBarcode.toString()=='null' || widget.product.productBarcode==null || widget.product.productBarcode!.isEmpty){
                  showTopSnackBar(
                    context,
                    const CustomSnackBar.error(
                      message: 'No Barcode Found',
                    ),
                  );
                }
                else{
                  printBarcode(widget.product.productBarcode.toString());
                }
              }, icon: Icon(Icons.print,color: appConstants.cirightBlue)),
            ],
          ),
        ),
      ),
    );
  }
}