// ignore_for_file: use_build_context_synchronously, file_names, unrelated_type_equality_checks, camel_case_types, must_be_immutable, duplicate_ignore, unused_local_variable

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:excel/excel.dart' show Excel, Sheet;
import 'package:flutter/services.dart';
import 'package:flutter_usb_printer/flutter_usb_printer.dart';
import 'package:mymerchant/Database/databaseController.dart';
import 'package:mymerchant/Model/Invoice.dart';
import 'package:mymerchant/Model/Product.dart';
import 'package:mymerchant/Resources/constant.dart';
import 'package:mymerchant/Screens/HomeScreens/bottomNavigation.dart';
import 'package:mymerchant/Screens/UI/OrderItemUI.dart';
import 'package:mymerchant/Screens/UI/OrderListUI.dart';
import 'package:flutter/material.dart';
import 'package:mymerchant/Screens/UI/PaymentTypeUI.dart';
import 'package:mymerchant/controller/invoice_controller.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
// import 'package:usb_serial/transaction.dart';
// import 'package:usb_serial/usb_serial.dart';
import '../../Model/OrderResponse.dart';
import 'package:mymerchant/Resources/global.dart' as global;
//import 'package:usb_serial/usb_serial.dart';

// ignore: must_be_immutable
class NewOrderScreen extends StatefulWidget {
  const NewOrderScreen({
    Key? key,
  }) : super(key: key);
  @override
  State<NewOrderScreen> createState() => NewOrderScreenState();
}

class NewOrderScreenState extends State<NewOrderScreen> {
  final newItemFormKey = GlobalKey<FormState>();
  final submitOrderFormKey = GlobalKey<FormState>();
  TextEditingController productNameTE = TextEditingController(text: '');
  TextEditingController productMRPTE = TextEditingController(text: '');
  TextEditingController productPriceTE = TextEditingController(text: '');
  TextEditingController productQtyTE = TextEditingController(text: '');
  TextEditingController productTotalTE = TextEditingController(text: '');
  TextEditingController subTotalTE = TextEditingController(text: '');
  TextEditingController invoiceTE = TextEditingController(text: '');
  TextEditingController customerTE = TextEditingController(text: '');
  TextEditingController invoiceDateTE = TextEditingController(text: '');
  TextEditingController searchProductTE = TextEditingController();
  TextEditingController totalQuantityTE = TextEditingController(text: '');
  TextEditingController totalMRPTE = TextEditingController(text: '');
  String selectYear = '2023';
  String selectedMonth = '01';
  List<OrderItem> sendApiOrder = [];
  List<OrderItem> invoiceOrderList = [];
  List<Product> filteredData = [];
  List<Product> productList = [];
  List<OrderItem> backupProductList = [];
  List<paymentTypeUI> paymentList = [];
  bool priceError = false;
  bool qtyError = false;
  bool morePayments = false;
  bool isOrderListLoading = true;
  bool isPaymentLoading = false;
  bool isEditing = false;
  bool isPaying = false;
  DateTime date = DateTime.now();
  String paymentMode = 'Cash';
  String jsonInvoiceString = '';
  //String? test;
  FlutterUsbPrinter flutterUsbPrinter = FlutterUsbPrinter();
  // UsbPort? _port;
  // final List<Widget> _serialData = [];
  // StreamSubscription<String>? _subscription;
  // Transaction<String>? _transaction;
  bool printerConnected = false;
  bool itemsLoading = false;


  void clearFunction() async{
    setState(() {
      searchProductTE.clear();
      filteredData.clear();
      filteredData.addAll(productList.reversed.toList());
    });
  }

  void refreshFunction() async {
    MyList myList = Provider.of<MyList>(context, listen: false);
    setState(() {
      invoiceOrderList = [];
    });
    myList.items.forEach((element) {
      invoiceOrderList.add(element);
    });
    getSubTotal();
  }

