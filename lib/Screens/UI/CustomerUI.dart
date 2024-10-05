// ignore_for_file: file_names
import 'package:mymerchant/Resources/constant.dart';
import 'package:flutter/material.dart';



// ignore: must_be_immutable
class CustomerUI extends StatefulWidget {
  int index;
  String customerName;

  CustomerUI(
      {Key? key,
        required this.index,
        required this.customerName,
      })
      : super(key: key);

  @override
  State<CustomerUI> createState() => _CustomerUIState();
}

class _CustomerUIState extends State<CustomerUI> {

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
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
              ExpansionTile(
                iconColor: appConstants.defaultColor,
                leading: Text("${widget.index.toString()}.",style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, fontFamily: appConstants.fontFamily,color: appConstants.indexColor)),
                title: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.account_circle,size: 36,color: appConstants.blackColor),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Text(widget.customerName,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, fontFamily: appConstants.fontFamily, color: appConstants.cirightBlue),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.start,
                      ),
                    ),
                  ],
                ),
            ),
          ],
        ),
      ),
    );
  }
}

