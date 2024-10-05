// ignore_for_file: file_names

//
// class OrderApiResp {
//   bool? status;
//   String? message;
//   OrderData? data;
//
//   OrderApiResp({this.status, this.message, this.data});
//
//   OrderApiResp.fromJson(Map<String, dynamic> json) {
//     status = json['status'];
//     message = json['message'];
//     data = json['data'] != null ? OrderData.fromJson(json['data']) : null;
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['status'] = status;
//     data['message'] = message;
//     if (this.data != null) {
//       data['data'] = this.data!.toJson();
//     }
//     return data;
//   }
// }
//
// class OrderData {
//   int? totalCount;
//   List<OrderList>? orderList;
//
//   OrderData({this.totalCount, this.orderList});
//
//   OrderData.fromJson(Map<String, dynamic> json) {
//     totalCount = json['totalCount'];
//     if (json['orderList'] != null) {
//       orderList = <OrderList>[];
//       json['orderList'].forEach((v) {
//         orderList!.add(OrderList.fromJson(v));
//
//       });
//     }
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['totalCount'] = totalCount;
//     if (orderList != null) {
//       data['orderList'] = orderList!.map((v) => v.toJson()).toList();
//     }
//     return data;
//   }
// }
//
// class OrderList {
//   int? projectId;
//   String? orderDate;
//   DateFormat inputFormat = DateFormat('MM/dd/yyyy');
//   DateTime? date;
//   double? orderTotal;
//   int? quantity;
//   int? phaseId;
//   String? phase;
//   int? customerId;
//   String? customerName;
//   List<Products>? products;
//
//   OrderList(
//       {this.projectId,
//         this.orderDate,
//         this.date,
//         this.orderTotal,
//         this.quantity,
//         this.phaseId,
//         this.phase,
//         this.customerId,
//         this.customerName,
//         this.products});
//
//   OrderList.fromJson(Map<String, dynamic> json) {
//     projectId = json['projectId'];
//     orderDate = json['orderDate'];
//     date = inputFormat.parse(json['orderDate']);
//     orderTotal = json['orderTotal'];
//     quantity = json['quantity'];
//     phaseId = json['phaseId'];
//     phase = json['phase'];
//     customerId = json['customerId'];
//     customerName = json['customerName'];
//     if (json['products'] != null) {
//       products = <Products>[];
//       json['products'].forEach((v) {
//         products!.add(Products.fromJson(v));
//       });
//     }
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['projectId'] = projectId;
//     data['orderDate'] = orderDate;
//     data['orderTotal'] = orderTotal;
//     data['quantity'] = quantity;
//     data['phaseId'] = phaseId;
//     data['phase'] = phase;
//     data['customerId'] = customerId;
//     data['customerName'] = customerName;
//     if (products != null) {
//       data['products '] = products!.map((v) => v.toJson()).toList();
//     }
//     return data;
//   }
// }
//
// class Products {
//   int? productId;
//   int? quantity;
//   double? price;
//   String? productName;
//
//   Products({this.productId, this.quantity, this.price, this.productName});
//
//   Products.fromJson(Map<String, dynamic> json) {
//     productId = json['productId'];
//     quantity = json['quantity'];
//     price = json['price'];
//     productName = json['productName'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['productId'] = productId;
//     data['quantity'] = quantity;
//     data['price'] = price;
//     data['productName'] = productName;
//     return data;
//   }
// }

class OrderItem {
  int? itemId;
  String? itemName;
  int? qty;
  int? mrp;
  int? price;

  int? total;

  OrderItem({
    required this.itemName,
    required this.qty,
    required this.mrp,
    required this.price,
    required this.total,
    required this.itemId,
  });

  // OrderItem.fromJson(Map<String, dynamic> json) {
  //
  // }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['productId'] = itemId;
    data['productName'] = itemName;
    data['quantity'] = qty;
    data['price'] = price;
    data['mrp'] = mrp;
    data['total'] = total;
    return data;
  }
  //
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    map['productId'] = itemId;
    map['productName'] = itemName;
    map['quantity'] = qty;
    map['price'] = price;
    map['total'] = total;
    map['mrp'] = mrp;
    return map;
  }

  // OrderItem.fromMap(Map<String, dynamic> map){
  //   itemId = map['productId'];
  //   itemName = map['productName'];
  //   qty = map['quantity'];
  //   price = map['quantity'];
  //   total = map['total'];
  // }

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
        itemId : json['productId'],
        itemName : json['productName'],
        qty : json['quantity'],
        mrp : json['mrp'],
        price : json['price'],
        total : json['total'],
    );
  }
}

class SalesOrderItem {
  String? invoiceNumber;
  String invoiceDate;
  String paymentMode;
  int? itemId;
  String? itemName;
  int? qty;
  int? price;
  int? mrp;
  int? total;


  SalesOrderItem({
    required this.invoiceDate,
    required this.invoiceNumber,
    required this.itemName,
    required this.qty,
    required this.price,
    required this.total,
    required this.mrp,
    required this.itemId,
    required this.paymentMode,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['productId'] = itemId;
    data['productName'] = itemName;
    data['quantity'] = qty;
    data['price'] = price;
    data['mrp'] = mrp;
    data['total'] = total;
    data['invoiceNumber'] = invoiceNumber;
    data['paymentMode'] = paymentMode;
    data['invoiceDate'] = invoiceDate;
    return data;
  }
  //
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    map['productId'] = itemId;
    map['productName'] = itemName;
    map['quantity'] = qty;
    map['price'] = price;
    map['total'] = total;
    map['mrp'] = mrp;
    map['invoiceDate'] = invoiceDate;
    map['invoiceNumber'] = invoiceNumber;
    map['paymentMode'] = paymentMode;
    return map;
  }

  factory SalesOrderItem.fromJson(Map<String, dynamic> json) {
    return SalesOrderItem(
      itemId : json['productId'],
      itemName : json['productName'],
      qty : json['quantity'],
      price : json['price'],
      mrp : json['mrp'],
      total : json['total'],
      invoiceDate: json['invoiceNumber'],
      invoiceNumber: json['invoiceNumber'],
      paymentMode: json['paymentMode']
    );
  }
}


class MyModel {
  final int id;
  final String name;

  MyModel(this.id, this.name);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory MyModel.fromJson(Map<String, dynamic> json) {
    return MyModel(json['id'], json['name']);
  }
}