  void createBackup() async {
    try{
      List<Invoice> invoiceList = [];
      List<InvoiceData> invoiceDataList = [];
      invoiceList.clear();
      invoiceDataList.clear();
      invoiceDataList = await DbManager.getInvoiceList();
      for (var element in invoiceDataList) {
        String dataString = element.invoiceData.toString();
        List<String> stringInvoice = element.invoiceData.toString().split(", InvoiceProductList").first.toString().replaceAll("{","").replaceAll("}","").split(",");
        Map<String,dynamic> result = {};
        for(int i=0;i<stringInvoice.length;i++){
          List<String> s = stringInvoice[i].split(":");
          result.putIfAbsent(s[0].trim(), () => s[1].trim());
        }
        String productListString = dataString.split(", InvoiceProductList: ").last.toString();
        List<dynamic> jsonList = json.decode(productListString.substring(0, productListString.length-1));
        setState(() {
          backupProductList = jsonList.map((json) => OrderItem.fromJson(json)).toList();
        });
        Invoice invoice = Invoice.fromMap(result);
        setState(() {
          invoice.invoiceListProduct = backupProductList;
        });
        invoiceList.add(invoice);
      }
      invoiceList = invoiceList.reversed.toList();
      List<Invoice> dbInvoiceList = [];
      dbInvoiceList.clear();
      FormController formController = FormController();
      formController.submitForm(invoiceList[0], (String response) {
        debugPrint("Response: $response");
        if (response == FormController.successStatus) {
          debugPrint('Submitted Successfully');
          showTopSnackBar(
            context,
            const CustomSnackBar.success(
              message: 'Updated Sheet Successfully',
            ),
          );
        } else {
          debugPrint('Can Not Submit');
          showTopSnackBar(
            context,
            const CustomSnackBar.error(
              message: 'Error',
            ),
          );
        }
      });
      for (var element in invoiceList) {
        if(element.invoiceDate.toString().substring(0,4)==selectYear){
          if(element.invoiceDate.toString().substring(5,7)==selectedMonth){
            dbInvoiceList.add(element);
          }
        }
      }
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Sheet1'];
      sheetObject.appendRow(['Invoice Number', 'Invoice Date','Invoice Customer', 'Invoice Total', 'Invoice PaymentMode', 'ProductList']);
      for (Invoice invoice in dbInvoiceList) {
        sheetObject.appendRow([invoice.invoiceNumber, invoice.invoiceDate, invoice.invoiceCustomer, invoice.invoiceTotal, invoice.invoicePaymentMode,  json.encode(invoice.invoiceListProduct?.map((model) => model.toJson()).toList()).toString()]);
      }
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/ToyBytesBackup$selectedMonth$selectYear.xlsx');
      await file.writeAsBytes(excel.encode()!);
      final fileName = 'ToyBytesBackup$selectedMonth$selectYear.xlsx';
      final filePath = '/storage/emulated/0/MyMerchant/Backup/$fileName';
      await file.copy(filePath);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void connectPrinter() async {
    try {
      await flutterUsbPrinter.connect(1046,20497);
    } on PlatformException {
      showTopSnackBar(
        context,
        const CustomSnackBar.error(
          message: 'Printer Not Connected',
        ),
      );
    } catch (error) {
      setState(() {
        printerConnected = false;
      });
    }
  }

  void getSubTotal() async {
    int totalItem = 0;
    int totalQty = 0;
    int subTotal = 0;
    int totalSaving = 0;
    MyList myList = Provider.of<MyList>(context, listen: false);
    setState(() {
      totalQty = 0;
      subTotal = 0;
      totalSaving = 0;
      totalItem = 0;
    });
    myList.items.forEach((element) async {
      // if(element.itemName.toString().length>19){
      //   String data = '${element.itemName.toString().substring(0,20)}Price : ${element.price.toString().padLeft(5,' ')}  Qty : ${element.qty.toString().padLeft(3,' ')}';
      //   await _port!.write(Uint8List.fromList(data.padLeft(40,' ').codeUnits));
      // }
      // else{
      //   String data = '${element.itemName.toString().padLeft(20,' ')}Price : ${element.price.toString().padLeft(5,' ')}  Qty : ${element.qty.toString().padLeft(3,' ')}';
      //   await _port!.write(Uint8List.fromList(data.padLeft(40,' ').codeUnits));
      // }
      totalItem++;
      int savedAmt = 0;
      savedAmt = element.mrp! * element.qty!;
      totalSaving = totalSaving + savedAmt;
      totalQty = totalQty + element.qty!.toInt();
      subTotal = subTotal + element.total!.toInt();
    });
    setState(() {
      subTotalTE.text = subTotal.toString();
      totalQuantityTE.text = totalQty.toString();
      totalMRPTE.text = totalSaving.toString();
    });
    //String data = 'Total : ${subTotal.toString().padRight(12,' ')}Item/Qty : ${totalItem.toString().padRight(5,' ')}/${totalQty.toString().padRight(5,' ')}';
    //await _port!.write(Uint8List.fromList(data.codeUnits));
  }

  void printInvoice() async {
    setState(() {
      isPaying = true;
    });
    MyList myList = Provider.of<MyList>(context, listen: false);
    sendApiOrder = [];
    myList.items.forEach((element) async {
      if (element.qty != 0 || element.price != 0.0 || element.itemName!.isNotEmpty) {
        OrderItem orderItem = OrderItem(
            itemId: element.itemId,
            itemName: element.itemName.toString(),
            qty: element.qty?.toInt(),
            price: element.price?.toInt(),
            mrp: element.mrp?.toInt(),
            total: element.total?.toInt());
          sendApiOrder.add(orderItem);
          DbManager dbManager = DbManager();
          int? stockQuantity = await DbManager.getProductQuantity(element.itemId!);
          int leftQuantity = (stockQuantity! - element.qty!);
          dbManager.updateProductQuantity(element.itemId!, leftQuantity);
      }
    });
    setState(() {
      jsonInvoiceString = json.encode(sendApiOrder.map((model) => model.toJson()).toList()).toString();
    });
    Invoice invoice = Invoice(
        invoiceNumber: invoiceTE.text,
        invoiceTotal: subTotalTE.text,
        invoiceDate: invoiceDateTE.text.replaceAll(":", "/"),
        invoiceCustomer: customerTE.text,
        invoicePaymentMode: paymentMode,
        invoiceProductList: jsonInvoiceString,
        invoiceListProduct: sendApiOrder);
    InvoiceData invoiceData = InvoiceData(invoiceData: invoice.toMap().toString());
    // String data = 'Total : ${subTotalTE.text.toString().padLeft(12,' ')}Payment Mode : ${paymentMode.toString().padLeft(6,' ')}';
    // await _port!.write(Uint8List.fromList(data.codeUnits));
    // String st = 'Thank You !          Do Visit Again !    ';
    // await _port!.write(Uint8List.fromList(st.codeUnits));
    DbManager.addInvoice(invoiceData);
    DbManager.getInvoiceList();
    createBackup();
    setState(() {
          isPaying = false;
        });Navigator.of(context).push(MaterialPageRoute(builder: (context) => bottomNavigation(selectedIndex: 0)));
    // try {
    //   if (printerConnected = true) {
    //     String ticketText = invoice.printInvoice();
    //     await flutterUsbPrinter.write(Uint8List.fromList([27, 64]));
    //     var data = Uint8List.fromList(utf8.encode(ticketText));
    //     await flutterUsbPrinter.write(data);
    //     Uint8List feedAndCut = Uint8List.fromList([0x1B, 0x64, 0x03, 0x1D, 0x56, 0x42, 0x00]);
    //     await flutterUsbPrinter.write(feedAndCut);
    //     await flutterUsbPrinter.write(Uint8List.fromList([27, 64]));
    //     Navigator.of(context).push(MaterialPageRoute(builder: (context) => bottomNavigation(selectedIndex: 0)));
    //   } else {
    //     showTopSnackBar(
    //       context,
    //       const CustomSnackBar.error(
    //         message: 'Printer Not Connected',
    //       ),
    //     );
    //   }
    // } on PlatformException {
    //   showTopSnackBar(
    //     context,
    //     const CustomSnackBar.error(
    //       message: 'Printer Error',
    //     ),
    //   );
    //   setState(() {
    //     isPaying = false;
    //   });
    // }
  }

  void initializeData() async {
    productPriceTE.addListener(() {
      if (productPriceTE.text.isNotEmpty && productQtyTE.text.isNotEmpty) {
        productTotalTE.text =
            (int.parse(productPriceTE.text) * int.parse(productQtyTE.text))
                .toString();
      } else {
        productTotalTE.clear();
      }
    });
    productQtyTE.addListener(() {
      if (productPriceTE.text.isNotEmpty && productQtyTE.text.isNotEmpty) {
        productTotalTE.text = (int.parse(productPriceTE.text) * int.parse(productQtyTE.text)).toString();
      } else {
        productTotalTE.clear();
      }
    });
    productMRPTE.addListener(() {
      if (productMRPTE.text.isNotEmpty) {
        productPriceTE.text = productMRPTE.text;
      } else {
        productPriceTE.clear();
      }
    });
    productList = await DbManager.getProductList();
    filteredData.addAll(productList.reversed.toList());
    MyList myList = Provider.of<MyList>(context, listen: false);
    //_getPorts();
    Future.delayed(const Duration(microseconds: 200), () async {
      myList.clearItems();
      String ans = await DbManager.getInvoiceNumber();
      int n = int.parse(ans.toString().substring(7, 12));
      String formattedNum;
      int year = DateTime.now().year;
      int month = DateTime.now().month;
      String financialYear;
      if (month < 4) {
        financialYear = '${year - 1}-${year.toString().substring(2)}';
      } else {
        financialYear = '$year-${(year + 1).toString().substring(2)}';
      }
      String retrievedFinancialYear = ans.substring(0,7);
      if (financialYear != retrievedFinancialYear) {
        formattedNum = '1'.padLeft(5, '0');
      } else {
        formattedNum = (n + 1).toString().padLeft(5, '0');
      }
      setState(() {
        invoiceTE.text = 'TB$financialYear$formattedNum';
        invoiceDateTE.text = DateTime.now().toString().substring(0,19);
        //invoiceDateTE.text ='2024-06-14 19:33:04';
        selectedMonth = DateTime.now().month.toString().padLeft(2,'0');
        selectYear = DateTime.now().year.toString();
      });
    });
  }

  Widget _buildOrderListView(List<Product>? productList) {
    return productList!.isNotEmpty
        ? ListView.builder(
            itemCount: productList.length,
            itemBuilder: (ctx, index) {
              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(7),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 6),
                        ]),
                    margin: const EdgeInsets.only(
                        top: 10, left: 10, right: 10, bottom: 0),
                    child: GestureDetector(
                      onTap: () async {
                        if(filteredData[index].id!=null ) {
                          MyList myList = Provider.of<MyList>(
                              context, listen: false);
                          OrderItem item = OrderItem(
                              itemId: filteredData[index].id!,
                              itemName: filteredData[index].productName,
                              price: int.parse(filteredData[index].productPrice.toString()),
                              total: int.parse(filteredData[index].productPrice.toString()),
                              mrp: int.parse(filteredData[index].productMrp.toString()),
                              qty: 1);
                          myList.addItem(item);
                          invoiceOrderList.add(item);
                          getSubTotal();
                          clearFunction();
                          showTopSnackBar(
                              context,
                              const CustomSnackBar.success(
                                message: 'Product Added Successfully',
                              ),
                              hideOutAnimationDuration: const Duration(
                                  milliseconds: 400),
                              displayDuration: const Duration(milliseconds: 100)
                          );
                          // if(item.itemName.toString().length>19){
                          //   String data = '${item.itemName.toString().substring(0,20)}Price: ${item.price.toString().padRight(5,' ')} Qty: ${item.qty.toString().padRight(2,' ')}';
                          //   await _port!.write(Uint8List.fromList(data.codeUnits));
                          // }
                          // else{
                          //   String data = '${item.itemName.toString().padRight(20,' ')}Price: ${item.price.toString().padRight(5,' ')} Qty: ${item.qty.toString().padRight(2,' ')}';
                          //   await _port!.write(Uint8List.fromList(data.codeUnits));
                          // }
                        }else{
                          showTopSnackBar(
                              context,
                              const CustomSnackBar.error(
                                message: 'Product Id Not Found!',
                              ),
                              hideOutAnimationDuration: const Duration(
                                  milliseconds: 400),
                              displayDuration: const Duration(milliseconds: 100)
                          );
                        }
                      },
                      child: SizedBox(
                        height: 40,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 10.0),
                                    child: Text(
                                      productList[index].productName.toString(),
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: appConstants.fontFamily,
                                          color: appConstants.cirightBlue),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 10.0),
                                  child: Text(
                                    productList[index].productMrp.toString(),
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: appConstants.fontFamily,
                                        color: appConstants.cirightBlue),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 40.0, right: 10),
                                  child: Text(
                                    productList[index].productPrice.toString(),
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: appConstants.fontFamily,
                                        color: appConstants.cirightBlue),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Text('Available Quantity : ${filteredData[index].quantity}',style: TextStyle(fontSize: 11,fontFamily: appConstants.fontFamily),),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          )
        : Center(
            child: Text("No Products",
                style: TextStyle(
                    color: appConstants.defaultColor,
                    fontWeight: FontWeight.w600,
                    fontFamily: appConstants.fontFamily,
                    fontSize: 16)));
  }

  void addItem(BuildContext context) async {
    Future.delayed(Duration.zero, () {
      showDialog<String>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
                title: const Text('Add Item'),
                content: SingleChildScrollView(
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.3,
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Form(
                      key: newItemFormKey,
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.7,
                            child: TextFormField(
                              controller: productNameTE,
                              minLines: 1,
                              cursorWidth: 2,
                              cursorHeight: 16,
                              textAlignVertical: TextAlignVertical.center,
                              textAlign: TextAlign.start,
                              validator: appConstants.validateProductName,
                              style: TextStyle(
                                  color: appConstants.blackColor,
                                  fontFamily: appConstants.fontFamily,
                                  fontSize: 14),
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 5.0, horizontal: 10.0),
                                labelText: 'Product',
                                labelStyle: TextStyle(
                                    color: appConstants.blackColor,
                                    fontFamily: appConstants.fontFamily),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: appConstants.defaultColor),
                                    borderRadius: BorderRadius.circular(8)),
                                focusedErrorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: appConstants.errorColor),
                                    borderRadius: BorderRadius.circular(8)),
                                errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: appConstants.errorColor),
                                    borderRadius: BorderRadius.circular(8)),
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: appConstants.blackColor),
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.7,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.16,
                                    child: TextFormField(
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                              decimal: true),
                                      autovalidateMode:
                                          AutovalidateMode.onUserInteraction,
                                      validator: appConstants
                                          .validateNumericNotEmptyDouble,
                                      controller: productMRPTE,
                                      cursorHeight: 16,
                                      cursorWidth: 2,
                                      textAlignVertical:
                                          TextAlignVertical.center,
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                          color: appConstants.blackColor,
                                          fontFamily: appConstants.fontFamily,
                                          fontSize: 14),
                                      decoration: InputDecoration(
                                        labelText: 'MRP',
                                        labelStyle: TextStyle(
                                            color: appConstants.blackColor,
                                            fontFamily:
                                                appConstants.fontFamily),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 5.0,
                                                horizontal: 10.0),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color:
                                                    appConstants.defaultColor),
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        focusedErrorBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: appConstants.errorColor),
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        errorBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: appConstants.errorColor),
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: appConstants.blackColor),
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                      ),
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.16,
                                      child: TextFormField(
                                        keyboardType: const TextInputType
                                            .numberWithOptions(decimal: true),
                                        autovalidateMode:
                                            AutovalidateMode.onUserInteraction,
                                        validator: appConstants
                                            .validateNumericNotEmptyDouble,
                                        controller: productPriceTE,
                                        cursorHeight: 16,
                                        cursorWidth: 2,
                                        textAlignVertical:
                                            TextAlignVertical.center,
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            color: appConstants.blackColor,
                                            fontFamily: appConstants.fontFamily,
                                            fontSize: 14),
                                        decoration: InputDecoration(
                                          labelText: 'Price',
                                          labelStyle: TextStyle(
                                              color: appConstants.blackColor,
                                              fontFamily:
                                                  appConstants.fontFamily),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 5.0,
                                                  horizontal: 10.0),
                                          focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: appConstants
                                                      .defaultColor),
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                          focusedErrorBorder:
                                              OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: appConstants
                                                          .errorColor),
                                                  borderRadius:
                                                      BorderRadius.circular(8)),
                                          errorBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color:
                                                      appConstants.errorColor),
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                          enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color:
                                                      appConstants.blackColor),
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Text(
                                        'X',
                                        style: TextStyle(
                                            color: appConstants.blackColor),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.16,
                                        child: TextFormField(
                                          keyboardType: const TextInputType
                                                  .numberWithOptions(
                                              decimal: false),
                                          validator: appConstants
                                              .validateNumericNotEmptyInteger,
                                          controller: productQtyTE,
                                          cursorWidth: 2,
                                          cursorHeight: 16,
                                          textAlignVertical:
                                              TextAlignVertical.center,
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                              color: appConstants.blackColor,
                                              fontFamily:
                                                  appConstants.fontFamily,
                                              fontSize: 14),
                                          decoration: InputDecoration(
                                            labelText: 'Qty',
                                            labelStyle: TextStyle(
                                                color: appConstants.blackColor,
                                                fontFamily:
                                                    appConstants.fontFamily),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    vertical: 5.0,
                                                    horizontal: 10.0),
                                            focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: appConstants
                                                        .defaultColor),
                                                borderRadius:
                                                    BorderRadius.circular(8)),
                                            focusedErrorBorder:
                                                OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: appConstants
                                                            .errorColor),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8)),
                                            errorBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: appConstants
                                                        .errorColor),
                                                borderRadius:
                                                    BorderRadius.circular(8)),
                                            enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: appConstants
                                                        .blackColor),
                                                borderRadius:
                                                    BorderRadius.circular(8)),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Text(
                                        '=',
                                        style: TextStyle(
                                            color: appConstants.blackColor),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.16,
                                  child: TextFormField(
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    readOnly: true,
                                    validator: appConstants
                                        .validateNumericNotEmptyDouble,
                                    controller: productTotalTE,
                                    cursorWidth: 2,
                                    cursorHeight: 16,
                                    textAlignVertical: TextAlignVertical.center,
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                        color: appConstants.blackColor,
                                        fontFamily: appConstants.fontFamily,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700),
                                    decoration: InputDecoration(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 5.0, horizontal: 10.0),
                                      labelText: 'Total',
                                      labelStyle: TextStyle(
                                          color: appConstants.blackColor,
                                          fontFamily: appConstants.fontFamily,
                                          fontWeight: FontWeight.w600),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: appConstants.defaultColor),
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      focusedErrorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: appConstants.errorColor),
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      errorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: appConstants.errorColor),
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: appConstants.blackColor),
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: SizedBox(
                              height: 40,
                              width: 100,
                              child: ElevatedButton(
                                  onPressed: () async {
                                    int productId = await DbManager.getProductID();
                                      Product product = Product(
                                          productName: productNameTE.text,
                                          productPrice: int.parse(productPriceTE.text).toString(),
                                          productMrp: int.parse(productMRPTE.text).toString(),
                                          quantity: int.parse(productQtyTE.text).toString());
                                      DbManager.addProduct(product);
                                      OrderItem addOrder = OrderItem(
                                          itemId: productId,
                                          itemName: productNameTE.text,
                                          qty: int.parse(productQtyTE.text),
                                          price: int.parse(productPriceTE.text),
                                          mrp: int.parse(productMRPTE.text),
                                          total: int.parse(productTotalTE.text));
                                      setState(() {
                                        MyList myList = Provider.of<MyList>(context, listen: false);
                                        myList.addItem(addOrder);
                                        invoiceOrderList.add(addOrder);
                                        getSubTotal();
                                      });
                                    // if(addOrder.itemName.toString().length>19){
                                    //   String data = '${addOrder.itemName.toString().substring(0,20)}Price : ${addOrder.price.toString().padLeft(5,' ')}  Qty : ${addOrder.qty.toString().padLeft(3,' ')}';
                                    //   await _port!.write(Uint8List.fromList(data.padLeft(40,' ').codeUnits));
                                    // }
                                    // else{
                                    //   String data = '${addOrder.itemName.toString().padLeft(20,' ')}Price : ${addOrder.price.toString().padLeft(5,' ')}  Qty : ${addOrder.qty.toString().padLeft(3,' ')}';
                                    //   await _port!.write(Uint8List.fromList(data.padLeft(40,' ').codeUnits));
                                    // }
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
                                  child: const Text('Add')),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ));
    });
  }

  void filterSearchResults(String query) {
    setState(() {
      query = query.replaceAll(RegExp(r'\s+'),'');
    });
    List<Product> filterList = [];
    setState(() {
      filterList.addAll(productList.reversed.toList());
      filteredData = filterList
          .where((item) =>
              item.productName
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              item.productBarcode.toString().contains(query.toString()))
          .toList();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Future<bool> _connectTo(device) async {
  //   _serialData.clear();
  //
  //   if (_subscription != null) {
  //     _subscription!.cancel();
  //     _subscription = null;
  //   }
  //
  //   if (_transaction != null) {
  //     _transaction!.dispose();
  //     _transaction = null;
  //   }
  //
  //   if (_port != null) {
  //     _port!.close();
  //     _port = null;
  //   }
  //
  //   if (device == null) {
  //     setState(() {
  //     });
  //     return true;
  //   }
  //
  //   _port = await device.create();
  //   if (await (_port!.open()) != true) {
  //     setState(() {
  //     });
  //     return false;
  //   }
  //
  //   await _port!.setDTR(true);
  //   await _port!.setRTS(true);
  //   await _port!.setPortParameters(115200, UsbPort.DATABITS_8, UsbPort.STOPBITS_1, UsbPort.PARITY_NONE);
  //
  //   _transaction = Transaction.stringTerminated(_port!.inputStream as Stream<Uint8List>, Uint8List.fromList([13, 10]));
  //
  //   _subscription = _transaction!.stream.listen((String line) {
  //     setState(() {
  //       _serialData.add(Text(line));
  //       if (_serialData.length > 20) {
  //         _serialData.removeAt(0);
  //       }
  //     });
  //   });
  //
  //   setState(() {
  //   });
  //   return true;
  // }

  // void _getPorts() async {
  //   List<UsbDevice> devices = await UsbSerial.listDevices();
  //   if (!devices.contains(_device)) {
  //     _connectTo(null);
  //   }
  //
  //   for (var device in devices) {
  //     if(device.vid == 6790 && device.pid == 29987){
  //       _connectTo(device);
  //     }
  //   }
  // }

  @override
  void initState() {
    super.initState();
    initializeData();
    //connectPrinter();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_outlined),
            onPressed: () async {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>  bottomNavigation(selectedIndex: 0)),
                  (route) => false);
            },
          ),
          centerTitle: true,
          title: Text(appConstants.appTitle,
              style: TextStyle(fontFamily: appConstants.fontFamily)),
          backgroundColor: appConstants.defaultColor,
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 10),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0,right: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('New Invoice',
                        style: TextStyle(
                            color: appConstants.blackColor,
                            fontWeight: FontWeight.w800,
                            fontFamily: appConstants.fontFamily,
                            fontSize: 28)),
                    Row(
                      children: [
                        Text('MRP Total : ',
                            style: TextStyle(
                                color: appConstants.blackColor,
                                fontWeight: FontWeight.w600,
                                fontFamily: appConstants.fontFamily,
                                fontSize: 24)),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.056,
                          width: MediaQuery.of(context).size.width * 0.16,
                          child: TextFormField(
                            controller: totalMRPTE,
                            readOnly: true,
                            cursorHeight: 20,
                            cursorWidth: 2,
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              color: appConstants.blackColor,
                              fontFamily: appConstants.fontFamily,
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: InputDecoration(
                              contentPadding:
                              const EdgeInsets.symmetric(
                                  vertical: 10.0,
                                  horizontal: 12.0),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: appConstants
                                          .blackColor),
                                  borderRadius:
                                  BorderRadius.circular(8)),
                              focusedErrorBorder:
                              OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: appConstants
                                          .errorColor),
                                  borderRadius:
                                  BorderRadius.circular(
                                      8)),
                              errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: appConstants
                                          .errorColor),
                                  borderRadius:
                                  BorderRadius.circular(8)),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: appConstants
                                          .blackColor),
                                  borderRadius:
                                  BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Form(
                key: submitOrderFormKey,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.07,
                        width: 500,
                        child: TextFormField(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          controller: invoiceTE,
                          readOnly: true,
                          cursorWidth: 2,
                          textAlignVertical: TextAlignVertical.center,
                          textAlign: TextAlign.start,
                          validator: appConstants.validateInvoiceNumber,
                          style: TextStyle(
                              color: appConstants.defaultColor,
                              fontFamily: appConstants.fontFamily,
                              fontSize: 14),
                          decoration: InputDecoration(
                            labelStyle: TextStyle(
                                color: appConstants.defaultColor,
                                fontFamily: appConstants.fontFamily,
                                fontSize: 14),
                            labelText: 'Invoice No',
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: appConstants.defaultColor),
                                borderRadius: BorderRadius.circular(8)),
                            focusedErrorBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: appConstants.errorColor),
                                borderRadius: BorderRadius.circular(8)),
                            errorBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: appConstants.errorColor),
                                borderRadius: BorderRadius.circular(8)),
                            enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: appConstants.blackColor),
                                borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.07,
                        width: MediaQuery.of(context).size.width * 0.46,
                        child: TextFormField(
                          readOnly: true,
                          controller: invoiceDateTE,
                          cursorWidth: 2,
                          textAlignVertical: TextAlignVertical.center,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              color: appConstants.defaultColor,
                              fontFamily: appConstants.fontFamily,
                              fontSize: 14),
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.calendar_month,
                                color: appConstants.blackColor),
                            labelStyle: TextStyle(
                                color: appConstants.defaultColor,
                                fontFamily: appConstants.fontFamily,
                                fontSize: 14),
                            labelText: 'Invoice Date',
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: appConstants.defaultColor),
                                borderRadius: BorderRadius.circular(8)),
                            focusedErrorBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: appConstants.errorColor),
                                borderRadius: BorderRadius.circular(8)),
                            errorBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: appConstants.errorColor),
                                borderRadius: BorderRadius.circular(8)),
                            enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: appConstants.blackColor),
                                borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.07,
                        width: 500,
                        child: TextFormField(
                          controller: customerTE,
                          cursorWidth: 2,
                          textAlignVertical: TextAlignVertical.center,
                          textAlign: TextAlign.start,
                          validator: appConstants.validateName,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          style: TextStyle(
                              color: appConstants.defaultColor,
                              fontFamily: appConstants.fontFamily,
                              fontSize: 14),
                          decoration: InputDecoration(
                            labelStyle: TextStyle(
                                color: appConstants.defaultColor,
                                fontFamily: appConstants.fontFamily,
                                fontSize: 14),
                            labelText: 'Customer Name',
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: appConstants.defaultColor),
                                borderRadius: BorderRadius.circular(8)),
                            focusedErrorBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: appConstants.errorColor),
                                borderRadius: BorderRadius.circular(8)),
                            errorBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: appConstants.errorColor),
                                borderRadius: BorderRadius.circular(8)),
                            enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: appConstants.blackColor),
                                borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.04,
                        width: 500,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade100,
                          ),
                          onPressed: () {
                            setState(() {
                              productNameTE.clear();
                              productPriceTE.clear();
                              productQtyTE.clear();
                              productTotalTE.clear();
                              productMRPTE.clear();
                              searchProductTE.clear();
                              priceError = false;
                              qtyError = false;
                            });
                            addItem(context);
                          },
                          child: Align(
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Add Items',
                                      style: TextStyle(
                                          color: appConstants.defaultColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600)),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 3.0),
                                    child: Icon(
                                      Icons.add,
                                      color: appConstants.defaultColor,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              )),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Stack(
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.34,
                            width: 500,
                            child: Container(
                              decoration: BoxDecoration(border: Border.all(color: appConstants.cirightBlue)),
                              child: itemsLoading? const Padding(
                                padding: EdgeInsets.only(top: 20.0),
                                child: Column(
                                  children: [
                                    SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator()),
                                  ],
                                ),
                              ) : ListView.builder(
                                itemCount: invoiceOrderList.length,
                                itemBuilder: (ctx, index) {
                                  return Dismissible(
                                    key: Key(invoiceOrderList[index].toString()),
                                    onDismissed: (direction) {
                                      setState(() {
                                        itemsLoading = true;
                                        invoiceOrderList.removeAt(index);
                                        MyList myList = Provider.of<MyList>(context, listen: false);
                                        myList.deleteItems(index);
                                        setState(() {
                                          invoiceOrderList = [];
                                        });
                                        myList.items.forEach((element) {
                                          invoiceOrderList.add(element);
                                        });
                                        getSubTotal();
                                      });
                                      Future.delayed(const Duration(milliseconds: 400),(){
                                        setState(() {
                                          itemsLoading = false;
                                        });
                                      });
                                    },
                                    background: Container(color: appConstants.errorColor),
                                    direction: DismissDirection.endToStart,
                                    child:  orderItemUI(
                                      orderItem: invoiceOrderList[index],
                                      index: index,
                                    ),
                                  );
                                },
                              )
                            ),
                          ),
                          Positioned(
                            right: 5,
                            top: 5,
                            child: Align(
                              alignment: Alignment.topRight,
                              child: CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.blue.shade100,
                                child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        global.isEditing = !global.isEditing;
                                      });
                                      refreshFunction();
                                    },
                                    child: Icon(
                                      global.isEditing
                                          ? Icons.edit
                                          : Icons.done,
                                      color: appConstants.defaultColor,
                                    )),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Column(
                        children: [
                          Row(
                            children: [
                              Text("Items :",
                                  style: TextStyle(
                                      color: appConstants.blackColor,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600)),
                              Padding(
                                padding: const EdgeInsets.only(left: 10.0),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 5.0),
                                      child: SizedBox(
                                        height:
                                        MediaQuery.of(context).size.height *
                                            0.056,
                                        width:
                                        MediaQuery.of(context).size.width *
                                            0.08,
                                        child: TextFormField(
                                          controller: totalQuantityTE,
                                          readOnly: true,
                                          cursorHeight: 20,
                                          cursorWidth: 2,
                                          textAlign: TextAlign.end,
                                          style: TextStyle(
                                            color: appConstants.blackColor,
                                            fontFamily: appConstants.fontFamily,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w800,
                                          ),
                                          decoration: InputDecoration(
                                            contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 10.0,
                                                horizontal: 12.0),
                                            focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: appConstants
                                                        .blackColor),
                                                borderRadius:
                                                BorderRadius.circular(8)),
                                            focusedErrorBorder:
                                            OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: appConstants
                                                        .errorColor),
                                                borderRadius:
                                                BorderRadius.circular(
                                                    8)),
                                            errorBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: appConstants
                                                        .errorColor),
                                                borderRadius:
                                                BorderRadius.circular(8)),
                                            enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: appConstants
                                                        .blackColor),
                                                borderRadius:
                                                BorderRadius.circular(8)),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 72.0),
                                child: Text("Total :",
                                    style: TextStyle(
                                        color: appConstants.blackColor,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600)),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 10.0),
                                child: Row(
                                  children: [
                                    Text('\u20b9',
                                        style: TextStyle(
                                            color: appConstants.blackColor,
                                            fontFamily: appConstants.fontFamily,
                                            fontSize: 22,
                                            fontWeight: FontWeight.w800)),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 5.0),
                                      child: SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.056,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.16,
                                        child: TextFormField(
                                          controller: subTotalTE,
                                          readOnly: true,
                                          cursorHeight: 20,
                                          cursorWidth: 2,
                                          textAlign: TextAlign.end,
                                          style: TextStyle(
                                            color: appConstants.blackColor,
                                            fontFamily: appConstants.fontFamily,
                                            fontSize: 22,
                                            fontWeight: FontWeight.w800,
                                          ),
                                          decoration: InputDecoration(
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    vertical: 10.0,
                                                    horizontal: 12.0),
                                            focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: appConstants
                                                        .blackColor),
                                                borderRadius:
                                                    BorderRadius.circular(8)),
                                            focusedErrorBorder:
                                                OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: appConstants
                                                            .errorColor),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8)),
                                            errorBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: appConstants
                                                        .errorColor),
                                                borderRadius:
                                                    BorderRadius.circular(8)),
                                            enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: appConstants
                                                        .blackColor),
                                                borderRadius:
                                                    BorderRadius.circular(8)),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text("Payment Mode",
                                      style: TextStyle(
                                          color: appConstants.blackColor,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600)),
                                  const Padding(
                                    padding: EdgeInsets.only(left: 4.0),
                                    child: Icon(
                                      Icons.wallet,
                                      color: Colors.green,
                                    ),
                                  ),
                                  // IconButton(
                                  //   icon: Icon(Icons.add_circle,
                                  //       color: appConstants.cirightBlue),
                                  //   onPressed: (){
                                  //       setState(() {
                                  //         morePayments = !morePayments;
                                  //         paymentList.clear();
                                  //         paymentTypeUI p = paymentTypeUI(amount: int.parse(subTotalTE.text)~/2);
                                  //         paymentTypeUI q = paymentTypeUI(amount: int.parse(subTotalTE.text)~/2);
                                  //         paymentList.add(p);
                                  //         paymentList.add(q);
                                  //       });
                                  //   },
                                  // ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 116.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: appConstants.blackColor)),
                                  height: MediaQuery.of(context).size.height *
                                      0.056,
                                  width:
                                      MediaQuery.of(context).size.width * 0.2,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 10.0),
                                    child: DropdownButton<String>(
                                      underline: const SizedBox(),
                                      value: paymentMode,
                                      isExpanded: true,
                                      elevation: 0,
                                      items: <String>[
                                        'Cash',
                                        'Card',
                                        'UPI',
                                        'Others'
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
                                          paymentMode = newValue.toString();
                                        });
                                      },
                                    ),
                                  ),
                                  // TextFormField(
                                  //   cursorHeight: 18,
                                  //   cursorWidth: 2,
                                  //   validator: appConstants.validateUsername,
                                  //   style: TextStyle(color: appConstants.blackColor, fontFamily: appConstants.fontFamily,fontSize: 16),
                                  //   decoration: InputDecoration(
                                  //     contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                                  //     focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: appConstants.blackColor),borderRadius: BorderRadius.circular(8)),
                                  //     focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide(color: appConstants.errorColor),borderRadius: BorderRadius.circular(8)),
                                  //     errorBorder: OutlineInputBorder(borderSide: BorderSide(color: appConstants.errorColor),borderRadius: BorderRadius.circular(8)),
                                  //     enabledBorder:OutlineInputBorder(borderSide: BorderSide(color: appConstants.blackColor),borderRadius: BorderRadius.circular(8)),
                                  //   ),
                                  // ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      morePayments? Container(
                        height: 160,
                        width: MediaQuery.of(context).size.width * 0.48,
                        decoration: BoxDecoration(border: Border.all(color: appConstants.blackColor,width: 0.1)),
                        child: isPaymentLoading? const Padding(
                          padding: EdgeInsets.only(top: 20.0),
                          child: Column(
                            children: [
                              SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator()),
                            ],
                          ),
                        ) :
                        Column(
                          children: <Widget>[
                            Expanded(
                              child: ListView.builder(
                                itemCount: paymentList.length,
                                itemBuilder: (ctx, index) {
                                  return Dismissible(
                                    key: Key(paymentList[index].toString()),
                                    onDismissed: (direction) {
                                        setState(() {
                                          isPaymentLoading = true;
                                        });
                                        paymentList.removeAt(index);
                                        Future.delayed(const Duration(milliseconds: 100),(){
                                          setState(() {
                                            setState(() {
                                              isPaymentLoading = false;
                                            });
                                          });
                                        });
                                    },
                                    background: Container(color: appConstants.errorColor),
                                    direction: DismissDirection.endToStart,
                                    child: paymentTypeUI(
                                      amount: paymentList[index].amount,
                                    ),
                                  );
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: SizedBox(
                                height: 26,
                                width: 480,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue.shade100,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      productNameTE.clear();
                                      productPriceTE.clear();
                                      productQtyTE.clear();
                                      productTotalTE.clear();
                                      productMRPTE.clear();
                                      searchProductTE.clear();
                                      priceError = false;
                                      qtyError = false;
                                    });
                                    addItem(context);
                                  },
                                  child: Align(
                                      alignment: Alignment.center,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text('Add More',
                                              style: TextStyle(
                                                  color: appConstants.defaultColor,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600)),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 3.0),
                                            child: Icon(
                                              Icons.add,
                                              color: appConstants.defaultColor,
                                              size: 16,
                                            ),
                                          ),
                                        ],
                                      )),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ) : const SizedBox(),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.06,
                        width: MediaQuery.of(context).size.width * 0.48,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (global.formValidate == true) {
                              if (submitOrderFormKey.currentState!.validate()) {
                                MyList myList = Provider.of<MyList>(context, listen: false);
                                if (myList.items.isNotEmpty) {
                                  printInvoice();
                                } else {
                                  showTopSnackBar(
                                    context,
                                    const CustomSnackBar.error(
                                      message: 'Invalid Order Items',
                                    ),
                                  );
                                }
                              }
                            } else {
                              showTopSnackBar(
                                context,
                                const CustomSnackBar.error(
                                  message: 'Invalid Order Items',
                                ),
                              );
                            }
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                appConstants.cirightBlue),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                            ),
                          ),
                          child: isPaying
                              ? SizedBox(
                                  height: 28,
                                  width: 28,
                                  child: CircularProgressIndicator(
                                      color: appConstants.whiteColor))
                              : Text(
                                  'Print',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18,
                                      fontFamily: appConstants.fontFamily),
                                ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                      padding: const EdgeInsets.only(left: 5.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                  width: 400,
                                  child: TextFormField(
                                    decoration: const InputDecoration(
                                      hintText: 'Search Product',
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 10.0, horizontal: 16.0),
                                    ),
                                    controller: searchProductTE,
                                    onChanged: (value) {
                                      filterSearchResults(value);
                                    },
                                  )),
                              IconButton(onPressed: (){
                                clearFunction();
                              }, icon: const Icon(Icons.cancel))
                            ],
                          ),
                          Container(
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: appConstants.blackColor
                                          .withOpacity(0.2)),
                                  borderRadius: BorderRadius.circular(20)),
                              width: 470,
                              height: 460,
                              child: _buildOrderListView(filteredData)),
                        ],
                      )),
                ],
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
