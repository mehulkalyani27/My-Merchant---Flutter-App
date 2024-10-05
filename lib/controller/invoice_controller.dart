import 'dart:convert' as convert;
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../Model/Invoice.dart';

class FormController {
  // Google App Script Web URL.
  static const String uploadURL = "YOUR URL";
  // Success Status Message
  static const successStatus = "SUCCESS";

  void submitForm(
      Invoice invoice, void Function(String) callback) async {
    try {
      await http.post(Uri.parse(uploadURL), body: invoice.toJson()).then((response) async {
        if (response.statusCode == 302) {
          var url = response.headers['location'];
          await http.get(Uri.parse(url.toString())).then((response) {
            callback(convert.jsonDecode(response.body)['status']);
          });
        } else {
          callback(convert.jsonDecode(response.body)['status']);
        }
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}