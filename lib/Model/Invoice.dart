// ignore_for_file: file_names
// Upload Invoice URL
//https://script.google.com/macros/s/AKfycbws6b4VLXhMv7QMNARYQ0XQzULKYEo7yVT8w_IzcDvaTq-R4GEUxibUq43d8LxvWQ/exec
//Deployment ID
//AKfycbws6b4VLXhMv7QMNARYQ0XQzULKYEo7yVT8w_IzcDvaTq-R4GEUxibUq43d8LxvWQ
import 'package:mymerchant/Model/OrderResponse.dart';
import 'package:mymerchant/Model/Product.dart';

class InvoiceData{
  int? id;
  String? invoiceData;

  InvoiceData ({
    this.id,
    required this.invoiceData,
  });

  InvoiceData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    invoiceData = json['InvoiceData'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['InvoiceData'] = invoiceData;
    data['id'] = id;
    return data;
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    map['id'] = id;
    map["InvoiceData"] = invoiceData;
    return map;
  }

  InvoiceData.fromMap(Map<String, dynamic> map){
    id = map['id'];
    invoiceData = map["InvoiceData"];

  }

}

class Invoice {
  String? invoiceNumber;
  String? invoiceTotal;
  String? invoiceCustomer;
  String? invoiceDate;
  String? invoicePaymentMode;
  String? invoiceProductList;
  List<OrderItem>? invoiceListProduct;

  Invoice ({
    required this.invoiceNumber,
    required this.invoiceTotal,
    required this.invoiceDate,
    required this.invoiceCustomer,
    required this.invoicePaymentMode,
    required this.invoiceProductList,
    required this.invoiceListProduct,
  });


