// ignore_for_file: must_be_immutable, file_names
import 'package:mymerchant/Model/Invoice.dart';
import 'package:mymerchant/Model/OrderResponse.dart';
import 'package:mymerchant/Resources/constant.dart';
import 'package:flutter/material.dart';
import 'package:mymerchant/Screens/HomeScreens/viewOrderScreen.dart';


// ignore: camel_case_types
// ignore: camel_case_types
class orderUI extends StatefulWidget {
  int index;
  Invoice invoiceData;

  orderUI(
      {Key? key,
        required this.index,
        required this.invoiceData,
      })
      : super(key: key);

  @override
  State<orderUI> createState() => _orderUIState();
}




// ignore: camel_case_types
class _orderUIState extends State<orderUI> {

  List<OrderItem> productList = [];

  @override void initState() {
    super.initState();
    getData();
  }

  void getData() async {

  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
        height: 94,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 50,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Text("${widget.index.toString()}.",style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, fontFamily: appConstants.fontFamily,color: appConstants.indexColor)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Invoice : ${widget.invoiceData.invoiceNumber}",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, fontFamily: appConstants.fontFamily,color: appConstants.defaultColor),
                      ),
                      Text(
                        "Invoice Date: ${widget.invoiceData.invoiceDate.toString().replaceAll("/", ":")}",
                        style: TextStyle(fontFamily: appConstants.fontFamily,fontSize: 14),
                      ),
                      Text(
                        "Invoice Amount: \u20b9 ${widget.invoiceData.invoiceTotal}",
                        style: TextStyle(fontFamily: appConstants.fontFamily,fontSize: 14),
                      ),
                      Text(
                        "Payment Mode : ${widget.invoiceData.invoicePaymentMode}",
                        style: TextStyle(fontFamily: appConstants.fontFamily,fontSize: 14),
                      )
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder:(context) => ViewOrderScreen(invoiceData: widget.invoiceData)));
                },
                child: SizedBox(
                  height: 86,
                  width: 40,
                  child: Image.asset("assets/images/invoiceIcon.png"),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}