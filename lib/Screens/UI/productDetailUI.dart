// ignore_for_file: file_names

import 'package:mymerchant/Model/OrderResponse.dart';
import 'package:mymerchant/Resources/constant.dart';
import 'package:flutter/material.dart';


// ignore: must_be_immutable
class ViewOrderUI extends StatefulWidget {
  int index;
  OrderItem productDetails;


  ViewOrderUI(
      {Key? key,
        required this.index,
        required this.productDetails,
      })
      : super(key: key);

  @override
  State<ViewOrderUI> createState() => _ViewOrderUIState();
}

class _ViewOrderUIState extends State<ViewOrderUI> {

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
        height: 74,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: 40,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Text("${widget.index}.",style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, fontFamily: appConstants.fontFamily,color: appConstants.indexColor)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width : 700,
                        child: Text("${widget.productDetails.itemName}",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, fontFamily: appConstants.fontFamily,color: appConstants.defaultColor),
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Row(
                          children: [
                            Text("Item ID : ${widget.productDetails.itemId}",
                              style: TextStyle(fontFamily: appConstants.fontFamily,fontSize: 16,color: appConstants.tealColor),
                            ),
                            const SizedBox(width: 40),
                            Text("MRP : ${widget.productDetails.mrp}",
                              style: TextStyle(fontFamily: appConstants.fontFamily,fontSize: 16,color: appConstants.tealColor),
                            ),
                            const SizedBox(width: 40),
                            Text("${widget.productDetails.price}",
                              style: TextStyle(fontFamily: appConstants.fontFamily,fontSize: 16,color: appConstants.tealColor),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8,right: 8),
                              child: Text("x",
                                style: TextStyle(fontFamily: appConstants.fontFamily,fontSize: 14),
                              ),
                            ),
                            Text("${widget.productDetails.qty}",
                              style: TextStyle(fontFamily: appConstants.fontFamily,fontSize: 16,color: appConstants.tealColor),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(right: 5),
              child: Text('${int.parse(widget.productDetails.price.toString())*int.parse(widget.productDetails.qty.toString())}',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 18,fontFamily: appConstants.fontFamily,fontWeight: FontWeight.w700),
              )
            )
          ],
        ),
      ),
    );
  }
}