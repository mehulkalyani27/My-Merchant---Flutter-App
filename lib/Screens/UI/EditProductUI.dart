// ignore_for_file: file_names, use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_usb_printer/flutter_usb_printer.dart';
import 'package:mymerchant/Database/databaseController.dart';
import 'package:mymerchant/Model/Product.dart';
import 'package:mymerchant/Resources/constant.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import '../HomeScreens/bottomNavigation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

// ignore_for_file: camel_case_types
//ignore_for_file: must_be_immutable
class EditProductUI extends StatefulWidget {
  Product product;

  EditProductUI(
      {Key? key,
        required this.product,
      })
      : super(key: key);

  @override
  State<EditProductUI> createState() => _EditProductUIState();
}

class _EditProductUIState extends State<EditProductUI> {

  TextEditingController productNameTE = TextEditingController(text: '');
  TextEditingController productPriceTE = TextEditingController(text: '');
  TextEditingController productQtyTE = TextEditingController(text: '');
  TextEditingController productBarcodeTE = TextEditingController(text: '');
  TextEditingController productMrpTE = TextEditingController(text: '');
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  FlutterUsbPrinter flutterUsbPrinter = FlutterUsbPrinter();
  bool printerConnected = false;
  String pdfPath = '';

  void printBarcode(String data) async {
    try {
      await flutterUsbPrinter.write(Uint8List.fromList([27, 64]));
      await flutterUsbPrinter.write(Uint8List.fromList(utf8.encode('\x1B\x61\x01\x1B\x21\x20Toy Bytes\n')));
      Uint8List? productName;
      if(widget.product.productName.toString().length<20){
        setState(() {
          setState(() {
            productName = Uint8List.fromList(utf8.encode('\x1B\x61\x01\x1B\x21\x00Product : ${widget.product.productName.toString()}\n'));
          });
        });
      }else{
        setState(() {
          productName = Uint8List.fromList(utf8.encode('\x1B\x61\x01\x1B\x21\x00          Product : ${widget.product.productName.toString()}\n'));
        });
      }
      await flutterUsbPrinter.write(productName!);
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
      returned = await flutterUsbPrinter.connect(1046, 20497);
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
    initializeData();
    connectPrinter();
  }

  void initializeData() async{
    setState(() {
      productQtyTE = TextEditingController(text: widget.product.quantity.toString());
      productPriceTE = TextEditingController(text: widget.product.productPrice.toString());
      productBarcodeTE = TextEditingController(text: widget.product.productBarcode.toString());
      productNameTE = TextEditingController(text: widget.product.productName.toString());
      productMrpTE = TextEditingController(text: widget.product.productMrp.toString());
    });
  }

  void generatePdfBarcode() async {
    const pageFormat = PdfPageFormat(73*PdfPageFormat.mm, 48*PdfPageFormat.mm);
    final customFont = pw.Font.ttf(await rootBundle.load('assets/fonts/futuramediumbt.ttf'));
    const imageWidth = 24*PdfPageFormat.mm;
    const imageHeight = 12*PdfPageFormat.mm;
    final pdf = pw.Document(pageMode: PdfPageMode.fullscreen);
    final image1 = pw.MemoryImage(
      (await rootBundle.load('assets/images/TBLogo.jpg')).buffer.asUint8List(),
    );
    final image2 = pw.MemoryImage(
      (await rootBundle.load('assets/images/SBLogo.png')).buffer.asUint8List(),
    );
    pdf.addPage(
      pw.Page(
        pageFormat: pageFormat,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Padding(
              padding: const pw.EdgeInsets.only(top: 3),
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                children: [
                  pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.SizedBox(width: 10*PdfPageFormat.mm),
                        pw.Image(image1,width:imageWidth,height: imageHeight ),
                        pw.SizedBox(width: 5*PdfPageFormat.mm),
                        pw.Divider(thickness: 1,height: 10),
                        pw.SizedBox(width: 5*PdfPageFormat.mm),
                        pw.Image(image2,width:imageWidth,height: imageHeight ),
                        pw.SizedBox(width: 10*PdfPageFormat.mm),
                      ]
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
    pdf.save();
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/Test.pdf');
    final bytes = await pdf.save();
    await file.writeAsBytes(bytes);
    String fileName = 'Test.pdf';
    Directory newFolder = Directory("/storage/emulated/0/MyMerchant/Test/Test.pdf");
    String filePath = '/storage/emulated/0/MyMerchant/Test/$fileName';
    await file.copy(filePath);
    setState(() {
      pdfPath = filePath;
    });
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope( onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_outlined), onPressed: (){
            Navigator.pop(context);
          },),
          actions: [
            Padding(
                padding: const EdgeInsets.only(right: 10),
                child: IconButton(onPressed: (){
                  printBarcode(productBarcodeTE.text);
                }, icon: Icon(Icons.print,color: appConstants.whiteColor,size: 28))),
            Padding(
                padding: const EdgeInsets.only(right: 10),
                child: IconButton(onPressed: (){
                      generatePdfBarcode();
                }, icon: Icon(Icons.baby_changing_station,color: appConstants.whiteColor,size: 28))),
          ],
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
                              Icon(Icons.view_list,color: appConstants.defaultColor),
                              Padding(
                                padding: const EdgeInsets.only(left: 5.0),
                                child: Text('Product',style: TextStyle(color: appConstants.defaultColor, fontWeight: FontWeight.w600, fontFamily: appConstants.fontFamily,fontSize: 22)),
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
                    height: MediaQuery.of(context).size.height*0.042,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 50.0),
                            child: Text('Product Info',style: TextStyle(color: appConstants.defaultColor, fontWeight: FontWeight.w600, fontFamily: appConstants.fontFamily,fontSize: 16)),
                          ),
                        ]
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0,right: 20.0),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height*0.7,
                    width: MediaQuery.of(context).size.width,
                    child : Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          SizedBox(
                            height: MediaQuery.of(context).size.height*0.07,
                            width: double.infinity,
                            child: TextFormField(
                              controller: productNameTE,
                              cursorWidth: 2,
                              textAlignVertical: TextAlignVertical.center,
                              textAlign: TextAlign.start,
                              validator: appConstants.validateName,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              style: TextStyle(color: appConstants.defaultColor, fontFamily: appConstants.fontFamily,fontSize: 14),
                              decoration: InputDecoration(
                                labelStyle: TextStyle(color: appConstants.defaultColor, fontFamily: appConstants.fontFamily,fontSize: 14),
                                labelText: 'Product Name',
                                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: appConstants.defaultColor),borderRadius: BorderRadius.circular(8)),
                                focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide(color: appConstants.errorColor),borderRadius: BorderRadius.circular(8)),
                                errorBorder: OutlineInputBorder(borderSide: BorderSide(color: appConstants.errorColor),borderRadius: BorderRadius.circular(8)),
                                enabledBorder:OutlineInputBorder(borderSide: BorderSide(color: appConstants.blackColor),borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: MediaQuery.of(context).size.height*0.07,
                            width: double.infinity,
                            child: TextFormField(
                              controller: productBarcodeTE,
                              cursorWidth: 2,
                              textAlignVertical: TextAlignVertical.center,
                              textAlign: TextAlign.start,
                              style: TextStyle(color: appConstants.defaultColor, fontFamily: appConstants.fontFamily,fontSize: 14),
                              decoration: InputDecoration(
                                labelStyle: TextStyle(color: appConstants.defaultColor, fontFamily: appConstants.fontFamily,fontSize: 14),
                                labelText: 'Product Barcode',
                                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: appConstants.defaultColor),borderRadius: BorderRadius.circular(8)),
                                focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide(color: appConstants.errorColor),borderRadius: BorderRadius.circular(8)),
                                errorBorder: OutlineInputBorder(borderSide: BorderSide(color: appConstants.errorColor),borderRadius: BorderRadius.circular(8)),
                                enabledBorder:OutlineInputBorder(borderSide: BorderSide(color: appConstants.blackColor),borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: MediaQuery.of(context).size.height*0.07,
                            width: double.infinity,
                            child: TextFormField(
                              controller: productMrpTE,
                              cursorWidth: 2,
                              textAlignVertical: TextAlignVertical.center,
                              textAlign: TextAlign.start,
                              validator: appConstants.validateNumericNotEmptyInteger,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              style: TextStyle(color: appConstants.defaultColor, fontFamily: appConstants.fontFamily,fontSize: 14),
                              decoration: InputDecoration(
                                labelStyle: TextStyle(color: appConstants.defaultColor, fontFamily: appConstants.fontFamily,fontSize: 14),
                                labelText: 'Product Mrp',
                                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: appConstants.defaultColor),borderRadius: BorderRadius.circular(8)),
                                focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide(color: appConstants.errorColor),borderRadius: BorderRadius.circular(8)),
                                errorBorder: OutlineInputBorder(borderSide: BorderSide(color: appConstants.errorColor),borderRadius: BorderRadius.circular(8)),
                                enabledBorder:OutlineInputBorder(borderSide: BorderSide(color: appConstants.blackColor),borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: MediaQuery.of(context).size.height*0.07,
                            width: double.infinity,
                            child: TextFormField(
                              controller: productPriceTE,
                              cursorWidth: 2,
                              textAlignVertical: TextAlignVertical.center,
                              textAlign: TextAlign.start,
                              validator: appConstants.validateNumericNotEmptyDouble,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              style: TextStyle(color: appConstants.defaultColor, fontFamily: appConstants.fontFamily,fontSize: 14),
                              decoration: InputDecoration(
                                labelStyle: TextStyle(color: appConstants.defaultColor, fontFamily: appConstants.fontFamily,fontSize: 14),
                                labelText: 'Product Price',
                                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: appConstants.defaultColor),borderRadius: BorderRadius.circular(8)),
                                focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide(color: appConstants.errorColor),borderRadius: BorderRadius.circular(8)),
                                errorBorder: OutlineInputBorder(borderSide: BorderSide(color: appConstants.errorColor),borderRadius: BorderRadius.circular(8)),
                                enabledBorder:OutlineInputBorder(borderSide: BorderSide(color: appConstants.blackColor),borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: MediaQuery.of(context).size.height*0.07,
                            width: double.infinity,
                            child: TextFormField(
                              controller: productQtyTE,
                              cursorWidth: 2,
                              textAlignVertical: TextAlignVertical.center,
                              textAlign: TextAlign.start,
                              validator: appConstants.validateNumericNotEmptyInteger,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              style: TextStyle(color: appConstants.defaultColor, fontFamily: appConstants.fontFamily,fontSize: 14),
                              decoration: InputDecoration(
                                labelStyle: TextStyle(color: appConstants.defaultColor, fontFamily: appConstants.fontFamily,fontSize: 14),
                                labelText: 'Product Quantity',
                                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: appConstants.defaultColor),borderRadius: BorderRadius.circular(8)),
                                focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide(color: appConstants.errorColor),borderRadius: BorderRadius.circular(8)),
                                errorBorder: OutlineInputBorder(borderSide: BorderSide(color: appConstants.errorColor),borderRadius: BorderRadius.circular(8)),
                                enabledBorder:OutlineInputBorder(borderSide: BorderSide(color: appConstants.blackColor),borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          Center(
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height*0.07,
                              width: MediaQuery.of(context).size.width*0.38,
                              child: ElevatedButton(
                                onPressed: () async {
                                  productBarcodeTE.text = DateTime.now().toString().replaceAll("-","").replaceAll(" ", "").replaceAll(":", "").substring(2,14);
                                },
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all<Color>(
                                      appConstants.cirightBlue
                                  ),
                                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                ),
                                child:
                                const Text('Generate Barcode',style: TextStyle(fontWeight: FontWeight.w600,fontSize: 18),),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          Center(
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height*0.07,
                              width: MediaQuery.of(context).size.width*0.38,
                              child: ElevatedButton(
                                onPressed: () async {
                                  if(_formKey.currentState!.validate()){
                                    DbManager dbManager = DbManager();
                                    dbManager.updateProduct(widget.product.id!, productPriceTE.text, productNameTE.text, productBarcodeTE.text, productQtyTE.text,productMrpTE.text);
                                    showTopSnackBar(
                                      context,
                                      const CustomSnackBar.success(
                                        message: 'Product Details updated Successfully!',
                                      ),
                                    );
                                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => bottomNavigation(selectedIndex: 3)));
                                  }
                                },
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all<Color>(
                                      appConstants.cirightBlue
                                  ),
                                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                ),
                                child:
                                const Text('Save',style: TextStyle(fontWeight: FontWeight.w600,fontSize: 18),),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ]
          ),
        ),
      ),
    );
  }
}