// ignore_for_file: file_names, depend_on_referenced_packages, use_build_context_synchronously

// import 'dart:convert';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mymerchant/Model/Invoice.dart';
import 'package:mymerchant/Model/OrderResponse.dart';
import 'package:mymerchant/Resources/constant.dart';
import 'package:mymerchant/Screens/HomeScreens/warrantyScreen.dart';
import 'package:mymerchant/Screens/UI/productDetailUI.dart';
import 'package:flutter/services.dart';
import 'package:flutter_usb_printer/flutter_usb_printer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;




// ignore: must_be_immutable
class ViewOrderScreen extends StatefulWidget {
  Invoice invoiceData;

  ViewOrderScreen({Key? key ,
    required this.invoiceData,

  }) : super(key: key);
  @override
  State<ViewOrderScreen> createState() => ViewOrderScreenState();
}

class ViewOrderScreenState extends State<ViewOrderScreen> {

  TextEditingController subTotalTE = TextEditingController(text: '');
  TextEditingController invoiceTE = TextEditingController(text: '');
  TextEditingController customerTE = TextEditingController(text: '');
  TextEditingController invoiceDateTE = TextEditingController(text: '');
  int totalItems = 0;
  int totalAmount = 0;
  List<OrderItem> productList = [];
  List<String> productNameList = [];
  int mrpTotal = 0;
  int totalSaving = 0;
  bool isLoading = true;
  DateTime date = DateTime.now();
  FlutterUsbPrinter flutterUsbPrinter = FlutterUsbPrinter();
  bool printerConnected = false;
  int index = 1;
  String selectWPro = 'Option 1';
  String selectWPer = 'Option 1';
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

  void generatePrintPdf() async{
    const pageFormat = PdfPageFormat(13.5*PdfPageFormat.cm, 20.2*PdfPageFormat.cm);
    final pdf = pw.Document(pageMode: PdfPageMode.fullscreen);
    final customFont = pw.Font.ttf(await rootBundle.load('assets/fonts/futuramediumbt.ttf'));
    const imageWidth = 13.5*PdfPageFormat.cm;
    const imageHeight = 4.6*PdfPageFormat.cm;

    void addTableToPage (List<OrderItem> singlePageList,bool isLastPage) async {
      pdf.addPage(
        pw.Page(
          pageFormat: pageFormat,
          build: (pw.Context context) {
            final content = <pw.Widget>[];
            // Image Header
            content.add(
              pw.Container(
                height: imageHeight,
                width: imageWidth,
              ));
            // Invoice Number and Invoice Date
            content.add(pw.Padding(
              padding: const pw.EdgeInsets.only(
                  left: 10, right: 10, top: 0.1 * PdfPageFormat.cm),
              child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Padding(
                        padding: const pw.EdgeInsets.only(
                            left: 1 * PdfPageFormat.cm),
                        child: pw.Text('        ',
                            style: pw.TextStyle(
                              font: customFont,
                              fontSize: 10,
                            ))
                    ),
                    pw.Padding(
                        padding: const pw.EdgeInsets.only(
                            left: 2.4 * PdfPageFormat.cm),
                        child: pw.Text('/ ${widget.invoiceData.invoiceNumber
                            .toString()}',
                            style: pw.TextStyle(
                              font: customFont,
                              fontSize: 10,
                            ))
                    ),
                    pw.Padding(
                        padding: const pw.EdgeInsets.only(
                            left: 4.1 * PdfPageFormat.cm),
                        child: pw.Column(
                            children: [
                              pw.Text(DateFormat('dd-MM-yyyy').format(DateTime
                                  .parse(
                                  widget.invoiceData.invoiceDate.toString()
                                      .substring(0, 10))), style: const pw
                                  .TextStyle(fontSize: 8)),
                              pw.Text(widget.invoiceData.invoiceDate
                                  .toString().substring(11, 19).replaceAll(
                                  "/", ":"),
                                  style: pw.TextStyle(
                                    font: customFont,
                                    fontSize: 8,
                                  ))
                            ]
                        )
                    ),
                  ]
              ),
            ),
            );
            // Sorting Data
            List<List<String>> data = [
              for (var item in singlePageList)
                [
                  '${index++}',
                  '${item.itemName}',
                  '${item.qty}',
                  '${item.mrp}',
                  '${item.price}',
                  '${item.total}',
                ],
            ];

            content.add(
              pw.Padding(
                  padding: const pw.EdgeInsets.only(
                      left: 10, right: 10, top: 0.1 * PdfPageFormat.cm),
                  child: pw.Container(
                      height:  isLastPage? 8.6 * PdfPageFormat.cm : 10.9 * PdfPageFormat.cm,
                      decoration: pw.BoxDecoration(
                          border: pw.Border.all(width: 0.0)),
                      child: pw.Column(
                          mainAxisAlignment: pw.MainAxisAlignment
                              .spaceBetween,
                          children: [
                            pw.Table.fromTextArray(
                              border: const pw.TableBorder(
                                left: pw.BorderSide(width: 0, color: PdfColors
                                    .black),
                                right: pw.BorderSide(
                                    width: 0, color: PdfColors.black),
                                top: pw.BorderSide(width: 0, color: PdfColors
                                    .black),
                                bottom: pw.BorderSide(
                                    width: 0, color: PdfColors.black),
                              ),
                              cellAlignment: pw.Alignment.center,
                              rowDecoration: pw.BoxDecoration(
                                  border: pw.Border.all(
                                    color: PdfColors.black,
                                    width: 0.1,
                                  )
                              ),
                              headerDecoration: const pw.BoxDecoration(
                                color: PdfColors.grey300,
                              ),
                              defaultColumnWidth: const pw
                                  .IntrinsicColumnWidth(),
                              columnWidths: {
                                0: const pw.FlexColumnWidth(1),
                                1: const pw.FlexColumnWidth(4),
                                2: const pw.FlexColumnWidth(1),
                                3: const pw.FlexColumnWidth(2),
                                4: const pw.FlexColumnWidth(2),
                                5: const pw.FlexColumnWidth(2),
                              },
                              context: context,
                              headers: [
                                '#',
                                'Product',
                                'Qty',
                                'MRP',
                                'Rate',
                                'Total'
                              ],
                              headerStyle: pw.TextStyle(
                                font: customFont,
                                fontSize: 10,
                              ),
                              data: data,
                              cellStyle: pw.TextStyle(fontSize: 8,font: customFont,),
                            ),
                          ]
                      )
                  )
              ),
            );

            // MRP Total
            isLastPage ? content.add(
              pw.Padding(
                  padding: const pw.EdgeInsets.only(left: 10, right: 10),
                  child: pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Table.fromTextArray(
                          border: const pw.TableBorder(
                            left: pw.BorderSide(
                                width: 0, color: PdfColors.black),
                            right: pw.BorderSide(
                                width: 0, color: PdfColors.black),
                            top: pw.BorderSide(
                                width: 0, color: PdfColors.black),
                            bottom: pw.BorderSide(
                                width: 0, color: PdfColors.black),
                          ),
                          cellAlignment: pw.Alignment.center,
                          rowDecoration: pw.BoxDecoration(
                              border: pw.Border.all(
                                color: PdfColors.black,
                                width: 0.1,
                              )
                          ),
                          headerDecoration: const pw.BoxDecoration(
                            color: PdfColors.grey300,
                          ),
                          defaultColumnWidth: const pw.IntrinsicColumnWidth(),
                          columnWidths: {
                            0: const pw.FlexColumnWidth(1),
                            1: const pw.FlexColumnWidth(2),
                            2: const pw.FlexColumnWidth(1),
                            3: const pw.FlexColumnWidth(2),
                            4: const pw.FlexColumnWidth(4),
                            5: const pw.FlexColumnWidth(2),
                          },
                          headerStyle: pw.TextStyle(
                            font: customFont,
                            fontSize: 10,
                          ),
                          context: context,
                          headers: ['', '', '', '', 'MRP Total', '$mrpTotal'],
                          data: [],
                          cellStyle: const pw.TextStyle(fontSize: 10),
                        ),
                      ]
                  )
              ),
            ) : null;

