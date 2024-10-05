// ignore_for_file: must_be_immutable, file_names
import 'package:mymerchant/Model/Invoice.dart';
import 'package:mymerchant/Model/OrderResponse.dart';
import 'package:flutter/material.dart';
import 'package:mymerchant/Resources/constant.dart';

// ignore: camel_case_types
// ignore: camel_case_types
class salesProductUI extends StatefulWidget {
  SalesOrderItem salesOrderItem;

  salesProductUI(
      {Key? key,
        required this.salesOrderItem,
      })
      : super(key: key);

  @override
  State<salesProductUI> createState() => _salesProductUIState();
}




// ignore: camel_case_types
class _salesProductUIState extends State<salesProductUI> {

  @override void initState() {
    super.initState();
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
        height: 84,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${widget.salesOrderItem.itemName}",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, fontFamily: appConstants.fontFamily,color: appConstants.defaultColor),
                  ),
                  Text(
                    "Invoice Number: ${widget.salesOrderItem.invoiceNumber}",
                    style: TextStyle(fontFamily: appConstants.fontFamily,fontSize: 14),
                  ),
                  Text(
                    "Invoice Date: ${widget.salesOrderItem.invoiceDate.toString().replaceAll("/", ":")}",
                    style: TextStyle(fontFamily: appConstants.fontFamily,fontSize: 14),
                  ),
                  Text(
                    "Payment Mode : ${widget.salesOrderItem.paymentMode}",
                    style: TextStyle(fontFamily: appConstants.fontFamily,fontSize: 14),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("${widget.salesOrderItem.total}",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, fontFamily: appConstants.fontFamily,color: appConstants.defaultColor),
                  ),
                  Text(
                    "MRP: ${widget.salesOrderItem.mrp}",
                    style: TextStyle(fontFamily: appConstants.fontFamily,fontSize: 14),
                  ),
                  Text(
                    "Price : ${widget.salesOrderItem.price}",
                    style: TextStyle(fontFamily: appConstants.fontFamily,fontSize: 14),
                  ),
                  Text(
                    "Qty: ${widget.salesOrderItem.qty}",
                    style: TextStyle(fontFamily: appConstants.fontFamily,fontSize: 14),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}