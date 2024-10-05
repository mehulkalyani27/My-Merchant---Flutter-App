// ignore_for_file: camel_case_types

class Product {
  int? id;
  String? productName;
  String? productPrice;
  String? productMrp;
  String? quantity;
  String? productBarcode;

  Product({
    this.id,
    required this.productName,
    required this.productPrice,
    required this.quantity,
    required this.productMrp,
    this.productBarcode,
  });

  Product.fromJson(Map<String, dynamic> json) {
    productPrice = json['ProductPrice'];
    productMrp = json['ProductMrp'];
    productName = json['ProductName'];
    productBarcode = json['ProductBarcode'];
    quantity = json['quantity'];
    id = json['id'];
  }



  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ProductPrice'] = productPrice;
    data['ProductMrp'] = productMrp;
    data['ProductName'] = productName;
    data['ProductBarcode'] = productBarcode;
    data['id'] = id;
    data['quantity'] = quantity;
    return data;
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    map["id"] = id;
    map["ProductBarcode"] = productBarcode;
    map["ProductPrice"] = productPrice;
    map["ProductMrp"] = productMrp;
    map["ProductName"] = productName;
    map["ProductQuantity"] = quantity;
    return map;
  }

  Product.fromMap(Map<String, dynamic> map){
    id = map["id"];
    productName = map["ProductName"];
    productBarcode = map["ProductBarcode"];
    productPrice = map["ProductPrice"].toString();
    productMrp = map["ProductMrp"].toString();
    quantity = map["ProductQuantity"].toString();
  }

}


class invoiceMode {
  int? amount;
  String? mode;

  invoiceMode({
    this.amount,
    required this.mode,
  });

}

class summaryData {
  int? id;
  String? productName;
  int? averageMrp;
  int? averagePrice;
  int? quantity;

  summaryData({
    required this.id,
    required this.productName,
    required this.averagePrice,
    required this.quantity,
    required this.averageMrp,
  });

  summaryData.fromJson(Map<String, dynamic> json) {
    averagePrice = json['ProductPrice'];
    averageMrp = json['ProductMrp'];
    productName = json['ProductName'];
    quantity = json['quantity'];
    id = json['id'];
  }



  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ProductPrice'] = averagePrice;
    data['ProductMrp'] = averageMrp;
    data['ProductName'] = productName;
    data['id'] = id;
    data['quantity'] = quantity;
    return data;
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    map["id"] = id;
    map["ProductPrice"] = averagePrice;
    map["ProductMrp"] = averageMrp;
    map["ProductName"] = productName;
    map["ProductQuantity"] = quantity;
    return map;
  }

  summaryData.fromMap(Map<String, dynamic> map){
    id = map["id"];
    productName = map["ProductName"];
    averagePrice = map["ProductPrice"].toInt();
    averageMrp = map["ProductMrp"].toInt();
    quantity = map["ProductQuantity"].toInt();
  }


}

class dayData {

  String? date;
  int? total;


  dayData({
    required this.date,
    required this.total,
  });

  dayData.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    total = json['total'];
  }


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['date'] = date;
    data['total'] = total;
    return data;
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    map["date"] = date;
    map["total"] = total;
    return map;
  }

  dayData.fromMap(Map<String, dynamic> map){
    date = map["date"];
    total = map["total"].toInt();
  }


}