            // Discount Total
            isLastPage ? content.add(
              pw.Padding(
                  padding: const pw.EdgeInsets.only(left: 10, right: 10),
                  child: pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Table.fromTextArray(
                          border: const pw.TableBorder(
                            left: pw.BorderSide(
                                width: 0, color: PdfColors.black),
                            right: pw.BorderSide(
                                width: 0, color: PdfColors.black),
                            top: pw.BorderSide(
                                width: 0, color: PdfColors.black),
                            bottom: pw.BorderSide(
                                width: 0, color: PdfColors.black),
                          ),
                          cellAlignment: pw.Alignment.center,
                          rowDecoration: pw.BoxDecoration(
                              border: pw.Border.all(
                                color: PdfColors.black,
                                width: 0.1,
                              )
                          ),
                          defaultColumnWidth: const pw.IntrinsicColumnWidth(),
                          columnWidths: {
                            0: const pw.FlexColumnWidth(1),
                            1: const pw.FlexColumnWidth(2),
                            2: const pw.FlexColumnWidth(1),
                            3: const pw.FlexColumnWidth(2),
                            4: const pw.FlexColumnWidth(4),
                            5: const pw.FlexColumnWidth(2),
                          },
                          context: context,
                          headers: [
                            '',
                            '',
                            '',
                            '',
                            'Discount',
                            '(-) $totalSaving'
                          ],
                          headerStyle: pw.TextStyle(
                            font: customFont,
                            fontSize: 10,
                          ),
                          data: [],
                          cellStyle: const pw.TextStyle(fontSize: 10),
                        ),
                      ]
                  )
              ),
            ) : null;


            isLastPage ? content.add(
              pw.Padding(
                  padding: const pw.EdgeInsets.only(left: 10, right: 10),
                  child: pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Table.fromTextArray(
                          border: const pw.TableBorder(
                            left: pw.BorderSide(
                                width: 0, color: PdfColors.black),
                            right: pw.BorderSide(
                                width: 0, color: PdfColors.black),
                            top: pw.BorderSide(
                                width: 0, color: PdfColors.black),
                            bottom: pw.BorderSide(
                                width: 0, color: PdfColors.black),
                          ),
                          cellAlignment: pw.Alignment.center,
                          rowDecoration: pw.BoxDecoration(
                              border: pw.Border.all(
                                color: PdfColors.black,
                                width: 0.1,
                              )
                          ),
                          headerDecoration: const pw.BoxDecoration(
                            color: PdfColors.grey300,
                          ),
                          defaultColumnWidth: const pw.IntrinsicColumnWidth(),
                          columnWidths: {
                            0: const pw.FlexColumnWidth(1),
                            1: const pw.FlexColumnWidth(3),
                            2: const pw.FlexColumnWidth(1),
                            3: const pw.FlexColumnWidth(1),
                            4: const pw.FlexColumnWidth(4),
                            5: const pw.FlexColumnWidth(2),
                          },
                          context: context,
                          headerStyle: pw.TextStyle(
                            font: customFont,
                            fontSize: 10,
                          ),
                          headers: ['', '', '', '$totalItems', 'Total', '$totalAmount'],
                          data: [],
                          cellStyle: const pw.TextStyle(fontSize: 10),
                        ),
                      ]
                  )
              ),
            ) : null;

            content.add(
              pw.Padding(
                  padding: const pw.EdgeInsets.only(
                      left: 10, right: 10, bottom: 0.2 * PdfPageFormat.cm),
                  child: pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Table.fromTextArray(
                          border: const pw.TableBorder(
                            left: pw.BorderSide(
                                width: 0, color: PdfColors.black),
                            right: pw.BorderSide(
                                width: 0, color: PdfColors.black),
                            top: pw.BorderSide(
                                width: 0, color: PdfColors.black),
                            bottom: pw.BorderSide(
                                width: 0, color: PdfColors.black),
                          ),
                          cellAlignment: pw.Alignment.center,
                          rowDecoration: pw.BoxDecoration(
                              border: pw.Border.all(
                                color: PdfColors.black,
                                width: 0.1,
                              )
                          ),
                          defaultColumnWidth: const pw.IntrinsicColumnWidth(),
                          columnWidths: {
                            0: const pw.FlexColumnWidth(1),
                            1: const pw.FlexColumnWidth(2),
                            2: const pw.FlexColumnWidth(1),
                            3: const pw.FlexColumnWidth(1),
                            4: const pw.FlexColumnWidth(4),
                            5: const pw.FlexColumnWidth(2),
                          },
                          context: context,
                          headers: isLastPage ? [
                            '',
                            '',
                            '',
                            '',
                            'Payment Mode :',
                            '${widget.invoiceData.invoicePaymentMode}'
                          ] : ['', '', '', '', '', 'PTO'],
                          data: [],
                          headerStyle: pw.TextStyle(
                            font: customFont,
                            fontSize: 10,
                          ),
                          cellStyle: const pw.TextStyle(fontSize: 10),
                        ),
                      ]
                  )
              ),
            );


            // Footer and Conditions
            content.add(
              pw.Center(
                  child: pw.Container(
                    width: 14 * PdfPageFormat.cm,
                    height: 1.3 * PdfPageFormat.cm,
                  )
              ),
            );

            content.add(
                pw.Padding(
                    padding: const pw.EdgeInsets.only(top: 5, left: 10),
                    child: pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.start,
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Terms & Conditions :',
                              style: pw.TextStyle(fontSize: 7,font: customFont, )),
                          pw.Text('1. This is Computer generated Invoice.',
                              style: pw.TextStyle(fontSize: 7,font: customFont,)),
                          pw.Text(
                              '2. Our risk and responsibility ceases as soon as the goods leave our premises.',
                              style: pw.TextStyle(fontSize: 7,font: customFont,)),
                          pw.Text('3. Subject to NADIAD Jurisdiction only.',
                              style: pw.TextStyle(fontSize: 7,font: customFont,)),
                        ]
                    )
                )
            );

            return pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: content,
            );
          },
        ),
      );
    }
    setState(() {
      index=1;
    });
    if(productList.length < 10 ){
      addTableToPage(productList,true);
    }
    else{
      for (var i = 0; i < productList.length; i += 9) {
        final chunk = productList.sublist(i, i + 9.clamp(0, productList.length - i));
        if(chunk.length == 9){
          addTableToPage(chunk,false);
        }
        else{
          addTableToPage(chunk,true);
        }
      }
    }
    //Saving PDF
    pdf.save();
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/${widget.invoiceData.invoiceNumber}.pdf');
    final bytes = await pdf.save();
    await file.writeAsBytes(bytes);
    String fileName = '${widget.invoiceData.invoiceNumber}.pdf';
    Directory newFolder = Directory("/storage/emulated/0/MyMerchant/Invoice/${widget.invoiceData.invoiceNumber.toString().substring(2,9)}");
    if (!await newFolder.exists()) {
      await newFolder.create(recursive: true);
      String filePath = '/storage/emulated/0/MyMerchant/Invoice/${widget.invoiceData.invoiceNumber.toString().substring(2,9)}/$fileName';
      await file.copy(filePath);
    } else {
      String filePath = '/storage/emulated/0/MyMerchant/Invoice/${widget.invoiceData.invoiceNumber.toString().substring(2,9)}/$fileName';
      await file.copy(filePath);
    }
    generatePdf();
  }


  void generatePdf() async {
      const pageFormat = PdfPageFormat(13.5*PdfPageFormat.cm, 20.2*PdfPageFormat.cm);
      final pdf = pw.Document(pageMode: PdfPageMode.fullscreen);
      final headerImage = pw.MemoryImage(
        (await rootBundle.load('assets/images/TBHeader.JPEG')).buffer.asUint8List(),
      );
      final footerImage = pw.MemoryImage(
        (await rootBundle.load('assets/images/TBFooter.jpg')).buffer.asUint8List(),
      );
      final customFont = pw.Font.ttf(await rootBundle.load('assets/fonts/futuramediumbt.ttf'));
      const imageWidth = 13.5*PdfPageFormat.cm;
      const imageHeight = 5.0*PdfPageFormat.cm;

      void addTableToPage (List<OrderItem> singlePageList,bool isLastPage) async {
        pdf.addPage(
          pw.Page(
            pageFormat: pageFormat,
            build: (pw.Context context) {
              final content = <pw.Widget>[];
              // Image Header
              content.add(
                pw.Image(headerImage, width: imageWidth, height: imageHeight),);
              // Invoice Number and Invoice Date
              content.add(pw.Padding(
                padding: const pw.EdgeInsets.only(
                    left: 10, right: 10, top: 0.1 * PdfPageFormat.cm),
                child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.start,
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Padding(
                          padding: const pw.EdgeInsets.only(
                              left: 1 * PdfPageFormat.cm),
                          child: pw.Text('Bill No.',
                              style: pw.TextStyle(
                                font: customFont,
                                  fontSize: 10,
                              ))
                      ),
                      pw.Padding(
                          padding: const pw.EdgeInsets.only(),
                          child: pw.Text(' ${widget.invoiceData.invoiceNumber
                              .toString()}',
                              style: pw.TextStyle(
                                font: customFont,
                                fontSize: 10,
                              ))
                      ),
                      pw.Padding(
                          padding: const pw.EdgeInsets.only(
                              left: 4.4 * PdfPageFormat.cm),
                          child: pw.Text('Date : ',
                              style: pw.TextStyle(
                                font: customFont,
                                fontSize: 10,
                              ))
                      ),
                      pw.Padding(
                          padding: const pw.EdgeInsets.only(
                              left: 0.1 * PdfPageFormat.cm),
                          child: pw.Column(
                              children: [
                                pw.Text(DateFormat('dd-MM-yyyy').format(DateTime
                                    .parse(
                                    widget.invoiceData.invoiceDate.toString()
                                        .substring(0, 10))), style: const pw
                                    .TextStyle(fontSize: 8)),
                                pw.Text(widget.invoiceData.invoiceDate
                                    .toString().substring(11, 19).replaceAll(
                                    "/", ":"),
                                    style: pw.TextStyle(
                                      font: customFont,
                                      fontSize: 8,
                                    ))
                              ]
                          )
                      ),
                    ]
                ),
              ),
              );
              // Sorting Data
              List<List<String>> data = [
                for (var item in singlePageList)
                  [
                    '${index++}',
                    '${item.itemName}',
                    '${item.qty}',
                    '${item.mrp}',
                    '${item.price}',
                    '${item.total}',
                  ],
              ];

              content.add(
                pw.Padding(
                    padding: const pw.EdgeInsets.only(
                        left: 10, right: 10, top: 0.1 * PdfPageFormat.cm),
                    child: pw.Container(
                        height:  isLastPage? 8.6 * PdfPageFormat.cm : 10.9 * PdfPageFormat.cm,
                        decoration: pw.BoxDecoration(
                            border: pw.Border.all(width: 0.0)),
                        child: pw.Column(
                            mainAxisAlignment: pw.MainAxisAlignment
                                .spaceBetween,
                            children: [
                              pw.Table.fromTextArray(
                                border: const pw.TableBorder(
                                  left: pw.BorderSide(width: 0, color: PdfColors
                                      .black),
                                  right: pw.BorderSide(
                                      width: 0, color: PdfColors.black),
                                  top: pw.BorderSide(width: 0, color: PdfColors
                                      .black),
                                  bottom: pw.BorderSide(
                                      width: 0, color: PdfColors.black),
                                ),
                                cellAlignment: pw.Alignment.center,
                                rowDecoration: pw.BoxDecoration(
                                    border: pw.Border.all(
                                      color: PdfColors.black,
                                      width: 0.1,
                                    )
                                ),
                                headerDecoration: const pw.BoxDecoration(
                                  color: PdfColors.grey300,
                                ),
                                defaultColumnWidth: const pw
                                    .IntrinsicColumnWidth(),
                                columnWidths: {
                                  0: const pw.FlexColumnWidth(1),
                                  1: const pw.FlexColumnWidth(4),
                                  2: const pw.FlexColumnWidth(1),
                                  3: const pw.FlexColumnWidth(2),
                                  4: const pw.FlexColumnWidth(2),
                                  5: const pw.FlexColumnWidth(2),
                                },
                                context: context,
                                headers: [
                                  '#',
                                  'Product',
                                  'Qty',
                                  'MRP',
                                  'Rate',
                                  'Total'
                                ],
                                headerStyle: pw.TextStyle(
                                  font: customFont,
                                  fontSize: 10,
                                ),
                                data: data,
                                cellStyle: pw.TextStyle(fontSize: 8,font: customFont,),
                              ),
                            ]
                        )
                    )
                ),
              );

              // MRP Total
              isLastPage ? content.add(
                pw.Padding(
                    padding: const pw.EdgeInsets.only(left: 10, right: 10),
                    child: pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Table.fromTextArray(
                            border: const pw.TableBorder(
                              left: pw.BorderSide(
                                  width: 0, color: PdfColors.black),
                              right: pw.BorderSide(
                                  width: 0, color: PdfColors.black),
                              top: pw.BorderSide(
                                  width: 0, color: PdfColors.black),
                              bottom: pw.BorderSide(
                                  width: 0, color: PdfColors.black),
                            ),
                            cellAlignment: pw.Alignment.center,
                            rowDecoration: pw.BoxDecoration(
                                border: pw.Border.all(
                                  color: PdfColors.black,
                                  width: 0.1,
                                )
                            ),
                            headerDecoration: const pw.BoxDecoration(
                              color: PdfColors.grey300,
                            ),
                            defaultColumnWidth: const pw.IntrinsicColumnWidth(),
                            columnWidths: {
                              0: const pw.FlexColumnWidth(1),
                              1: const pw.FlexColumnWidth(2),
                              2: const pw.FlexColumnWidth(1),
                              3: const pw.FlexColumnWidth(2),
                              4: const pw.FlexColumnWidth(4),
                              5: const pw.FlexColumnWidth(2),
                            },
                            headerStyle: pw.TextStyle(
                              font: customFont,
                              fontSize: 10,
                            ),
                            context: context,
                            headers: ['', '', '', '', 'MRP Total', '$mrpTotal'],
                            data: [],
                            cellStyle: const pw.TextStyle(fontSize: 10),
                          ),
                        ]
                    )
                ),
              ) : null;

              // Discount Total
              isLastPage ? content.add(
                pw.Padding(
                    padding: const pw.EdgeInsets.only(left: 10, right: 10),
                    child: pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Table.fromTextArray(
                            border: const pw.TableBorder(
                              left: pw.BorderSide(
                                  width: 0, color: PdfColors.black),
                              right: pw.BorderSide(
                                  width: 0, color: PdfColors.black),
                              top: pw.BorderSide(
                                  width: 0, color: PdfColors.black),
                              bottom: pw.BorderSide(
                                  width: 0, color: PdfColors.black),
                            ),
                            cellAlignment: pw.Alignment.center,
                            rowDecoration: pw.BoxDecoration(
                                border: pw.Border.all(
                                  color: PdfColors.black,
                                  width: 0.1,
                                )
                            ),
                            defaultColumnWidth: const pw.IntrinsicColumnWidth(),
                            columnWidths: {
                              0: const pw.FlexColumnWidth(1),
                              1: const pw.FlexColumnWidth(2),
                              2: const pw.FlexColumnWidth(1),
                              3: const pw.FlexColumnWidth(2),
                              4: const pw.FlexColumnWidth(4),
                              5: const pw.FlexColumnWidth(2),
                            },
                            context: context,
                            headers: [
                              '',
                              '',
                              '',
                              '',
                              'Discount',
                              '(-) $totalSaving'
                            ],
                            headerStyle: pw.TextStyle(
                              font: customFont,
                              fontSize: 10,
                            ),
                            data: [],
                            cellStyle: const pw.TextStyle(fontSize: 10),
                          ),
                        ]
                    )
                ),
              ) : null;


              isLastPage ? content.add(
                pw.Padding(
                    padding: const pw.EdgeInsets.only(left: 10, right: 10),
                    child: pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Table.fromTextArray(
                            border: const pw.TableBorder(
                              left: pw.BorderSide(
                                  width: 0, color: PdfColors.black),
                              right: pw.BorderSide(
                                  width: 0, color: PdfColors.black),
                              top: pw.BorderSide(
                                  width: 0, color: PdfColors.black),
                              bottom: pw.BorderSide(
                                  width: 0, color: PdfColors.black),
                            ),
                            cellAlignment: pw.Alignment.center,
                            rowDecoration: pw.BoxDecoration(
                                border: pw.Border.all(
                                  color: PdfColors.black,
                                  width: 0.1,
                                )
                            ),
                            headerDecoration: const pw.BoxDecoration(
                              color: PdfColors.grey300,
                            ),
                            defaultColumnWidth: const pw.IntrinsicColumnWidth(),
                            columnWidths: {
                              0: const pw.FlexColumnWidth(1),
                              1: const pw.FlexColumnWidth(3),
                              2: const pw.FlexColumnWidth(1),
                              3: const pw.FlexColumnWidth(1),
                              4: const pw.FlexColumnWidth(4),
                              5: const pw.FlexColumnWidth(2),
                            },
                            context: context,
                            headerStyle: pw.TextStyle(
                              font: customFont,
                              fontSize: 10,
                            ),
                            headers: ['', '', '', '$totalItems', 'Total', '$totalAmount'],
                            data: [],
                            cellStyle: const pw.TextStyle(fontSize: 10),
                          ),
                        ]
                    )
                ),
              ) : null;

              content.add(
                pw.Padding(
                    padding: const pw.EdgeInsets.only(
                        left: 10, right: 10, bottom: 0.2 * PdfPageFormat.cm),
                    child: pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Table.fromTextArray(
                            border: const pw.TableBorder(
                              left: pw.BorderSide(
                                  width: 0, color: PdfColors.black),
                              right: pw.BorderSide(
                                  width: 0, color: PdfColors.black),
                              top: pw.BorderSide(
                                  width: 0, color: PdfColors.black),
                              bottom: pw.BorderSide(
                                  width: 0, color: PdfColors.black),
                            ),
                            cellAlignment: pw.Alignment.center,
                            rowDecoration: pw.BoxDecoration(
                                border: pw.Border.all(
                                  color: PdfColors.black,
                                  width: 0.1,
                                )
                            ),
                            defaultColumnWidth: const pw.IntrinsicColumnWidth(),
                            columnWidths: {
                              0: const pw.FlexColumnWidth(1),
                              1: const pw.FlexColumnWidth(2),
                              2: const pw.FlexColumnWidth(1),
                              3: const pw.FlexColumnWidth(1),
                              4: const pw.FlexColumnWidth(4),
                              5: const pw.FlexColumnWidth(2),
                            },
                            context: context,
                            headers: isLastPage ? [
                              '',
                              '',
                              '',
                              '',
                              'Payment Mode :',
                              '${widget.invoiceData.invoicePaymentMode}'
                            ] : ['', '', '', '', '', 'PTO'],
                            data: [],
                            headerStyle: pw.TextStyle(
                              font: customFont,
                              fontSize: 10,
                            ),
                            cellStyle: const pw.TextStyle(fontSize: 10),
                          ),
                        ]
                    )
                ),
              );

              // Footer and Conditions
              content.add(
                pw.Center(
                    child: pw.Image(
                      footerImage,
                      width: 14 * PdfPageFormat.cm,
                      height: 1.3 * PdfPageFormat.cm,
                    )
                ),
              );
              content.add(
                  pw.Padding(
                      padding: const pw.EdgeInsets.only(top: 5, left: 10),
                      child: pw.Column(
                          mainAxisAlignment: pw.MainAxisAlignment.start,
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('Terms & Conditions :',
                                style: pw.TextStyle(fontSize: 7,font: customFont, )),
                            pw.Text('1. This is Computer generated Invoice.',
                                style: pw.TextStyle(fontSize: 7,font: customFont,)),
                            pw.Text(
                                '2. Our risk and responsibility ceases as soon as the goods leave our premises.',
                                style: pw.TextStyle(fontSize: 7,font: customFont,)),
                            pw.Text('3. Subject to NADIAD Jurisdiction only.',
                                style: pw.TextStyle(fontSize: 7,font: customFont,)),
                          ]
                      )
                  )
              );

              return pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: content,
              );
            },
          ),
        );
      }
      setState(() {
        index=1;
      });
      if(productList.length < 10 ){
        addTableToPage(productList,true);
      }
      else{
        for (var i = 0; i < productList.length; i += 9) {
          final chunk = productList.sublist(i, i + 9.clamp(0, productList.length - i));
          if(chunk.length == 9){
            addTableToPage(chunk,false);
          }
          else{
            addTableToPage(chunk,true);
          }
        }
      }
      //Saving PDF
      pdf.save();
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/${widget.invoiceData.invoiceNumber}.pdf');
      final bytes = await pdf.save();
      await file.writeAsBytes(bytes);
      String fileName = '${widget.invoiceData.invoiceNumber}.pdf';
      Directory newFolder = Directory("/storage/emulated/0/MyMerchant/Invoice/${widget.invoiceData.invoiceNumber.toString().substring(2,9)}");
      if (!await newFolder.exists()) {
        await newFolder.create(recursive: true);
        String filePath = '/storage/emulated/0/MyMerchant/Invoice/${widget.invoiceData.invoiceNumber.toString().substring(2,9)}/$fileName';
        await file.copy(filePath);
        await Share.shareFiles([file.path],
            text: 'Dear Customer,\n\n\n We hope you’re doing well. Hereby we have attached your Invoice for your recent purchase from Toy Bytes. \n\n Thank you for your Business. Do visit Again.\n',
            subject: 'Invoice for your recent Purchase from Toy Bytes',
        );
      } else {
        String filePath = '/storage/emulated/0/MyMerchant/Invoice/${widget.invoiceData.invoiceNumber.toString().substring(2,9)}/$fileName';
        await file.copy(filePath);
        await Share.shareFiles([file.path],
            text: 'Dear Customer,\n\n\n We hope you’re doing well. Hereby we have attached your Invoice for your recent purchase from Toy Bytes. \n\n Thank you for your Business. Do visit Again.\n',
            subject: 'Invoice for your recent Purchase from Toy Bytes');
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
  }

  void initializeData() async{
    setState(() {
      isLoading = true;
      totalAmount = int.parse(widget.invoiceData.invoiceTotal.toString());
      productNameList.clear();
    });
    for (var element in widget.invoiceData.invoiceListProduct!) {
      productNameList.add(element.itemName.toString());
      productList.add(element);
      int savedAmt = 0;
      savedAmt = (element.mrp! - element.price!) * element.qty!;
      totalItems = totalItems + element.qty!;
      totalSaving = totalSaving + savedAmt;
      mrpTotal = mrpTotal + (element.mrp! * element.qty!);
    }
    // setState(() {
    //   selectWPer = '6 Months';
    //   selectWPro = productNameList[0];
    // });
    connectPrinter();
    Future.delayed(const Duration(milliseconds: 1500),(){
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

  void printInvoice() async {

    try {
        await flutterUsbPrinter.write(Uint8List.fromList([27, 64]));
        String ticketText = widget.invoiceData.printInvoice();
        await flutterUsbPrinter.write(Uint8List.fromList(utf8.encode(ticketText)));
        Uint8List feedAndCut = Uint8List.fromList([0x1B, 0x64, 0x03, 0x1D, 0x56, 0x42, 0x00]);
        await flutterUsbPrinter.write(feedAndCut);
        await flutterUsbPrinter.write(Uint8List.fromList([27, 64]));
        flutterUsbPrinter.close();
    } on PlatformException {
      showTopSnackBar(
        context,
        const CustomSnackBar.error(
          message: 'Printer Error',
        ),
      );
    }
    catch (error){
      showTopSnackBar(
        context,
         CustomSnackBar.error(
          message: 'Printer Error\n$error',
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
          actions: [
            IconButton(onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder:(context) => WarrantyScreen(invoiceData: widget.invoiceData)));
            }, icon: Icon(Icons.credit_card_sharp,color: appConstants.whiteColor)),
            IconButton(onPressed: (){
              generatePrintPdf();
              printInvoice();
            }, icon: Icon(Icons.print,color: appConstants.whiteColor)),
            IconButton(onPressed: (){
              generatePdf();
            }, icon: Icon(Icons.share,color: appConstants.whiteColor)),
          ],
          centerTitle: true,
          title: Text(appConstants.appTitle,style: TextStyle(fontFamily: appConstants.fontFamily)),
          backgroundColor: appConstants.defaultColor,
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 14.0,right: 14.0,top: 20),
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height*0.02),
                Stack(
                  children: [
                    Column(
                      children: [
                        Card(
                        elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30.0),
                              color: Colors.white,
                              border: Border.all(color: appConstants.blackColor.withOpacity(0.2))
                            ),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height*0.76,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 2.0, right: 2.0),
                                child: Column(
                                  children: [
                                    const SizedBox(height: 50),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 60.0),
                                      child: SizedBox(
                                        height: MediaQuery.of(context).size.height*0.46,
                                        child: isLoading? const Padding(
                                          padding: EdgeInsets.only(top: 140.0),
                                          child: Column(
                                            children: [
                                              SizedBox(height: 30, width: 30, child: CircularProgressIndicator()),
                                            ],
                                          ),
                                        ) :
                                       ListView.builder(
                                         itemCount: widget.invoiceData.invoiceListProduct!.length,
                                         itemBuilder: (context, index) {
                                           return ViewOrderUI(
                                               index: index+1,
                                               productDetails: widget.invoiceData.invoiceListProduct![index]);
                                         },
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0,right: 8.0,top: 8),
                                      child: Divider(
                                        color: appConstants.blackColor,
                                        thickness: 1,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0,right: 8.0,  bottom: 8),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Padding(
                                                  padding: const EdgeInsets.only(top: 12, bottom: 12,left: 5),
                                                  child: Text('Payment Mode : ', style: TextStyle(color: appConstants.blackColor,fontFamily: appConstants.fontFamily,fontSize: 28, fontWeight: FontWeight.w600),maxLines: 1,overflow: TextOverflow.ellipsis,softWrap: false, textAlign: TextAlign.end, )
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(left: 10.0),
                                                child: Container(
                                                  width: 160,
                                                  height: 60,
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(20.0),
                                                    color: appConstants.defaultColor.withOpacity(0.14),
                                                  ),
                                                  child: Padding(
                                                      padding: const EdgeInsets.only(top: 12, bottom: 12,left: 5,right: 16),
                                                      child: Text(widget.invoiceData.invoicePaymentMode.toString(),
                                                        style: TextStyle(color: appConstants.blackColor,fontFamily: appConstants.fontFamily,fontSize: 28,
                                                            fontWeight: FontWeight.w800),maxLines: 1,overflow: TextOverflow.ellipsis,softWrap: false,
                                                        textAlign: TextAlign.end, )),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Padding(
                                                  padding: const EdgeInsets.only(top: 12, bottom: 12,left: 5),
                                                  child: Text('Total : ', style: TextStyle(color: appConstants.blackColor,fontFamily: appConstants.fontFamily,fontSize: 28, fontWeight: FontWeight.w600),maxLines: 1,overflow: TextOverflow.ellipsis,softWrap: false, textAlign: TextAlign.end, )
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(left: 10.0),
                                                child: Container(
                                                  width: 320,
                                                  height: 60,
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(20.0),
                                                    color: appConstants.defaultColor.withOpacity(0.14),
                                                  ),
                                                  child: Padding(
                                                      padding: const EdgeInsets.only(top: 12, bottom: 12,left: 5,right: 16),
                                                      child: Text('\u20b9 ${widget.invoiceData.invoiceTotal.toString()}',
                                                        style: TextStyle(color: appConstants.blackColor,fontFamily: appConstants.fontFamily,fontSize: 28,
                                                            fontWeight: FontWeight.w800),maxLines: 1,overflow: TextOverflow.ellipsis,softWrap: false,
                                                     textAlign: TextAlign.end, )),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text('Total Saving : \u20b9 $totalSaving',style: TextStyle(fontFamily: appConstants.fontFamily,fontSize:18,fontWeight: FontWeight.w600),)
                      ],
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      left: 0,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0),
                            color: Colors.white,
                            border: Border.all(color: appConstants.blackColor)
                          ),
                          child: FittedBox(
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height*0.16,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10, right: 8.0, top: 10, bottom: 10),
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width/2.1,
                                      child: Column(
                                        mainAxisAlignment : MainAxisAlignment.spaceEvenly,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                              padding: const EdgeInsets.only(top: 12,left: 10),
                                              child: Text('Invoice for', style: TextStyle(color: appConstants.blackColor,fontFamily: appConstants.fontFamily,fontSize: 14, fontWeight: FontWeight.w400),)),
                                          FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Padding(
                                              padding: const EdgeInsets.only(top: 6, bottom: 6,left: 10,right: 3),
                                              child: Text(widget.invoiceData.invoiceCustomer.toString(),
                                                  style: TextStyle(color: appConstants.blackColor,fontFamily: appConstants.fontFamily,fontSize: 36,
                                                      fontWeight: FontWeight.w800),maxLines: 2,overflow: TextOverflow.ellipsis,softWrap: true,),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 4.0,top: 4.0,bottom: 6.0),
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width/2.7,
                                      child: Column(
                                        mainAxisAlignment : MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Padding(
                                                padding: const EdgeInsets.only(top: 8,left: 10),
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Text('Invoice Number', style: TextStyle(color: appConstants.blackColor,fontFamily: appConstants.fontFamily,fontSize: 12, fontWeight: FontWeight.w400),),
                                                    Text(widget.invoiceData.invoiceNumber.toString(), style: TextStyle(color: appConstants.blackColor,fontFamily: appConstants.fontFamily,fontSize: 20, fontWeight: FontWeight.w800),
                                                      overflow: TextOverflow.ellipsis,)
                                                  ],
                                                )),
                                          ),
                                          FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Padding(
                                                padding: const EdgeInsets.only(bottom: 0,left: 10),
                                                child:  Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Text('Invoice Date', style: TextStyle(color: appConstants.blackColor,fontFamily: appConstants.fontFamily,fontSize: 12, fontWeight: FontWeight.w400),),
                                                    Text(widget.invoiceData.invoiceDate.toString().replaceAll("/", ":"), style: TextStyle(color: appConstants.blackColor,fontFamily: appConstants.fontFamily,fontSize: 20, fontWeight: FontWeight.w800),
                                                      overflow: TextOverflow.ellipsis,)
                                                  ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
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
