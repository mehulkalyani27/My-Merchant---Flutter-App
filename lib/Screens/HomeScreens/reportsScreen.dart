// import 'package:mymerchant/Resources/constant.dart';
// import 'package:flutter/material.dart';
// //import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';
// import 'package:syncfusion_flutter_pdf/pdf.dart';
// import 'package:top_snackbar_flutter/custom_snack_bar.dart';
// import 'package:top_snackbar_flutter/top_snack_bar.dart';
// import '../../Model/OrderResponse.dart';
// import '../../Resources/save_file_mobile.dart';
// import 'package:intl/intl.dart';
// import 'package:mymerchant/Resources/global.dart' as global;
//
// class ReportScreen extends StatefulWidget {
//   const ReportScreen({Key? key}) : super(key: key);
//   @override
//   State<ReportScreen> createState() => _ReportScreenState();
// }

//
// class _ReportScreenState extends State<ReportScreen> {
//
//   bool isLoading = false;
//   bool permissionGranted =false;
//   var _tabTextIconIndexSelected = 0;
//
//   @override void initState()  {
//     super.initState();
//     //getData();
//   }
//
//
//   // void filterData() async{
//   //   //Filtering Orders
//   //   for (var element in orderList) {
//   //     //Filtering Order Year-Wise
//   //     if(element.date?.year==DateTime.now().year){
//   //       yearlyOrderList.add(element);
//   //       //Filtering Order Month-Wise
//   //       if(element.date?.month==DateTime.now().month){
//   //         monthlyOrderList.add(element);
//   //         //Filtering Order Week-Wise
//   //         DateTime getDate(DateTime d) => DateTime(d.year, d.month, d.day);
//   //         final date = DateTime.now();
//   //         DateTime startWeekDate = getDate(date.subtract(Duration(days: date.weekday - 1)));
//   //         for(int i=0;i<7;i++){
//   //           if(element.date==startWeekDate){
//   //             weeklyOrderList.add(element);
//   //
//   //             if(element.date?.day==DateTime.now().day){
//   //               dailyOrderList.add(element);
//   //             }
//   //           }
//   //           startWeekDate = getDate(startWeekDate.add(const Duration(days: 1)));
//   //         }
//   //       }
//   //     }
//   //   }
//   // }
//
//   // void getData() async{
//   //   setState(() {
//   //     isLoading = true;
//   //   });
//   //   SharedPreferences prefs = await SharedPreferences.getInstance();
//   //   setState(() {
//   //     global.employeeName=prefs.getString("employeeName")!;
//   //   });
//   //
//   //   if(orderList.isNotEmpty){
//   //     filterData();
//   //     if(mounted){
//   //       setState(() {
//   //         isLoading = false;
//   //       });
//   //     }
//   //   }
//   //   else{
//   //     if(mounted){
//   //       setState(() {
//   //         isLoading = false;
//   //       });
//   //     }
//   //     // ignore: use_build_context_synchronously
//   //     showTopSnackBar(
//   //       context,
//   //       const CustomSnackBar.error(
//   //         message: 'No Records Found',
//   //       ),
//   //     );
//   //   }
//   // }
//
//
//   // Future<void> generateReport(List<OrderList> generateOrderList) async {
//   //   if(generateOrderList.isNotEmpty){
//   //     //Create a PDF document.
//   //     final PdfDocument document = PdfDocument();
//   //     //Add page to the PDF
//   //     final PdfPage page = document.pages.add();
//   //     //Get page client size
//   //     final Size pageSize = page.getClientSize();
//   //     //Draw rectangle
//   //     page.graphics.drawRectangle(
//   //         bounds: Rect.fromLTWH(0, 0, pageSize.width, pageSize.height),
//   //         pen: PdfPen(PdfColor(142, 170, 219)));
//   //     //Generate PDF grid.
//   //     final PdfGrid grid = getGrid(generateOrderList);
//   //     //Draw the header section by creating text element
//   //     final PdfLayoutResult result = drawHeader(page, pageSize, grid);
//   //     //Draw grid
//   //     drawGrid(page, grid, result);
//   //     //Add invoice footer
//   //     drawFooter(page, pageSize);
//   //     //Save the PDF document
//   //     final List<int> bytes = document.saveSync();
//   //     //Dispose the document.
//   //     document.dispose();
//   //     //Save and launch the file.
//   //     await saveAndLaunchFile(bytes, 'Reports_${global.employeeName}${DateTime.now().toString().substring(0,19)}.pdf');
//   //   }
//   //   else{
//   //     showTopSnackBar(
//   //       context,
//   //       const CustomSnackBar.error(
//   //         message: 'No Records Found',
//   //       ),
//   //     );
//   //   }
//   // }
//
//   //Draws the invoice header
//   // PdfLayoutResult drawHeader(PdfPage page, Size pageSize, PdfGrid grid) {
//   //   final DateFormat format = DateFormat.yMMMMd('en_US');
//   //   //Draw rectangle
//   //   page.graphics.drawRectangle(
//   //       brush: PdfSolidBrush(PdfColor(91, 126, 215)),
//   //       bounds: Rect.fromLTWH(0, 0, pageSize.width - 115, 90));
//   //   //Draw string
//   //   page.graphics.drawString(
//   //       'Reports', PdfStandardFont(PdfFontFamily.helvetica, 30),
//   //       brush: PdfBrushes.white,
//   //       bounds: Rect.fromLTWH(25, 0, pageSize.width - 115, 90),
//   //       format: PdfStringFormat(lineAlignment: PdfVerticalAlignment.middle));
//   //
//   //   page.graphics.drawRectangle(
//   //       bounds: Rect.fromLTWH(400, 0, pageSize.width - 400, 90),
//   //       brush: PdfSolidBrush(PdfColor(65, 104, 205)));
//   //
//   //   page.graphics.drawString(format.format(DateTime.now()),
//   //       PdfStandardFont(PdfFontFamily.helvetica, 14),
//   //       bounds: Rect.fromLTWH(400, 0, pageSize.width - 400, 100),
//   //       brush: PdfBrushes.white,
//   //       format: PdfStringFormat(
//   //           alignment: PdfTextAlignment.center,
//   //           lineAlignment: PdfVerticalAlignment.middle));
//   //
//   //   final PdfFont contentFont = PdfStandardFont(PdfFontFamily.helvetica, 12);
//   //   //Draw string
//   //   page.graphics.drawString('Date', contentFont,
//   //       brush: PdfBrushes.white,
//   //       bounds: Rect.fromLTWH(400, 0, pageSize.width - 400, 33),
//   //       format: PdfStringFormat(
//   //           alignment: PdfTextAlignment.center,
//   //           lineAlignment: PdfVerticalAlignment.bottom));
//   //
//   //   final String invoiceNumber = 'Invoice Number: 2058557939\r\n\r\nDate: ${format.format(DateTime.now())}';
//   //   final Size contentSize = contentFont.measureString(invoiceNumber);
//   //   // ignore: leading_newlines_in_multiline_strings
//   //   String address = '''To: \r\n\r\n ${global.employeeName.toString()}''';
//   //
//   //   // PdfTextElement(text: invoiceNumber, font: contentFont).draw(
//   //   //     page: page,
//   //   //     bounds: Rect.fromLTWH(pageSize.width - (contentSize.width + 30), 120,
//   //   //         contentSize.width + 30, pageSize.height - 120));
//   //
//   //   return PdfTextElement(text: address, font: contentFont).draw(
//   //       page: page,
//   //       bounds: Rect.fromLTWH(30, 120,
//   //           pageSize.width - (contentSize.width + 30), pageSize.height - 120))!;
//   // }
//
//   //Draws the grid
//   void drawGrid(PdfPage page, PdfGrid grid, PdfLayoutResult result) {
//     Rect? totalPriceCellBounds;
//     Rect? quantityCellBounds;
//     //Invoke the beginCellLayout event.
//     grid.beginCellLayout = (Object sender, PdfGridBeginCellLayoutArgs args) {
//       final PdfGrid grid = sender as PdfGrid;
//       if (args.cellIndex == grid.columns.count - 1) {
//         totalPriceCellBounds = args.bounds;
//       } else if (args.cellIndex == grid.columns.count - 2) {
//         quantityCellBounds = args.bounds;
//       }
//     };
//     //Draw the PDF grid and get the result.
//     result = grid.draw(
//         page: page, bounds: Rect.fromLTWH(0, result.bounds.bottom + 40, 0, 0))!;
//
//     //Draw grand total.
//     page.graphics.drawString('Grand Total',
//         PdfStandardFont(PdfFontFamily.helvetica, 9, style: PdfFontStyle.bold),
//         bounds: Rect.fromLTWH(
//             quantityCellBounds!.left,
//             result.bounds.bottom + 10,
//             quantityCellBounds!.width,
//             quantityCellBounds!.height));
//     page.graphics.drawString(getTotalAmount(grid).toString(),
//         PdfStandardFont(PdfFontFamily.helvetica, 9, style: PdfFontStyle.bold),
//         bounds: Rect.fromLTWH(
//             totalPriceCellBounds!.left,
//             result.bounds.bottom + 10,
//             totalPriceCellBounds!.width,
//             totalPriceCellBounds!.height));
//   }
//
//   //Draw the invoice footer data.
//   void drawFooter(PdfPage page, Size pageSize) {
//     final PdfPen linePen =
//     PdfPen(PdfColor(142, 170, 219), dashStyle: PdfDashStyle.custom);
//     linePen.dashPattern = <double>[3, 3];
//     //Draw line
//     page.graphics.drawLine(linePen, Offset(0, pageSize.height - 100),
//         Offset(pageSize.width, pageSize.height - 100));
//   }
//
//   //Create PDF grid and return
//   // PdfGrid getGrid(List<OrderList> generateOrderList) {
//   //   //Create a PDF grid
//   //   final PdfGrid grid = PdfGrid();
//   //   //Specify the columns count to the grid.
//   //   grid.columns.add(count: 5);
//   //   //Create the header row of the grid.
//   //   final PdfGridRow headerRow = grid.headers.add(1)[0];
//   //   //Set style
//   //   headerRow.style.backgroundBrush = PdfSolidBrush(PdfColor(68, 114, 196));
//   //   headerRow.style.textBrush = PdfBrushes.white;
//   //   headerRow.cells[0].value = 'No';
//   //   headerRow.cells[0].stringFormat.alignment = PdfTextAlignment.center;
//   //   headerRow.cells[1].value = 'Customer Name';
//   //   headerRow.cells[2].value = 'Invoice-No';
//   //   headerRow.cells[3].value = 'Quantities';
//   //   headerRow.cells[4].value = 'Total';
//   //   int i=1;
//   //   for (var element in generateOrderList) {
//   //     addOrders(i.toString(), element.customerName.toString(), element.projectId.toString(), element.quantity!, element.orderTotal!, grid);
//   //     i++;
//   //   }
//   //   //Apply the table built-in style
//   //   grid.applyBuiltInStyle(PdfGridBuiltInStyle.listTable4Accent5);
//   //   //Set gird columns width
//   //   grid.columns[1].width = 200;
//   //   for (int i = 0; i < headerRow.cells.count; i++) {
//   //     headerRow.cells[i].style.cellPadding =
//   //         PdfPaddings(bottom: 5, left: 5, right: 5, top: 5);
//   //   }
//   //   for (int i = 0; i < grid.rows.count; i++) {
//   //     final PdfGridRow row = grid.rows[i];
//   //     for (int j = 0; j < row.cells.count; j++) {
//   //       final PdfGridCell cell = row.cells[j];
//   //       if (j == 0) {
//   //         cell.stringFormat.alignment = PdfTextAlignment.center;
//   //       }
//   //       cell.style.cellPadding = PdfPaddings(bottom: 5, left: 5, right: 5, top: 5);
//   //     }
//   //   }
//   //   return grid;
//   // }
//
//   //Create and row for the grid.
//   void addOrders(String serialNumber, String customerName, String invoiceNumber,
//       int quantity, double total, PdfGrid grid) {
//     final PdfGridRow row = grid.rows.add();
//     row.cells[0].value = serialNumber;
//     row.cells[1].value = customerName;
//     row.cells[2].value = invoiceNumber.toString();
//     row.cells[3].value = quantity.toString();
//     row.cells[4].value = total.toString();
//   }
//
//   //Get the total amount.
//   String getTotalAmount(PdfGrid grid) {
//     double total = 0;
//     for (int i = 0; i < grid.rows.count; i++) {
//       final String value =
//       grid.rows[i].cells[grid.columns.count - 1].value as String;
//       total += double.parse(value);
//     }
//     return total.toStringAsFixed(2);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope( onWillPop: () async => false,
//       child: Scaffold(
//         appBar: AppBar(
//           centerTitle: true,
//           title: Text(appConstants.appTitle,style: TextStyle(fontFamily: appConstants.fontFamily)),
//           backgroundColor: appConstants.defaultColor,
//           automaticallyImplyLeading: false,
//         ),
//         body: SingleChildScrollView(
//           child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children:[
//                 const SizedBox(height: 5),
//                 Card(
//                     child: SizedBox(
//                         height: MediaQuery.of(context).size.height*0.05,
//                         width: MediaQuery.of(context).size.width,
//                         child: Center(
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Icon(Icons.note,color: appConstants.defaultColor),
//                               Padding(
//                                 padding: const EdgeInsets.only(left: 5.0),
//                                 child: Text('Reports',style: TextStyle(color: appConstants.defaultColor, fontWeight: FontWeight.w600, fontFamily: appConstants.fontFamily,fontSize: 22)),
//                               ),
//                             ],
//                           ),
//                         )
//                     )
//                 ),
//                 const SizedBox(height: 10),
//                 Center(
//                   child: Container(
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(7.5),
//                       border: Border.all(color: appConstants.blackColor.withOpacity(0.3))
//                     ),
//                     child: FlutterToggleTab(
//                       width: MediaQuery.of(context).size.width*0.2,
//                       height: 40,
//                       borderRadius: 7.5,
//                       selectedTextStyle: TextStyle(color: appConstants.whiteColor, fontSize: 14, fontWeight: FontWeight.w600,fontFamily: appConstants.fontFamily),
//                       selectedBackgroundColors: [appConstants.defaultColor],
//                       unSelectedBackgroundColors: [appConstants.whiteColor],
//                       unSelectedTextStyle: TextStyle(color: appConstants.tealColor, fontSize: 14, fontWeight: FontWeight.w400, fontFamily: appConstants.fontFamily),
//                       labels: const ['Daily','Week','Month','Year'],
//                       selectedIndex: _tabTextIconIndexSelected,
//                       selectedLabelIndex: (index) {
//                         setState(() {
//                           _tabTextIconIndexSelected = index;
//                         });
//                       },
//                       marginSelected: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.only(top: 100.0),
//                   child: Center(
//                     child: SizedBox(
//                       height: 46,
//                       width: 190,
//                       child: ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: appConstants.cirightBlue,
//                           ),
//                         onPressed: (){
//                           // _tabTextIconIndexSelected==1? generateReport(weeklyOrderList)
//                           //     : _tabTextIconIndexSelected==2?  generateReport(monthlyOrderList)
//                           //     : _tabTextIconIndexSelected==3?  generateReport(yearlyOrderList)
//                           //     : generateReport(dailyOrderList);
//                         },
//                           child: isLoading? SizedBox(
//                             height: 16,
//                             width: 16,
//                             child: CircularProgressIndicator(color: appConstants.whiteColor),
//                           ) : Text('Generate Reports', style: TextStyle(color: appConstants.whiteColor, fontWeight: FontWeight.w500, fontFamily: appConstants.fontFamily,fontSize: 16))),
//                     ),
//                   ),
//                 ),
//               ]
//           ),
//         ),
//       ),
//     );
//   }
// }