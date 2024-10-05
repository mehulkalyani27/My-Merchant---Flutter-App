// ignore_for_file: use_build_context_synchronously, library_prefixes, no_leading_underscores_for_local_identifiers

import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:mymerchant/Model/Product.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:mymerchant/Database/databaseController.dart';
import 'package:mymerchant/Model/Invoice.dart';
import 'package:mymerchant/Model/OrderResponse.dart';
import 'package:mymerchant/Resources/constant.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pinput/pinput.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mymerchant/splashscreen.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:flutter/services.dart';
import 'package:flutter_usb_printer/flutter_usb_printer.dart';



class SettingScreen extends StatefulWidget {
  const SettingScreen({
    Key? key,
  }) : super(key: key);
  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  int empID = 0;
  String empName = '';
  bool isLoading = false;
  String selectYear = '2023';
  String selectedMonth = '01';
  List<Invoice> invoiceList = [];
  List<OrderItem> productList = [];
  static const focusedBorderColor = Color.fromRGBO(23, 171, 144, 1);
  static const fillColor = Color.fromRGBO(243, 246, 249, 0);
  static const borderColor = Color.fromRGBO(23, 171, 144, 0.4);
  final pinController = TextEditingController();
  final focusNode = FocusNode();
  bool isPassword = false;
  bool isSettlement = false;
  bool isSettling = false;
  FlutterUsbPrinter flutterUsbPrinter = FlutterUsbPrinter();
  TextEditingController dateTE = TextEditingController(text: '');
  TextEditingController abETE = TextEditingController(text: '');
  List<summaryData> itemsWithStats = [];
  bool isShown = false;
  List<SalesOrderItem> salesProductList = [];
  final defaultPinTheme = PinTheme(
    width: 56,
    height: 56,
    textStyle: const TextStyle(
      fontSize: 22,
      color: Color.fromRGBO(30, 60, 87, 1),
    ),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(19),
      border: Border.all(color: borderColor),
    ),
  );


  void connectPrinter() async {
    try {
      await flutterUsbPrinter.connect(1046, 20497);
    } on PlatformException {
      showTopSnackBar(
        context,
        const CustomSnackBar.error(
          message: 'Printer Not Connected',
        ),
      );
    } catch (error) {
      showTopSnackBar(
        context,
        CustomSnackBar.error(
          message: 'Printer Error \n$error',
        ),
      );
    }
  }


  void generateSettlement()async{
    int cashTotal = 0;
    int upiTotal = 0;
    int cardTotal = 0;
    int othersTotal = 0;
    int subTotal = 0;
    int cashCount = 0;
    int upiCount = 0;
    int cardCount = 0;
    int othersCount = 0;
    int subCount = 0;
    List<Invoice> selectedInvoiceList = [];
    setState(() {
      isSettling = true;
      selectedInvoiceList.clear();
    });
    List<Invoice> invoiceList = [];
    invoiceList = await fetchingInvoiceData();
    for (var element in invoiceList) {
      if(element.invoiceDate.toString().substring(0,10)==dateTE.text){
        selectedInvoiceList.add(element);
      }
    }
    for (var element in selectedInvoiceList) {
      if(element.invoicePaymentMode=='Cash'){
        setState(() {
          cashCount++;
          cashTotal = cashTotal + int.parse(element.invoiceTotal.toString());
        });
      }
      else if(element.invoicePaymentMode=='UPI'){
        setState(() {
          upiCount++;
          upiTotal = upiTotal + int.parse(element.invoiceTotal.toString());
        });
      }
      else if(element.invoicePaymentMode=='Card'){
        setState(() {
          cardCount++;
          cardTotal = cardTotal + int.parse(element.invoiceTotal.toString());
        });
      }
      else{
        setState(() {
          othersCount++;
          othersTotal = othersTotal + int.parse(element.invoiceTotal.toString());
        });
      }
    }
    setState(() {
      subTotal = cashTotal + upiTotal + othersTotal + cardTotal;
      subCount = cashCount + upiCount + othersCount + cardCount;
    });
    await flutterUsbPrinter.write(Uint8List.fromList([27, 64]));
    await flutterUsbPrinter.write(Uint8List.fromList(utf8.encode('\x1B\x61\x01\x1B\x21\x10    Toy Bytes\n\n')));
    await flutterUsbPrinter.write(Uint8List.fromList(utf8.encode('\x1B\x21\x00        ----------------------------------------\n')));
    await flutterUsbPrinter.write(Uint8List.fromList(utf8.encode( '\x1B\x21\x00\x1B\x61\x01    Date : ${dateTE.text}\n')));
    await flutterUsbPrinter.write(Uint8List.fromList(utf8.encode('\x1B\x21\x00        ----------------------------------------\n')));
    await flutterUsbPrinter.write(Uint8List.fromList(utf8.encode( '\x1B\x21\x00        Mode              Count           Total')));
    await flutterUsbPrinter.write(Uint8List.fromList(utf8.encode('\x1B\x21\x00        ----------------------------------------\n')));
    await flutterUsbPrinter.write(Uint8List.fromList(utf8.encode( '\x1B\x21\x00       Cash               ${cashCount.toString().padRight(3,' ')}         ${cashTotal.toString().padLeft(6,' ')}\n')));
    await flutterUsbPrinter.write(Uint8List.fromList(utf8.encode( '\x1B\x21\x00       UPI                ${upiCount.toString().padRight(3,' ')}         ${upiTotal.toString().padLeft(6,' ')}\n')));
    await flutterUsbPrinter.write(Uint8List.fromList(utf8.encode( '\x1B\x21\x00       Card               ${cardCount.toString().padRight(3,' ')}         ${cardTotal.toString().padLeft(6,' ')}\n')));
    await flutterUsbPrinter.write(Uint8List.fromList(utf8.encode( '\x1B\x21\x00       Others             ${othersCount.toString().padRight(3,' ')}         ${othersTotal.toString().padLeft(6,' ')}\n')));
    await flutterUsbPrinter.write(Uint8List.fromList(utf8.encode('\x1B\x21\x00        ----------------------------------------\n')));
    await flutterUsbPrinter.write(Uint8List.fromList(utf8.encode( '\x1B\x21\x00       Sub-Total          ${subCount.toString().padRight(4,' ')}        ${subTotal.toString().padLeft(6,' ')}\n')));
    await flutterUsbPrinter.write(Uint8List.fromList(utf8.encode('\x1B\x21\x00        ----------------------------------------\n')));
    await flutterUsbPrinter.write(Uint8List.fromList(utf8.encode( '\x1B\x21\x00\x1B\x61\x01    Absent Employee : ${abETE.text}\n')));
    await flutterUsbPrinter.write(Uint8List.fromList(utf8.encode('\x1B\x21\x00        ----------------------------------------\n')));
    Uint8List feedAndCut = Uint8List.fromList([0x1B, 0x64, 0x03, 0x1D, 0x56, 0x42, 0x00]);
    await flutterUsbPrinter.write(feedAndCut);
    setState(() {
      isSettling = false;
    });
  }

  Future<List<Invoice>> fetchingInvoiceData() async{
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
        productList = jsonList.map((json) => OrderItem.fromJson(json)).toList();
      });
      Invoice invoice = Invoice.fromMap(result);
      setState(() {
        invoice.invoiceListProduct = productList;
      });
      invoiceList.add(invoice);

    }
    invoiceList = invoiceList.reversed.toList();
    return invoiceList;
  }

  void _showDatePicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext builder) {
        return SizedBox(
          height: 300.0,
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.date,
            initialDateTime: DateTime.now(),
            minimumYear: 2000,
            maximumYear: 2100,
            onDateTimeChanged: (DateTime newDateTime) {
              setState(() {
                dateTE.text = newDateTime.toString().substring(0,10);
              });
            },
          ),
        );
      },
    );
  }

  void confirmDialog(BuildContext context) {
    showCupertinoDialog(
        context: context,
        builder: (BuildContext ctx) {
          return CupertinoAlertDialog(
            title: const Text('Logout'),
            content: const Text('Are you sure want to exit?'),
            actions: [
              CupertinoDialogAction(
                onPressed: () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  setState(() {
                    prefs.clear();
                  });
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const splash_screen()));
                },
                isDefaultAction: false,
                isDestructiveAction: false,
                child: const Text('Yes'),
              ),
              // The "No" button
              CupertinoDialogAction(
                onPressed: () async {
                  Navigator.of(context).pop();
                },
                isDefaultAction: true,
                isDestructiveAction: true,
                child: const Text('No'),
              )
            ],
          );
        });
  }

  void generateExcelSheet(List<Invoice> invoiceList) async {
    List<Invoice> dbInvoiceList = [];
    dbInvoiceList.clear();
    for (var element in invoiceList) {
      if(element.invoiceDate.toString().substring(0,4)==selectYear){
        if(element.invoiceDate.toString().substring(5,7)==selectedMonth){
          dbInvoiceList.add(element);
        }
      }
    }

    String formatTwoDigits(int number) {
      return number.toString().padLeft(2, '0');
    }

    DateTime now = DateTime.now();
    int year = now.year;
    int month = now.month;

    if(selectYear == now.year.toString() && selectedMonth == now.month.toString()) {}
    else{
      setState(() {
        year = int.parse(selectYear);
        month = int.parse(selectedMonth);
      });
    }


    int daysInMonth = DateTime(year, month + 1, 0).day;

    List<String> allDates = [];

    for (int day = 1; day <= daysInMonth; day++) {
      DateTime date = DateTime(year, month, day);
      if (now.isAfter(date) || now.isAtSameMomentAs(date)) {
        allDates.add('${date.year}-${formatTwoDigits(date.month)}-${formatTwoDigits(date.day)}');
      }
    }


    pw.Widget creatingGraph() {
      Map<String, Map<String, dynamic>> dateTotalMap = {};
      // dbInvoiceList.add(Invoice(invoiceNumber: '', invoiceTotal: '12459', invoiceDate: '2023-10-06', invoiceCustomer: '', invoicePaymentMode: '', invoiceProductList: '', invoiceListProduct: []));
      for (var item in allDates) {
        if (!dateTotalMap.containsKey(item)) {
          dateTotalMap[item] = {
            'total': 0,
          };
        }
      }

      for (var item in dbInvoiceList) {
        if (!dateTotalMap.containsKey(item.invoiceDate.toString().substring(0,10))) {
          dateTotalMap[item.invoiceDate.toString().substring(0,10)] = {
            'total': 0,
          };
        }
        dateTotalMap[item.invoiceDate.toString().substring(0,10)]!['total'] += int.parse(item.invoiceTotal.toString());
      }

      const maxValue = 35000;
      const graphWidth = 500.0;
      const graphHeight = 600.0;
      const barSpacing = 8.0;
      final barCount = dateTotalMap.length;
      final barWidth = (graphWidth - (barSpacing * (barCount - 1))) / barCount;
      const barColor = PdfColors.deepOrangeAccent;

      final bars = <pw.Widget>[];

      dateTotalMap.forEach((key, value) {
        bool isHoliday = false;
        if(int.parse(value['total'].toString())==0){
          setState(() {
            isHoliday = true;
          });
        }
        final barHeight = (int.parse(value['total'].toString()) / maxValue) * graphHeight;
        bars.add(
          pw.Column(
            children: [
              isHoliday? pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 10),
                  child: pw.Transform.rotate(
                    angle: -1.5708, // Rotate by 90 degrees counter-clockwise
                    child: pw.Text(
                      'HOLIDAY', // Add your data label here
                      style:  pw.TextStyle(
                        fontSize: (barWidth/3.toInt()<3? 3 : barWidth/6.toInt()), // Use the custom font
                      ),
                    ),
                  )) : pw.Container(
                height: 0,
                width: 0,
              ),
              pw.Container(
                width: barWidth,
                height: barHeight,
                color: barColor,
                alignment: pw.Alignment.bottomCenter,
                child: pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Padding(
                      padding: pw.EdgeInsets.only(top: barWidth/3.toInt()<4? 5 : barWidth/5.toInt()),
                      child: pw.Transform.rotate(
                        angle: -1.5708, // Rotate by 90 degrees counter-clockwise
                        child: pw.Text(
                          value['total'].toString(), // Add your data label here
                          style:  pw.TextStyle(
                            fontSize: (barWidth/3.toInt()<3? 3 : barWidth/6.toInt()), // Use the custom font
                          ),
                        ),
                      ),
                    ),
                    pw.Text(
                      key.toString().substring(8, 10),
                      style: pw.TextStyle(fontSize: (barWidth/3.toInt()<4? 5 : barWidth/7.toInt()), ),
                    ),
                  ],
                ),
              ),
            ]
          ),
        );

        bars.add(pw.SizedBox(width: barSpacing));
      });

      return pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: bars,
      );

    }

    if(dbInvoiceList.isNotEmpty){
      try{
        //final pageFormat = const PdfPageFormat(13.5 * PdfPageFormat.cm, 20.2 * PdfPageFormat.cm);
        final pdf = pw.Document(pageMode: PdfPageMode.fullscreen);
        DateTime date = DateTime(int.parse(selectYear), int.parse(selectedMonth));
        String monthName = DateFormat('MMMM').format(date);
        final image = pw.MemoryImage(
          (await rootBundle.load('assets/images/TBLogo.jpg')).buffer.asUint8List(),
        );
        pdf.addPage(
          pw.Page(
            //pageFormat: pageFormat,
            build: (pw.Context context) {
              return pw.Center(
                child: pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Image(image),
                    pw.Text(
                      '\n\n Sales Report - $monthName $selectYear',
                      style: const pw.TextStyle(fontSize: 24),
                    ),
                  ],
                ),
              );
            },
          ),
        );

        pdf.addPage(
          pw.Page(
            build: (pw.Context context) {
              return pw.Center(
                child: pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(top: 30,bottom: 20),
                      child: creatingGraph(),
                    ),
                    pw.Text("$monthName-$selectYear Sales Graph",style: const pw.TextStyle(fontSize: 20)),
                  ],
                ),
              );
            },
          ),
        );

        const maxRowsPerPage = 30;
        // Invoice Page
        void addTablePage(List<List<String>> data) {
          pdf.addPage(
            pw.Page(
              build: (pw.Context context) {
                return pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.only(top: 20)),
                    pw.Table.fromTextArray(
                      context: context,
                      data: data.map((row) => row.map((cell) => cell).toList()).toList(),
                      border: const pw.TableBorder(
                        left: pw.BorderSide(width: 1,color: PdfColors.black),
                        right: pw.BorderSide(width: 1,color: PdfColors.black),
                        top: pw.BorderSide(width: 1,color: PdfColors.black),
                        bottom:pw.BorderSide(width: 1,color: PdfColors.black),
                      ),
                      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      cellAlignment: pw.Alignment.center,
                      rowDecoration: pw.BoxDecoration(
                          border: pw.Border.all(
                            color: PdfColors.black,
                            width: 0.5,
                          )
                      ),
                      headerDecoration: const pw.BoxDecoration(
                        color: PdfColors.grey300,
                      ),
                      defaultColumnWidth: const pw.IntrinsicColumnWidth(),
                      columnWidths: {
                        0: const pw.FlexColumnWidth(2),
                        1: const pw.FlexColumnWidth(2),
                        2: const pw.FlexColumnWidth(2),
                      },
                    ),
                    pw.Padding(padding: const pw.EdgeInsets.only(top: 20)),
                  ],
                );
              },
            ),
          );
        }
        dbInvoiceList = dbInvoiceList.reversed.toList();
        for (var i = 0; i < dbInvoiceList.length; i += maxRowsPerPage) {
          final sublistEndIndex = (i + maxRowsPerPage < dbInvoiceList.length)
              ? i + maxRowsPerPage
              : dbInvoiceList.length;
          final sublist = dbInvoiceList.sublist(i, sublistEndIndex);
          List<List<String>> data = [
            ['Invoice Number','Invoice Date','Invoice Amount', 'Payment Mode'],
            for (var item in sublist)
              [item.invoiceNumber.toString(), item.invoiceDate.toString().replaceAll("/", ":"), item.invoiceTotal.toString(), item.invoicePaymentMode.toString()],
          ];
          addTablePage(data);
        }

        int cashTotal = 0;
        int cardTotal = 0;
        int upiTotal = 0;
        int othersTotal = 0;
        int cashCount = 0;
        int cardCount = 0;
        int upiCount = 0;
        int othersCount = 0;
        int subTotal = 0;
        int subCount = 0;
        for (Invoice invoice in dbInvoiceList) {
            if(invoice.invoicePaymentMode=='Cash'){
              cashCount = cashCount + 1;
              cashTotal = cashTotal + int.parse(invoice.invoiceTotal!);
            }
            else if(invoice.invoicePaymentMode=='Card'){
              cardCount = cardCount + 1;
              cardTotal = cardTotal + int.parse(invoice.invoiceTotal!);
            }
            else if(invoice.invoicePaymentMode=='UPI'){
              upiCount = upiCount + 1;
              upiTotal = upiTotal + int.parse(invoice.invoiceTotal!);
            }
            else if (invoice.invoicePaymentMode=='Others'){
              othersCount = othersCount + 1;
              othersTotal = othersTotal + int.parse(invoice.invoiceTotal!);
            }
            subTotal = cashTotal + cardTotal + upiTotal + othersTotal;
            subCount = cashCount + cardCount + upiCount + othersCount;
          }
        // Summary Page
        pdf.addPage(
          pw.Page(
            build: (pw.Context context) {
              final sData = [
                ['Payment Mode', 'Total Count', 'Total'],
                ['Cash', cashCount, cashTotal],
                ['Card', cardCount, cardTotal],
                ['UPI', upiCount, upiTotal],
                ['Others', othersCount, othersTotal],
                [],
              ];
              final tData = [
                ['',subCount,subTotal]
              ];
              return pw.Center(
                child: pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Text(
                      'Summary - $monthName $selectYear\n\n',
                      style: const pw.TextStyle(fontSize: 24),
                    ),
                pw.Table.fromTextArray(
                  context: context,
                  data: sData,
                    border: pw.TableBorder.all(
                      color: PdfColors.black,
                      width: 1,
                    ),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  cellAlignment: pw.Alignment.center,
                  headerDecoration: const pw.BoxDecoration(
                    color: PdfColors.grey300,
                  ),
                  defaultColumnWidth: const pw.IntrinsicColumnWidth(),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(2),
                    1: const pw.FlexColumnWidth(2),
                    2: const pw.FlexColumnWidth(2),
                  },
                ),
                    pw.Table.fromTextArray(
                      context: context,
                      data: tData,
                      border: pw.TableBorder.all(
                        color: PdfColors.black,
                        width: 1,
                      ),
                      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      cellAlignment: pw.Alignment.center,
                      headerDecoration: const pw.BoxDecoration(
                        color: PdfColors.grey300,
                      ),
                      defaultColumnWidth: const pw.IntrinsicColumnWidth(),
                      columnWidths: {
                        0: const pw.FlexColumnWidth(2),
                        1: const pw.FlexColumnWidth(2),
                        2: const pw.FlexColumnWidth(2),
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        );


        salesProductList.clear();

        for (var iElement in dbInvoiceList) {
          iElement.invoiceListProduct?.forEach((element) {
            SalesOrderItem orderItem = SalesOrderItem
              (
              invoiceDate: iElement.invoiceDate!,
              invoiceNumber: iElement.invoiceNumber!,
              paymentMode: iElement.invoicePaymentMode!,
              itemName: element.itemName,
              mrp: element.mrp,
              qty: element.qty,
              price: element.price,
              total: element.total,
              itemId: element.itemId,
            );
            salesProductList.add(orderItem);
          });
        }
        setState(() {
          itemsWithStats = [];
        });
        final Map<int, Map<String, dynamic>> itemStats = {};
        // Calculate the sum of prices and total quantity for each itemId
        for (var item in salesProductList) {
          if (!itemStats.containsKey(item.itemId)) {
            itemStats[item.itemId!] = {
              'priceSum': 0,
              'mrpSum': 0,
              'quantity': 0,
              'itemName' : item.itemName.toString(),
            };
          }
          itemStats[item.itemId]!['priceSum'] += item.price!*item.qty!;
          itemStats[item.itemId]!['mrpSum'] += item.mrp!*item.qty!;
          itemStats[item.itemId]!['quantity'] += item.qty;
        }
        //Popular Page
        // Calculate the average price for each item and print both average price and total quantity
        itemStats.forEach((itemId, stats) {
          final priceSum = stats['priceSum'].toInt();
          final mrpSum = stats['mrpSum'].toInt();
          final quantity = stats['quantity'].toInt();
          final averagePrice = priceSum / quantity;
          final averageMrp = mrpSum / quantity;
          summaryData myData = summaryData(
                  id:itemId,
                  productName:stats['itemName'].toString(),
                  averagePrice: averagePrice.toInt(),
                  quantity: quantity,
                  averageMrp: averageMrp.toInt());
          itemsWithStats.add(myData);
        });
        //Popular Products
        itemsWithStats.sort((a, b) => b.quantity!.compareTo(a.quantity!));
        if(itemsWithStats.length>=25){
          setState(() {
            itemsWithStats = itemsWithStats.sublist(0,30);
          });
        }
        final sHeaders = ['No', 'Product Name','Average MRP', 'Average Price', 'Quantity'];
        int i=1;
        final sData = [
          for(var it in itemsWithStats)[
            i++,
            it.productName!.length>25? it.productName!.substring(0,24) : it.productName,
            it.averageMrp,
            it.averagePrice,
            it.quantity,
          ]
        ];
        pdf.addPage(
          pw.Page(
            build: (pw.Context context) {
              return pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                children: [
                  pw.Padding(padding: const pw.EdgeInsets.only(top: 10)),
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 10),
                    child: pw.Text('Most Popular Products for Month',style: const pw.TextStyle(fontSize: 18)),
                  ),
                  pw.Table.fromTextArray(
                    context: context,
                    headers: sHeaders,
                    data: sData,
                    border: const pw.TableBorder(
                      left: pw.BorderSide(width: 1,color: PdfColors.black),
                      right: pw.BorderSide(width: 1,color: PdfColors.black),
                      top: pw.BorderSide(width: 1,color: PdfColors.black),
                      bottom:pw.BorderSide(width: 1,color: PdfColors.black),
                    ),
                    headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    cellAlignment: pw.Alignment.center,
                    rowDecoration: pw.BoxDecoration(
                        border: pw.Border.all(
                          color: PdfColors.black,
                          width: 0.5,
                        )
                    ),
                    headerDecoration: const pw.BoxDecoration(
                      color: PdfColors.grey300,
                    ),
                    defaultColumnWidth: const pw.IntrinsicColumnWidth(),
                    columnWidths: {
                      0: const pw.FlexColumnWidth(1),
                      1: const pw.FlexColumnWidth(3),
                      2: const pw.FlexColumnWidth(2),
                      3: const pw.FlexColumnWidth(2),
                      4: const pw.FlexColumnWidth(2),
                    },
                  ),
                  pw.Padding(padding: const pw.EdgeInsets.only(top: 20)),
                ],
              );
            },
          ),
        );

        // Least Selling
        setState(() {
          itemsWithStats=[];
        });
        itemStats.forEach((itemId, stats) {
          final priceSum = stats['priceSum'].toInt();
          final mrpSum = stats['mrpSum'].toInt();
          final quantity = stats['quantity'].toInt();
          final averagePrice = priceSum / quantity;
          final averageMrp = mrpSum / quantity;
          summaryData myData = summaryData(
              id:itemId,
              productName:stats['itemName'].toString(),
              averagePrice: averagePrice.toInt(),
              quantity: quantity,
              averageMrp: averageMrp.toInt());
          itemsWithStats.add(myData);
        });

        itemsWithStats.sort((a, b) => b.quantity!.compareTo(a.quantity!));
        setState(() {
          itemsWithStats = itemsWithStats.reversed.toList();
        });
        if(itemsWithStats.length>=30){
          setState(() {
            itemsWithStats = itemsWithStats.sublist(0,30);
          });
        }
        final lHeaders = ['No', 'Product Name','Average MRP', 'Average Price', 'Quantity'];
        int j=1;
        final lData = [
          for(var it in itemsWithStats)[
            j++,
            it.productName!.length>25? it.productName!.substring(0,24) : it.productName,
            it.averageMrp,
            it.averagePrice,
            it.quantity
          ]
        ];
        pdf.addPage(
          pw.Page(
            build: (pw.Context context) {
              return pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                children: [
                  pw.Padding(padding: const pw.EdgeInsets.only(top: 10)),
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 10),
                    child: pw.Text('Least Selling Products for Month',style: const pw.TextStyle(fontSize: 18)),
                  ),
                  pw.Table.fromTextArray(
                    context: context,
                    headers: lHeaders,
                    data: lData,
                    border: const pw.TableBorder(
                      left: pw.BorderSide(width: 1,color: PdfColors.black),
                      right: pw.BorderSide(width: 1,color: PdfColors.black),
                      top: pw.BorderSide(width: 1,color: PdfColors.black),
                      bottom:pw.BorderSide(width: 1,color: PdfColors.black),
                    ),
                    headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    cellAlignment: pw.Alignment.center,
                    rowDecoration: pw.BoxDecoration(
                        border: pw.Border.all(
                          color: PdfColors.black,
                          width: 0.5,
                        )
                    ),
                    headerDecoration: const pw.BoxDecoration(
                      color: PdfColors.grey300,
                    ),
                    defaultColumnWidth: const pw.IntrinsicColumnWidth(),
                    columnWidths: {
                      0: const pw.FlexColumnWidth(1),
                      1: const pw.FlexColumnWidth(3),
                      2: const pw.FlexColumnWidth(2),
                      3: const pw.FlexColumnWidth(2),
                      4: const pw.FlexColumnWidth(2),
                    },
                  ),
                  pw.Padding(padding: const pw.EdgeInsets.only(top: 20)),
                ],
              );
            },
          ),
        );

        //

        pdf.save();
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/$monthName${selectYear}SalesTB.pdf');
        final bytes = await pdf.save();
        await file.writeAsBytes(bytes);
        String fileName = '$monthName${selectYear}SalesTB.pdf';
        String filePath = '/storage/emulated/0/MyMerchant/Reports/';
        Directory newFolder = Directory("$filePath/${selectYear.toString()}");
        if (!await newFolder.exists()) {
          await newFolder.create(recursive: true);
          String filePath = '/storage/emulated/0/MyMerchant/Reports/${selectYear.toString()}/$fileName';
          await file.copy(filePath);
          await Share.shareFiles([file.path]);
        } else {
          String filePath = '/storage/emulated/0/MyMerchant/Reports/${selectYear.toString()}/$fileName';
          await file.copy(filePath);
          await Share.shareFiles([file.path]);
        }
        setState(() {
          isLoading = false;
        });
        showTopSnackBar(
          context,
          const CustomSnackBar.success(
            message: 'File Download Successfully',
          ),
        );
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        showTopSnackBar(
          context,
          CustomSnackBar.error(
            message: 'Error while generating File \n ${e.toString()}',
          ),
        );
      }
    }
    else{
      setState(() {
        isLoading = false;
      });
      showTopSnackBar(
        context,
        const CustomSnackBar.error(
          message: 'No Record Found',
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    getData();
    connectPrinter();
  }


  void getData() async {
    setState(() {
      selectedMonth = DateTime.now().month.toString().padLeft(2,'0');
      selectYear = DateTime.now().year.toString();
      invoiceList.clear();
      dateTE.text = DateTime.now().toString().substring(0,10);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(appConstants.appTitle,
              style: TextStyle(fontFamily: appConstants.fontFamily)),
          backgroundColor: appConstants.defaultColor,
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top:140,left: 140.0, right: 140.0,bottom: 10),
                        child: Image.asset("assets/images/TBLogo.jpg"),
                      ),
                    ),
                // const SizedBox(height: 480),
                isPassword? Padding(
                  padding: const EdgeInsets.only(top: 400.0,bottom: 60),
                  child: Directionality(
                    // Specify direction if desired
                    textDirection: TextDirection.ltr,
                    child: Pinput(
                      controller: pinController,
                      focusNode: focusNode,
                      androidSmsAutofillMethod: AndroidSmsAutofillMethod.smsUserConsentApi,
                      defaultPinTheme: defaultPinTheme,
                      validator: (value) {
                        return value == '0612' || value == '2703'?  null : 'Pin is incorrect';
                      },
                      hapticFeedbackType: HapticFeedbackType.lightImpact,
                      onCompleted: (pin) {

                      },
                      onChanged: (value) {
                        if(value=='0612'){
                          setState(() {
                            isShown = true;
                          });
                        }
                        else if(value=='2703'){
                          setState(() {
                            isSettlement = true;
                          });
                        }
                        else{
                          setState(() {
                            isShown = false;
                          });
                        }
                      },
                      cursor: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(bottom: 9),
                            width: 22,
                            height: 1,
                            color: focusedBorderColor,
                          ),
                        ],
                      ),
                      focusedPinTheme: defaultPinTheme.copyWith(
                        decoration: defaultPinTheme.decoration!.copyWith(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: focusedBorderColor),
                        ),
                      ),
                      submittedPinTheme: defaultPinTheme.copyWith(
                        decoration: defaultPinTheme.decoration!.copyWith(
                          color: fillColor,
                          borderRadius: BorderRadius.circular(19),
                          border: Border.all(color: focusedBorderColor),
                        ),
                      ),
                      errorPinTheme: defaultPinTheme.copyBorderWith(
                        border: Border.all(color: Colors.redAccent),
                      ),
                    ),
                  ),
                ) : const SizedBox(height: 500),
                SizedBox(
                  height: 50,
                  width: 200,
                  child: ElevatedButton(onPressed: (){
                    if(pinController.text.isEmpty){
                      setState(() {
                        isPassword = !isPassword;
                      });
                    }
                  }, child: Text('Passcode',style: TextStyle(fontFamily: appConstants.fontFamily),)),
                ),
                isShown? Padding(
                  padding: const EdgeInsets.only(top: 30.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 380.0,right: 380),
                        child: DropdownButton<String>(
                          underline: const SizedBox(),
                          value: selectedMonth,
                          isExpanded: true,
                          elevation: 0,
                          items: <String>['01','02','03','04','05','06','07','08','09','10','11','12']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: TextStyle(fontSize: 18,color: appConstants.blackColor,fontWeight: FontWeight.w700,fontFamily: appConstants.fontFamily),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedMonth = newValue.toString();
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20,left: 380.0,right: 380,bottom: 20),
                        child: DropdownButton<String>(
                          underline: const SizedBox(),
                          value: selectYear,
                          isExpanded: true,
                          elevation: 0,
                          items: <String>['2023', '2024', '2025', '2026','2027','2028','2029','2030']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: TextStyle(fontSize: 18,color: appConstants.blackColor,fontWeight: FontWeight.w700,fontFamily: appConstants.fontFamily),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectYear = newValue.toString();
                            });
                          },
                        ),
                      ),
                      SizedBox(
                        height: 50,
                        width: 200,
                        child: ElevatedButton(
                            onPressed: () async {
                              setState(() {
                                isLoading = true;
                              });
                              List<Invoice> invoiceList = [];
                              invoiceList = await fetchingInvoiceData();
                              generateExcelSheet(invoiceList);
                          },
                            child: isLoading? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: appConstants.whiteColor)) : Text('Generate Report',style: TextStyle(fontFamily: appConstants.fontFamily),)),
                      ),
                    ],
                  ),
                ) : isSettlement? Padding(
                  padding: const EdgeInsets.only(top : 40.0),
                  child: Column(
                    children: [
                      CupertinoButton(
                        child: const Text('Select Date'),
                        onPressed: () => _showDatePicker(context),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        height: 80,
                        width: 280,
                        child: TextFormField(
                          controller: dateTE,
                          readOnly: true,
                          cursorWidth: 2,
                          textAlignVertical: TextAlignVertical.center,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              color: appConstants.defaultColor,
                              fontFamily: appConstants.fontFamily,
                              fontSize: 14),
                          decoration: InputDecoration(
                            labelStyle: TextStyle(
                                color: appConstants.defaultColor,
                                fontFamily: appConstants.fontFamily,
                                fontSize: 14),
                            labelText: 'Selected Date',
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
                        height: 80,
                        width: 280,
                        child: TextFormField(
                          controller: abETE,
                          cursorWidth: 2,
                          textAlignVertical: TextAlignVertical.center,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              color: appConstants.defaultColor,
                              fontFamily: appConstants.fontFamily,
                              fontSize: 14),
                          decoration: InputDecoration(
                            labelStyle: TextStyle(
                                color: appConstants.defaultColor,
                                fontFamily: appConstants.fontFamily,
                                fontSize: 14),
                            labelText: 'Absent Employee',
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
                        height: 50,
                        width: 240,
                        child: ElevatedButton(
                          onPressed: () async {
                            if(abETE.text.isEmpty){
                              showTopSnackBar(
                                context,
                                const CustomSnackBar.error(
                                  message: 'Enter Absent Employee',
                                ),
                              );
                            }
                            else{
                              generateSettlement();
                            }
                          },
                          child: isSettling? SizedBox(height: 20,width: 20, child: CircularProgressIndicator(color: appConstants.whiteColor,)) : Text('Generate Settlement Report',style: TextStyle(fontFamily: appConstants.fontFamily),),
                        ),
                      )
                    ],
                  ),
                ) : const SizedBox(height: 1),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
