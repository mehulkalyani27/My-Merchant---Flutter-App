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
class orderItemUI extends StatefulWidget {
  OrderItem orderItem;
  int index;

  orderItemUI({
    Key? key,
    required this.orderItem,
    required this.index,
  }) : super(key: key);

  @override
  State<orderItemUI> createState() => _orderItemUIState();
}

// ignore: camel_case_types
class _orderItemUIState extends State<orderItemUI> {
  TextEditingController cProductNameTE = TextEditingController(text: '');
  TextEditingController cProductPriceTE = TextEditingController(text: '');
  TextEditingController cProductQtyTE = TextEditingController(text: '');
  TextEditingController cProductTotalTE = TextEditingController(text: '');
  TextEditingController cProductMRPTE = TextEditingController(text: '');
  int itemId = 0;
  int qty = 0;
  int price = 0;
  int total = 0;
  int mrp = 0;
  String productName = '';
  bool invalidQty = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    setState(() {
      cProductNameTE = TextEditingController(text: widget.orderItem.itemName);
      productName = widget.orderItem.itemName.toString();
      cProductPriceTE = TextEditingController(text: widget.orderItem.price.toString());
      price = int.parse(widget.orderItem.price.toString());
      cProductMRPTE = TextEditingController(text: widget.orderItem.mrp.toString());
      mrp = int.parse(widget.orderItem.mrp.toString());
      cProductQtyTE = TextEditingController(text: widget.orderItem.qty.toString());
      qty = int.parse(widget.orderItem.qty.toString());
      cProductTotalTE = TextEditingController(text: widget.orderItem.total.toString());
      total = int.parse(widget.orderItem.total.toString());
      itemId = widget.orderItem.itemId!;
    });
    cProductPriceTE.addListener(() {
      if (cProductPriceTE.text.isNotEmpty && cProductQtyTE.text.isNotEmpty) {
        setState(() {
          cProductTotalTE.text = (int.parse(cProductPriceTE.text) * int.parse(cProductQtyTE.text)).toString();
        });
      } else {
        setState(() {
          cProductTotalTE.clear();
        });
      }
    });
    cProductQtyTE.addListener(() {
      if (cProductPriceTE.text.isNotEmpty && cProductQtyTE.text.isNotEmpty) {
        setState(() {
          cProductTotalTE.text = (int.parse(cProductPriceTE.text) * int.parse(cProductQtyTE.text)).toString();
        });
      } else {
        setState(() {
          cProductTotalTE.clear();
        });
      }
    });
    cProductMRPTE.addListener(() {
      if(cProductMRPTE.text.isNotEmpty){
        setState(() {
          cProductPriceTE.text = cProductMRPTE.text;
        });
      }
      else{
        cProductPriceTE.clear();
      }
    });
  }

  void setNullFunction(){
    setState(() {
      qty = 0;
      total = price * qty;
    });
    MyList myList = Provider.of<MyList>(context, listen: false);
    OrderItem item =  OrderItem(itemId: itemId, itemName: productName, qty: qty, price: price, total: total, mrp: mrp);
    myList.updateItem(widget.index, item);
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
              BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 6),
            ]),
        margin: const EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 5),
        child: SizedBox(
          height: 154,
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Row(
              children: [
                Form(
                  key: _formKey,
                  child: Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0, top: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 5.0),
                                child: SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: Text('${(widget.index+1)}.',style: TextStyle(color: appConstants.indexColor,fontWeight: FontWeight.w600),),
                                ),
                              ),
                              Column(
                                children: [
                                  const SizedBox(height: 3),
                                  SizedBox(
                                    height: 50,
                                    width: MediaQuery.of(context).size.width * 0.4,
                                    child: TextFormField(
                                      readOnly: global.isEditing,
                                      onChanged: (value) {
                                        if(value.isEmpty){
                                          setState(() {
                                            productName = '';
                                            total = 0;
                                            cProductTotalTE.text = '0';
                                          });
                                          MyList myList = Provider.of<MyList>(context, listen: false);
                                          OrderItem item = OrderItem(
                                              itemId: itemId,
                                              mrp: mrp,
                                              itemName: productName,
                                              qty: qty,
                                              price: price,
                                              total: total);
                                          myList.updateItem(widget.index, item);
                                        }
                                        else {
                                          setState(() {
                                            price = int.parse(cProductPriceTE.text);
                                            qty = int.parse(cProductQtyTE.text);
                                            productName = value;
                                            total = price * qty;
                                            cProductTotalTE.text = total.toString();
                                          });
                                          MyList myList = Provider.of<MyList>(context, listen: false);
                                          OrderItem item = OrderItem(
                                              itemId: itemId,
                                              mrp: mrp,
                                              itemName: productName,
                                              qty: qty,
                                              price: price,
                                              total: total);
                                          myList.updateItem(widget.index, item);
                                        }
                                        setState(() {
                                          global.formValidate=_formKey.currentState!.validate();
                                        });
                                        },
                                      controller: cProductNameTE,
                                      minLines: 1,
                                      cursorWidth: 2,
                                      cursorHeight: 16,
                                      textAlignVertical: TextAlignVertical.center,
                                      textAlign: TextAlign.start,
                                      autovalidateMode: AutovalidateMode.onUserInteraction,
                                      validator: appConstants.validateProductNameNon,
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
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        children: [
                                          SizedBox(
                                            width:  100,
                                            child: TextFormField(
                                              readOnly: global.isEditing,
                                              onChanged: (value){
                                                RegExp regex = RegExp(r"^\d*\.?\d*$|^-\d*\.?\d*$");
                                                if(value.isEmpty || regex.hasMatch(value)==false){
                                                  setState(() {
                                                    mrp = 0;
                                                    price = 0;
                                                    total = price * qty;
                                                    cProductTotalTE = TextEditingController(text: '0');
                                                  });
                                                  MyList myList = Provider.of<MyList>(context, listen: false);
                                                  OrderItem item = OrderItem(
                                                      itemId: itemId,
                                                      itemName: productName, qty: qty, price: price, total: total,mrp: mrp);
                                                  myList.updateItem(widget.index, item);
                                                }else{
                                                  setState(() {
                                                    mrp = int.parse(value);
                                                    price = mrp;
                                                    total = price * qty;
                                                    cProductTotalTE.text = total.toString();
                                                  });
                                                  MyList myList = Provider.of<MyList>(context, listen: false);
                                                  OrderItem item = OrderItem(
                                                      itemId: itemId,
                                                      itemName: productName, qty: qty, price: price, total: total,mrp: mrp);
                                                  myList.updateItem(widget.index, item);
                                                }
                                                setState(() {
                                                  global.formValidate = _formKey.currentState!.validate();
                                                });
                                              },
                                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                              controller: cProductMRPTE,
                                              cursorHeight: 16,
                                              cursorWidth: 2,
                                              textAlignVertical: TextAlignVertical.center,
                                              textAlign: TextAlign.end,
                                              validator: appConstants.validateNumericNotEmptyDouble,
                                              autovalidateMode: AutovalidateMode.onUserInteraction,
                                              style: TextStyle(
                                                  color: appConstants.blackColor,
                                                  fontFamily: appConstants.fontFamily,
                                                  fontSize: 14),
                                              decoration: InputDecoration(
                                                labelText: 'MRP',
                                                labelStyle: TextStyle(
                                                    color: appConstants.blackColor,
                                                    fontFamily: appConstants.fontFamily),
                                                contentPadding: const EdgeInsets.symmetric(
                                                    vertical: 5.0, horizontal: 10.0),
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
                                          const SizedBox(width: 10),
                                          SizedBox(
                                            width: 100,
                                            child: TextFormField(
                                              readOnly: global.isEditing,
                                                onChanged: (value){
                                                  RegExp regex = RegExp(r"^\d*\.?\d*$|^-\d*\.?\d*$");
                                                  if(value.isEmpty || regex.hasMatch(value)==false){
                                                      setState(() {
                                                        price = 0;
                                                        total = price * qty;
                                                        cProductTotalTE = TextEditingController(text: '0');
                                                      });
                                                    MyList myList = Provider.of<MyList>(context, listen: false);
                                                    OrderItem item = OrderItem(
                                                      itemId: itemId,
                                                        itemName: productName, qty: qty, price: price, total: total,mrp: mrp);
                                                    myList.updateItem(widget.index, item);
                                                  }else{
                                                      setState(() {
                                                        price = int.parse(value);
                                                        total = price * qty;
                                                        cProductTotalTE.text = total.toString();
                                                      });
                                                      MyList myList = Provider.of<MyList>(context, listen: false);
                                                      OrderItem item = OrderItem(
                                                        itemId: itemId,
                                                          itemName: productName, qty: qty, price: price, total: total, mrp: mrp);
                                                      myList.updateItem(widget.index, item);
                                                    }
                                                  setState(() {
                                                    global.formValidate = _formKey.currentState!.validate();
                                                  });
                                                  },
                                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                              controller: cProductPriceTE,
                                              cursorHeight: 16,
                                              cursorWidth: 2,
                                              textAlignVertical: TextAlignVertical.center,
                                              textAlign: TextAlign.end,
                                              validator: appConstants.validateNumericNotEmptyDouble,
                                              autovalidateMode: AutovalidateMode.onUserInteraction,
                                              style: TextStyle(
                                                  color: appConstants.blackColor,
                                                  fontFamily: appConstants.fontFamily,
                                                  fontSize: 14),
                                              decoration: InputDecoration(
                                                labelText: 'Price',
                                                labelStyle: TextStyle(
                                                    color: appConstants.blackColor,
                                                    fontFamily: appConstants.fontFamily),
                                                contentPadding: const EdgeInsets.symmetric(
                                                    vertical: 5.0, horizontal: 10.0),
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
                                          const SizedBox(width: 20,child: Center(child: Text("x",style: TextStyle(fontSize: 12)))),
                                          SizedBox(
                                            width: 60,
                                            child: TextFormField(
                                              readOnly: global.isEditing,
                                              autovalidateMode: AutovalidateMode.onUserInteraction,
                                              onChanged: (value) async {
                                                RegExp regex = RegExp(r"^\d*\.?\d*$|^-\d*\.?\d*$");
                                                if(value.isEmpty || regex.hasMatch(price.toString())==false){
                                                  setState(() {
                                                    qty = 0;
                                                    total = price * qty;
                                                    cProductTotalTE = TextEditingController(text: '0');
                                                  });
                                                  MyList myList = Provider.of<MyList>(context, listen: false);
                                                  OrderItem item = OrderItem(
                                                    itemId: itemId,
                                                      itemName: productName, qty: qty, price: price, total: total,mrp: mrp);
                                                  myList.updateItem(widget.index, item);
                                                }else{
                                                  int? databaseQuantity;
                                                  databaseQuantity = await DbManager.getProductQuantity(widget.orderItem.itemId!);
                                                  debugPrint(databaseQuantity.toString());
                                                  if(databaseQuantity! >= int.parse(cProductQtyTE.text)){
                                                    setState(() {
                                                      qty = int.parse(value);
                                                      total = price * qty;
                                                      cProductTotalTE.text = total.toString();
                                                    });
                                                    MyList myList = Provider.of<MyList>(context, listen: false);
                                                    OrderItem item = OrderItem(
                                                      itemId: itemId,
                                                        itemName: productName, qty: qty, price: price, total: total,mrp: mrp);
                                                    myList.updateItem(widget.index, item);
                                                  }
                                                  else{
                                                    setState(() {
                                                      qty = 0;
                                                      total = price * qty;
                                                      cProductTotalTE = TextEditingController(text: '0');
                                                    });
                                                    MyList myList = Provider.of<MyList>(context, listen: false);
                                                    OrderItem item = OrderItem(
                                                      itemId: itemId,
                                                        itemName: productName, qty: qty, price: price, total: total,mrp: mrp);
                                                    myList.updateItem(widget.index, item);
                                                    showTopSnackBar(
                                                      context,
                                                      const CustomSnackBar.error(
                                                        message: 'Quantity must be less than Stock Quantity',
                                                      ),
                                                    );
                                                  }
                                                }
                                                setState(() {
                                                  global.formValidate = _formKey.currentState!.validate();
                                                });
                                              },
                                              keyboardType: const TextInputType.numberWithOptions(decimal: false),
                                              controller: cProductQtyTE,
                                              cursorWidth: 2,
                                              cursorHeight: 16,
                                              textAlignVertical: TextAlignVertical.center,
                                              textAlign: TextAlign.end,
                                              validator: appConstants.validateNumericNotEmptyInteger,
                                              style: TextStyle(color: appConstants.blackColor, fontFamily: appConstants.fontFamily, fontSize: 14),
                                              decoration: InputDecoration(
                                                labelText: 'Qty',
                                                labelStyle: TextStyle(color: appConstants.blackColor, fontFamily: appConstants.fontFamily),
                                                contentPadding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                                                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: appConstants.defaultColor), borderRadius: BorderRadius.circular(8)),
                                                focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide(color: appConstants.errorColor), borderRadius: BorderRadius.circular(8)),
                                                errorBorder: OutlineInputBorder(borderSide: BorderSide(color: appConstants.errorColor), borderRadius: BorderRadius.circular(8)),
                                                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: appConstants.blackColor), borderRadius: BorderRadius.circular(8)),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 20,child: Center(child: Text("=",style: TextStyle(fontSize: 12)))),
                                      SizedBox(
                                        width: 100,
                                        child: TextFormField(
                                          readOnly: true,
                                          controller: cProductTotalTE,
                                          cursorWidth: 2,
                                          cursorHeight: 16,
                                          textAlignVertical: TextAlignVertical.center,
                                          textAlign: TextAlign.end,
                                          style: TextStyle(color: appConstants.blackColor, fontFamily: appConstants.fontFamily, fontSize: 14, fontWeight: FontWeight.w700),
                                          decoration: InputDecoration(contentPadding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                                            labelText: 'Total',
                                            labelStyle: TextStyle(color: appConstants.blackColor, fontFamily: appConstants.fontFamily, fontWeight: FontWeight.w600),
                                            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: appConstants.defaultColor), borderRadius: BorderRadius.circular(8)),
                                            focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide(color: appConstants.errorColor),borderRadius: BorderRadius.circular(8)),
                                            errorBorder: OutlineInputBorder(borderSide: BorderSide(color: appConstants.errorColor), borderRadius: BorderRadius.circular(8)),
                                            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: appConstants.blackColor), borderRadius: BorderRadius.circular(8)),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text('Product ID : ${widget.orderItem.itemId.toString()}',style: TextStyle(fontSize: 8,fontFamily: appConstants.fontFamily)),
                          )
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
