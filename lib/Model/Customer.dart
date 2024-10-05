import 'OrderResponse.dart';

class Customer {
  String? id;
  String? email;
  String? name;
  String? phone;

  Customer({
    required this.id,
    this.email,
    required this.name,
    this.phone});

  Customer.fromJson(Map<String, dynamic> json) {
    email = json['email'];
    name = json['name'];
    phone = json['phone'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['email'] = email;
    data['name'] = name;
    data['phone'] = phone;
    data['id'] = id;
    return data;
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    map["id"] = id;
    map["CustomerName"] = name;
    map["CustomerEmail"] = email;
    map["CustomerPhone"] = phone;
    return map;
  }

  Customer.fromMap(Map<String, dynamic> map){
    id = map["id"];
    name = map["CustomerName"];
    phone = map["CustomerPhone"];
    email = map["CustomerEmail"];
  }

}


// class CustomerInvoice{
//   int? customerId;
//   bool? expanded;
//   List<OrderList>? orderList;
//
//   CustomerInvoice({
//     required this.expanded,
//     required this.orderList,
//     required this.customerId});
//
//   CustomerInvoice.fromJson(Map<String, dynamic> json) {
//     customerId = json['customerId'];
//     expanded = json['expanded'];
//     if (json['orderList'] != null) {
//       orderList = <OrderList>[];
//       json['orderList'].forEach((v) {
//         orderList!.add(OrderList.fromJson(v));
//       });
//     }
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['customerId'] = customerId;
//     data['expanded'] = expanded;
//     if (orderList != null) {
//       data['products '] = orderList!.map((v) => v.toJson()).toList();
//     }
//     return data;
//   }
//
// }