  Invoice.fromJson(Map<String, dynamic> json) {
    invoiceNumber = json['InvoiceNumber'];
    invoiceTotal = json['InvoiceTotal'];
    invoiceCustomer = json['InvoiceCustomer'];
    invoiceDate = json['InvoiceDate'];
    invoicePaymentMode = json['InvoicePaymentMode'];
    invoiceProductList = json['InvoiceProductList'];
    invoiceListProduct = json['InvoiceProductList'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['InvoiceNumber'] = invoiceNumber;
    data['InvoiceCustomer'] = invoiceCustomer;
    data['InvoiceTotal'] = invoiceTotal;
    data['InvoiceDate'] = invoiceDate;
    data['InvoicePaymentMode'] = invoicePaymentMode;
    data['InvoiceProductList'] = invoiceListProduct?.map((model) => model.toJson()).toList().toString();
    data['InvoiceProductList'] = invoiceListProduct?.map((model) => model.toJson()).toList().toString();
    return data;
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    map["InvoiceNumber"] = invoiceNumber;
    map["InvoiceCustomer"] = invoiceCustomer;
    map["InvoiceTotal"] = invoiceTotal;
    map["InvoiceDate"] = invoiceDate;
    map["InvoicePaymentMode"] = invoicePaymentMode;
    map["InvoiceProductList"] = invoiceProductList;
    return map;
  }

  Invoice.fromMap(Map<String, dynamic> map){
    invoiceNumber = map["InvoiceNumber"];
    invoiceCustomer = map["InvoiceCustomer"];
    invoiceTotal = map["InvoiceTotal"];
    invoiceDate = map["InvoiceDate"];
    invoicePaymentMode = map["InvoicePaymentMode"];
    invoiceProductList = map["InvoiceProductList"];
    invoiceListProduct = map["InvoiceProductList"];
  }

  printInvoice() {
    String itemRows = '';
    int items = 0;
    int quantity = 0;
    int savingAmount = 0;
    invoiceListProduct?.forEach((element) {
      int saved = 0;
      saved = (element.mrp! - element.price!) * element.qty!;
      savingAmount = savingAmount + saved;
      if (element.itemName!.length > 22) {
        itemRows += '${element.itemName?.toString().substring(0, 22)}   ${element.price?.toString().padLeft(6, " ")}   ${element.qty?.toString().padLeft(4, " ")}   ${element.total?.toString().padLeft(6, " ")}\n';
      }
      else {
        itemRows += '${element.itemName?.toString().padRight(22, " ")}   ${element.price.toString().toString().padLeft(6, " ")}   ${element.qty?.toString().padLeft(4, " ")}   ${element.total?.toString().padLeft(6, " ")}\n';
      }
      items++;
      quantity = quantity + element.qty!;
    });
    if (savingAmount > 44) {
      return '\x1B\x61\x01\x1B\x21\x10Toy Bytes\n\n'
          '\x1B\x61\x01\x1B\x21\x00G6, Nexus-III,\n'
          '\x1B\x61\x01\x1B\x21\x00Nadiad-Uttarsanda Road\n'
          '\x1B\x61\x01\x1B\x21\x00Nadiad- 387001\n'
          '\x1B\x61\x01\x1B\x21\x00toybytes@gmail.com\n'
          '\x1B\x61\x01\x1B\x21\x00GST IN : 24AAOFT3067E1Z4\n\n'
          '\x1B\x45\x01\x1B\x21\x00Retail Invoice \x1B\x45\x00\n\n'
          '\x1B\x61\x00\x1B\x21\x00Invoice Number : $invoiceNumber\n'
          '\x1B\x61\x00\x1B\x21\x00Invoice Date   : ${invoiceDate.toString().replaceAll("/", ":")}\n'
          '\x1B\x21\x00-----------------------------------------------\n'
          '\x1B\x21\x00Product                    Price     Qty   Total\n'
          '\x1B\x21\x00-----------------------------------------------\n'
          '\x1B\x21\x00$itemRows'
          '\x1B\x21\x00-----------------------------------------------\n'
          '\x1B\x21\x00Items/Qty : $items/$quantity                   Total: ${invoiceTotal.toString().padLeft(5," ")}\n'
          '\x1B\x21\x00Payment Mode :                              $invoicePaymentMode\n'
          '\x1B\x61\x01\x1B\x21\x00Saved Rs $savingAmount on MRP\n'
          '\x1B\x61\x01\x1B\x21\x10Thank You!\n'
          '\x1B\x61\x01\x1B\x21\x10Do visit Again!'
          '\x1B\x21\x01\nNo Return No Exchange\n'
          '\x1B\x21\x01No Warranty or Guarantee on any Product';
    }
    else {
      return
        '\x1B\x61\x01\x1B\x21\x10Toy Bytes\n'
            '\x1B\x61\x01\x1B\x21\x00G6, Nexus-III,\n'
            '\x1B\x61\x01\x1B\x21\x00Nadiad-Uttarsanda Road\n'
            '\x1B\x61\x01\x1B\x21\x00Nadiad- 387001\n'
            '\x1B\x61\x01\x1B\x21\x00toybytes@gmail.com\n'
            '\x1B\x61\x01\x1B\x21\x00GST IN : 24AAOFT3067E1Z4\n\n'
            '\x1B\x21\x00----------------------------------------------\n'
            '\x1B\x45\x01\x1B\x21\x00Retail Invoice\x1B\x45\x00\n'
            '\x1B\x21\x00----------------------------------------------\n'
            '\x1B\x61\x00\x1B\x21\x00Invoice Number : $invoiceNumber\n'
            '\x1B\x61\x00\x1B\x21\x00Invoice Date   : ${invoiceDate.toString().replaceAll("/", ":")}\n'
            '\x1B\x21\x00----------------------------------------------\n'
            '\x1B\x21\x00Product                    Price     Qty   Total\n'
            '\x1B\x21\x00-----------------------------------------------\n'
            '\x1B\x21\x00$itemRows'
            '\x1B\x21\x00-----------------------------------------------\n'
            '\x1B\x21\x00Items/Qty : $items/$quantity                   Total: ${invoiceTotal.toString().padLeft(5," ")}\n'
            '\x1B\x21\x00Payment Mode :                          $invoicePaymentMode\n\n'
            '\x1B\x61\x01\x1B\x21\x10Thank you!\n'
            '\x1B\x61\x01\x1B\x21\x10Do visit Again!\n'
            '\x1B\x21\x00\nNo Return No Exchange\n'
            '\x1B\x21\x00No Warranty or Guarantee on any Product';
    }
  }
}

class InvoiceDetails{
  List<Product>? productList;

  InvoiceDetails({
    required this.productList,
  });

  InvoiceDetails.fromJson(Map<String, dynamic> json) {
    productList= json['productList'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['productList'] = productList;
    return data;
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    map["ProductList"] = productList;
    return map;
  }

  InvoiceDetails.fromMap(Map<String, dynamic> map){
    productList = map["ProductList"];
  }
}

class OrderItemList{
  List<OrderItem>? productList;

  OrderItemList({
    required this.productList,
  });

  OrderItemList.fromJson(Map<String, dynamic> json) {
    productList= json['productList'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['productList'] = productList;
    return data;
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    map["ProductList"] = productList;
    return map;
  }

  OrderItemList.fromMap(Map<String, dynamic> map){
    productList = map["ProductList"];
  }
}
