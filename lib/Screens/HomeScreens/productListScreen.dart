// ignore_for_file: file_names, import_of_legacy_library_into_null_safe, use_build_context_synchronously

import 'dart:io';
//import 'package:downloads_path_provider/downloads_path_provider.dart' show DownloadsPathProvider;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_usb_printer/flutter_usb_printer.dart';
import 'package:mymerchant/Database/databaseController.dart';
import 'package:mymerchant/Resources/constant.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
import 'package:shimmer/shimmer.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import '../../Model/Product.dart';
import '../UI/ProductUI.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart' show Excel, Sheet;



class ProductListScreen extends StatefulWidget {
  const ProductListScreen({Key? key}) : super(key: key);
  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {

  List<Product> databaseProductList = [];
  int totalProducts = 0;
  List<Product> sortedList = [];
  List<Product> filteredData = [];
  int lastAddedProduct = 0;
  int adding = 0;
  int maxProduct = 0;
  bool isLoading = true;
  bool sort = false;
  bool isIngesting = false;
  final ScrollController _scrollController = ScrollController();
  TextEditingController productNameTE = TextEditingController(text: '');
  TextEditingController productPriceTE = TextEditingController(text: '');
  TextEditingController productQtyTE = TextEditingController(text: '');
  TextEditingController productBarcodeTE = TextEditingController(text: '');
  TextEditingController productMRPTE = TextEditingController(text: '');
  final newItemFormKey = GlobalKey<FormState>();
  TextEditingController searchProductTE = TextEditingController(text: '');
  FilePickerResult? result;

  void filterSearchResults(String query) {
    setState(() {
      query = query.replaceAll(RegExp(r'\s+'),'');
    });
    List<Product> filterList = [];
    setState(() {
      filterList.addAll(databaseProductList.toList());
      filteredData = filterList
          .where((item) =>
      item.productName
          .toString()
          .toLowerCase()
          .contains(query.toLowerCase()) ||
          item.productBarcode.toString().contains(query.toString().toLowerCase()))
          .toList();
    });
  }
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
                    child: const SizedBox(height: 54),
                ),
              );
            },
          ),
        );
  }

  FlutterUsbPrinter flutterUsbPrinter = FlutterUsbPrinter();
  bool printerConnected = false;

  void cutPaper() async {
    try {
      await flutterUsbPrinter.write(Uint8List.fromList([29, 86, 66, 0]));
      await flutterUsbPrinter.write(Uint8List.fromList([27, 64]));
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

  void addProduct(BuildContext context) async{
    Future.delayed(Duration.zero,(){
      showDialog<String>(
          context: context,
          builder: (BuildContext context) =>
              AlertDialog(
                title: const Text('Add Product'),
                content: SingleChildScrollView(
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height*0.32,
                    width: MediaQuery.of(context).size.width*0.8,
                    child: Form(
                      key: newItemFormKey,
                      child: Column(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width*0.7,
                            child: TextFormField(
                              controller: productNameTE,
                              minLines: 1,
                              cursorWidth: 2,
                              cursorHeight: 16,
                              textAlignVertical: TextAlignVertical.center,
                              textAlign: TextAlign.start,
                              validator: appConstants.validateProductName,
                              style: TextStyle(color: appConstants.blackColor, fontFamily: appConstants.fontFamily,fontSize: 14),
                              decoration: InputDecoration(
                                errorStyle: const TextStyle(fontSize: 10),
                                contentPadding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                                labelText: 'Product',
                                labelStyle: TextStyle(color: appConstants.blackColor, fontFamily: appConstants.fontFamily),
                                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: appConstants.defaultColor),borderRadius: BorderRadius.circular(8)),
                                focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide(color: appConstants.errorColor),borderRadius: BorderRadius.circular(8)),
                                errorBorder: OutlineInputBorder(borderSide: BorderSide(color: appConstants.errorColor),borderRadius: BorderRadius.circular(8)),
                                enabledBorder:OutlineInputBorder(borderSide: BorderSide(color: appConstants.blackColor),borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: MediaQuery.of(context).size.width*0.7,
                            child: TextFormField(
                              controller: productBarcodeTE,
                              minLines: 1,
                              cursorWidth: 2,
                              cursorHeight: 16,
                              textAlignVertical: TextAlignVertical.center,
                              textAlign: TextAlign.start,
                              style: TextStyle(color: appConstants.blackColor, fontFamily: appConstants.fontFamily,fontSize: 14),
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                                labelText: 'Barcode',
                                errorStyle: const TextStyle(fontSize: 10),
                                labelStyle: TextStyle(color: appConstants.blackColor, fontFamily: appConstants.fontFamily),
                                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: appConstants.defaultColor),borderRadius: BorderRadius.circular(8)),
                                focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide(color: appConstants.errorColor),borderRadius: BorderRadius.circular(8)),
                                errorBorder: OutlineInputBorder(borderSide: BorderSide(color: appConstants.errorColor),borderRadius: BorderRadius.circular(8)),
                                enabledBorder:OutlineInputBorder(borderSide: BorderSide(color: appConstants.blackColor),borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width*0.2,
                                    child: TextFormField(
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      autovalidateMode: AutovalidateMode.onUserInteraction,
                                      validator: appConstants.validateNumericNotEmptyDouble,
                                      controller: productMRPTE,
                                      cursorHeight: 16,
                                      cursorWidth: 2,
                                      textAlignVertical: TextAlignVertical.center,
                                      textAlign: TextAlign.end,
                                      style: TextStyle(color: appConstants.blackColor, fontFamily: appConstants.fontFamily,fontSize: 14),
                                      decoration: InputDecoration(
                                        errorStyle: const TextStyle(fontSize: 1),
                                        labelText: 'MRP',
                                        labelStyle: TextStyle(color: appConstants.blackColor, fontFamily: appConstants.fontFamily),
                                        contentPadding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: appConstants.defaultColor),borderRadius: BorderRadius.circular(8)),
                                        focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide(color: appConstants.errorColor),borderRadius: BorderRadius.circular(8)),
                                        errorBorder: OutlineInputBorder(borderSide: BorderSide(color: appConstants.errorColor),borderRadius: BorderRadius.circular(8)),
                                        enabledBorder:OutlineInputBorder(borderSide: BorderSide(color: appConstants.blackColor),borderRadius: BorderRadius.circular(8)),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width*0.2,
                                      child: TextFormField(
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        autovalidateMode: AutovalidateMode.onUserInteraction,
                                        validator: appConstants.validateNumericNotEmptyDouble,
                                        controller: productPriceTE,
                                        cursorHeight: 16,
                                        cursorWidth: 2,
                                        textAlignVertical: TextAlignVertical.center,
                                        textAlign: TextAlign.end,
                                        style: TextStyle(color: appConstants.blackColor, fontFamily: appConstants.fontFamily,fontSize: 14),
                                        decoration: InputDecoration(
                                          errorStyle: const TextStyle(fontSize: 1),
                                          labelText: 'Price',
                                          labelStyle: TextStyle(color: appConstants.blackColor, fontFamily: appConstants.fontFamily),
                                          contentPadding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: appConstants.defaultColor),borderRadius: BorderRadius.circular(8)),
                                          focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide(color: appConstants.errorColor),borderRadius: BorderRadius.circular(8)),
                                          errorBorder: OutlineInputBorder(borderSide: BorderSide(color: appConstants.errorColor),borderRadius: BorderRadius.circular(8)),
                                          enabledBorder:OutlineInputBorder(borderSide: BorderSide(color: appConstants.blackColor),borderRadius: BorderRadius.circular(8)),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: SizedBox(
                                      //height: 40,
                                      width: MediaQuery.of(context).size.width*0.16,
                                      child: TextFormField(
                                        keyboardType: const TextInputType.numberWithOptions(decimal: false),
                                        validator: appConstants.validateNumericNotEmptyInteger,
                                        controller: productQtyTE,
                                        cursorWidth: 2,
                                        cursorHeight: 16,
                                        textAlignVertical: TextAlignVertical.center,
                                        textAlign: TextAlign.end,
                                        style: TextStyle(color: appConstants.blackColor, fontFamily: appConstants.fontFamily,fontSize: 14),
                                        decoration: InputDecoration(
                                          errorStyle: const TextStyle(fontSize: 1),
                                          labelText: 'Qty',
                                          labelStyle: TextStyle(color: appConstants.blackColor, fontFamily: appConstants.fontFamily),
                                          contentPadding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: appConstants.defaultColor),borderRadius: BorderRadius.circular(8)),
                                          focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide(color: appConstants.errorColor),borderRadius: BorderRadius.circular(8)),
                                          errorBorder: OutlineInputBorder(borderSide: BorderSide(color: appConstants.errorColor),borderRadius: BorderRadius.circular(8)),
                                          enabledBorder:OutlineInputBorder(borderSide: BorderSide(color: appConstants.blackColor),borderRadius: BorderRadius.circular(8)),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ),
                actions: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 100.0),
                        child: SizedBox(
                          height: 40,
                          width: 240,
                          child: ElevatedButton(
                              onPressed: (){
                                productBarcodeTE.text = DateTime.now().toString().replaceAll("-","").replaceAll(" ", "").replaceAll(":", "").substring(2,14);
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all<Color>(
                                    appConstants.cirightBlue
                                ),
                                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(2.0),
                                  ),
                                ),
                              ),
                              child: const Text('Generate Barcode')),
                        ),
                      ),
                      Row(
                        children: [
                          SizedBox(
                            height: 40,
                            width: 160,
                            child: ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all<Color>(
                                    appConstants.greyColor
                                ),),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text("Cancel"),
                            ),
                          ),
                          const SizedBox(width: 20),
                          SizedBox(
                            height: 40,
                            width: 140,
                            child: ElevatedButton(
                              onPressed: () async {
                                if(newItemFormKey.currentState!.validate()){
                                  Product? product;
                                  if(productBarcodeTE.text.isEmpty){
                                    setState(() {
                                      product= Product(
                                          productMrp: productMRPTE.text,
                                          productName: productNameTE.text,
                                          productPrice: productPriceTE.text,
                                          quantity: productQtyTE.text
                                      );
                                    });
                                  }
                                  else{
                                    setState(() {
                                      product= Product(
                                          productMrp: productMRPTE.text,
                                          productName: productNameTE.text,
                                          productPrice: productPriceTE.text,
                                          productBarcode: productBarcodeTE.text,
                                          quantity: productQtyTE.text
                                      );
                                    });
                                  }
                                  try{
                                    await DbManager.addProduct(product!);
                                  } catch (error){
                                    showTopSnackBar(
                                      context,
                                      CustomSnackBar.error(
                                        message: 'Error \n$error',
                                      ),
                                    );
                                  }
                                  Navigator.pop(context);
                                  getProducts();
                                }
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all<Color>(
                                    appConstants.cirightBlue
                                ),),
                              child: const Text("Add"),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ));
    });
  }


  //Order List View
  Widget _buildOrderListView(List<Product>? productList) {
    return productList!.isNotEmpty ? ListView.builder(
      itemCount: productList.length,
      itemBuilder: (ctx, index) {
        return Dismissible(
          key: Key(productList[index].toString()),
          onDismissed: (direction) async {
            setState(() {
              isLoading = true;
            });
            int res = await DbManager.deleteProduct(productList[index].id!.toInt());
            if(res != 1){
              showTopSnackBar(
                context,
                const CustomSnackBar.error(
                  message: 'Error!',
                ),
              );
            }
            getProducts();
            Future.delayed(const Duration(milliseconds: 500),(){
              setState(()  {
                isLoading = false;
              });
            });
          },
          background: Container(color: appConstants.errorColor),
          direction: DismissDirection.endToStart,
          child:  productUI(
            product: productList[index],
            index: productList[index].id!,
          ),
        );
      },
    ) :
    Center(child: Text("No Products",style: TextStyle(color: appConstants.defaultColor, fontWeight: FontWeight.w600, fontFamily: appConstants.fontFamily,fontSize: 16)));
  }

  @override void initState() {
    super.initState();
    getProducts();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<bool> generateExcelSheet(List<Product> productList) async {
    try{
      productList = productList.reversed.toList();
      productList = await DbManager.getProductList();
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Sheet1'];
      sheetObject.appendRow(['Product Id', 'Product Name','Product Barcode', 'Product MRP', 'Product Price', 'Product Quantity']);
      for (Product product in productList) {
        sheetObject.appendRow([
          product.id,
          product.productName,
          product.productBarcode,
          int.parse(product.productMrp.toString()),
          int.parse(product.productPrice.toString()),
          int.parse(product.quantity.toString()
          )]);
      }
      String date = DateFormat('dMMMM').format(DateTime.now());
      String fileName = '${date}TBStockSheet.xlsx';
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(excel.encode()!);
      String filePath = '/storage/emulated/0/MyMerchant/StockSheet/$fileName';
      await file.copy(filePath);
      await Share.shareFiles([file.path]);
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  void getProducts() async {
    setState(() {
      isLoading = true;
      totalProducts = 0;
    });
    productMRPTE.addListener(() {
      if(productMRPTE.text.isNotEmpty){
        productPriceTE.text = productMRPTE.text;
      }
      else{
        productMRPTE.clear();
      }
    });
    var productFuture = DbManager.getProductList();
      await productFuture.then((data){
        setState(() {
          databaseProductList = data.cast();
          databaseProductList = databaseProductList.reversed.toList();
          filteredData = databaseProductList;
        });
      });
      for (var element in databaseProductList) {
        setState(() {
          totalProducts = totalProducts + int.parse(element.quantity!);
        });
      }
    Future.delayed(const Duration(milliseconds: 300),(){
      setState(() {
        searchProductTE.clear();
        isLoading = false;
      });
    });
  }

  void addProductsFromExcelSheet(String file) async{
    setState(() {
      isLoading = true;
    });
    lastAddedProduct= await DbManager.getProductListLength();
    final bytes = File(file).readAsBytesSync();
    final excel = Excel.decodeBytes(bytes);
    final sheet = excel.tables['Sheet1'];
    final rows = sheet?.rows;
    int n =0;
    setState(() {
      maxProduct = rows!.length-2;
      isIngesting = true;
      n = maxProduct-lastAddedProduct;
    });
    showTopSnackBar(
      context,
      CustomSnackBar.success(
        message: 'New $n Product Found',
      ),
    );
    for (int i = lastAddedProduct+1; i < rows!.length-2; i++) {
      final row = rows[i];
      setState(() {
        adding = i;
      });
      Product product = Product(
          productName: row[1]?.value.toString(),
          productBarcode: row[2]?.value.toString(),
          productMrp: row[3]?.value.toString(),
          productPrice: row[4]?.value.toString(),
          quantity: row[5]!.value.toString(),
      );
      try{
        await DbManager.addProduct(product);
      } catch (error){
        showTopSnackBar(
          context,
          CustomSnackBar.error(
            message: 'Can not Add $adding ${row[1]?.value.toString()}\n$error',
          ),
        );
        continue;
      }
    }
    setState(() {
      getProducts();
      isLoading = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return WillPopScope( onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(appConstants.appTitle,style: TextStyle(fontFamily: appConstants.fontFamily)),
          actions: [
            Padding(
                padding: const EdgeInsets.only(right: 10),
                child: IconButton(onPressed: (){
                  productMRPTE.clear();
                  productNameTE.clear();
                  productPriceTE.clear();
                  productQtyTE.clear();
                  productBarcodeTE.clear();
                  addProduct(context);
                }, icon: Icon(Icons.add_circle,color: appConstants.whiteColor,size: 28))),
            Padding(
                padding: const EdgeInsets.only(right: 10),
                child: IconButton(onPressed: () async {
                  getProducts();
                  bool status = await generateExcelSheet(databaseProductList);
                  debugPrint(status.toString());
                  if(status==true){
                    showTopSnackBar(
                      context,
                      const CustomSnackBar.success(
                        message: 'Stock Sheet Download Successfully',
                      ),
                    );
                  }
                  else{
                    showTopSnackBar(
                      context,
                      const CustomSnackBar.error(
                        message: 'Error while downloading File.',
                      ),
                    );
                  }
                }, icon: Icon(Icons.file_download,color: appConstants.whiteColor,size: 24))),
            Padding(
                padding: const EdgeInsets.only(right: 10),
                child: IconButton(onPressed: () async {
                  result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['xlsx', 'xls'],
                    allowMultiple: false,
                  );
                  if(result!.files.isNotEmpty){
                    setState(() {
                      isLoading = false;
                    });
                    addProductsFromExcelSheet(result!.files.first.path!);
                  }
                }, icon: Icon(Icons.file_open_sharp,color: appConstants.whiteColor,size: 24))),
            Padding(
                padding: const EdgeInsets.only(right: 10),
                child: IconButton(
                    onPressed: () async {
                    cutPaper();
                  },
                    icon: Icon(Icons.cut,color: appConstants.whiteColor,size: 24))),
          ],
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
                              Padding(
                                padding: const EdgeInsets.only(bottom: 6.0),
                                child: Icon(Icons.view_list,color: appConstants.defaultColor),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 5.0),
                                child: Text('Products ($totalProducts)',style: TextStyle(color: appConstants.defaultColor, fontWeight: FontWeight.w600, fontFamily: appConstants.fontFamily,fontSize: 24)),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 20.0),
                                child: Text('#',style: TextStyle(color: appConstants.defaultColor, fontWeight: FontWeight.w600, fontFamily: appConstants.fontFamily,fontSize: 16)),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 100.0),
                                child: Text('Product Info',style: TextStyle(color: appConstants.defaultColor, fontWeight: FontWeight.w600, fontFamily: appConstants.fontFamily,fontSize: 16)),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 510.0),
                                child: Text('MRP',style: TextStyle(color: appConstants.defaultColor, fontWeight: FontWeight.w600, fontFamily: appConstants.fontFamily,fontSize: 16)),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 40.0),
                                child: Text('Price',style: TextStyle(color: appConstants.defaultColor, fontWeight: FontWeight.w600, fontFamily: appConstants.fontFamily,fontSize: 16)),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 40.0),
                                child: Text('Qty',style: TextStyle(color: appConstants.defaultColor, fontWeight: FontWeight.w600, fontFamily: appConstants.fontFamily,fontSize: 16)),
                              ),
                            ],
                          ),
                        ]
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10, right: 50.0,left: 50.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: appConstants.circularBackgroundColor)
                    ),
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height*0.07,
                    child: TextFormField(
                      decoration: const InputDecoration(
                        hintText: 'Search Product',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                      ),
                      controller: searchProductTE,
                      onChanged: (value) {
                        filterSearchResults(value);
                      },
                    )
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height*0.58,
                  width: MediaQuery.of(context).size.width,
                  child: isLoading? Column(
                    children: [
                      isIngesting? const SizedBox(height: 20) : const SizedBox(height: 1),
                      isIngesting? SizedBox(
                          width: MediaQuery.of(context).size.width*0.8,
                          child: LinearProgressIndicator(
                            minHeight: 8,
                            value: adding/maxProduct,
                          )
                      ): const SizedBox(height: 1),
                      isIngesting? const SizedBox(height: 20) : const SizedBox(height: 1),
                      SizedBox(
                          height: MediaQuery.of(context).size.height*0.5,
                          width: MediaQuery.of(context).size.width,
                          child: _buildLoadingScreen()),
                    ],
                  ) :  _buildOrderListView(filteredData),
                ),
              ]
          ),
        ),
      ),
    );
  }
}