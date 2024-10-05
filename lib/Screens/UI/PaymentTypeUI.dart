// ignore_for_file: use_build_context_synchronously

import 'package:mymerchant/Database/databaseController.dart';
import 'package:mymerchant/Model/OrderResponse.dart';
import 'package:mymerchant/Resources/constant.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'OrderListUI.dart';
import 'package:mymerchant/Resources/global.dart' as global;

// ignore: camel_case_types, must_be_immutable
class paymentTypeUI extends StatefulWidget {
  int amount;
  paymentTypeUI({
    required this.amount,
    Key? key,
  }) : super(key: key);

  @override
  State<paymentTypeUI> createState() => _paymentTypeUIState();
}

// ignore: camel_case_types
class _paymentTypeUIState extends State<paymentTypeUI> {
  TextEditingController paymentAmountTE = TextEditingController(text: '');
  String paymentMode = 'Cash';
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    setState(() {
      paymentAmountTE.text = widget.amount.toString();
    });
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<MyList>(builder: (context, myList, child) {
      return Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(7),
            boxShadow: [
              BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 6),
            ]),
        margin: const EdgeInsets.only(top: 5, left: 10, right: 10, bottom: 5),
        child: SizedBox(
          height: 40,
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Row(
              children: [
                Form(
                  key: _formKey,
                  child: Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0, top: 2,bottom: 2),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                height: 36,
                                width:200,
                                child: TextFormField(
                                  controller: paymentAmountTE,
                                  readOnly: true,
                                  cursorHeight: 20,
                                  cursorWidth: 2,
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                    color: appConstants.blackColor,
                                    fontFamily: appConstants.fontFamily,
                                    fontSize: 18,
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
                              SizedBox(
                                height: 30,
                                width: 100,
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
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
