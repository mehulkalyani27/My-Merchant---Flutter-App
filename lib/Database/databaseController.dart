// ignore_for_file: depend_on_referenced_packages, file_names

import 'dart:async';
import 'package:mymerchant/Model/Invoice.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:mymerchant/Model/Customer.dart';
import '../Model/Product.dart';

const int _version = 1;
const String _dbName = "MyMerchantDBhj.db";

class DbManager {
  static Future<Database> _getDb() async {
    return openDatabase(join(await getDatabasesPath(), _dbName),
        onCreate: (db, version) async {
          await db.execute(
              "CREATE TABLE productTb(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, ProductName TEXT NOT NULL, ProductPrice TEXT NOT NULL, ProductMrp TEXT NOT NULL, ProductBarcode TEXT UNIQUE, ProductQuantity INTEGER NOT NULL, ProductBatch TEXT);"
          );
          await db.execute(
              "CREATE TABLE invoiceTb(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, InvoiceData TEXT NOT NULL);"
          );
          await db.execute(
              "CREATE TABLE customerTb(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, CustomerName TEXT NOT NULL UNIQUE, CustomerEmail TEXT, CustomerPhone TEXT);"
          );
        },
        version: _version

    );
  }

  static Future<int> addCustomer(Customer customer) async {
    final db = await _getDb();
    return await db.insert("customerTb", customer.toMap());
  }

  static Future<int> addProduct(Product product) async {
    final db = await _getDb();
    return await db.insert("productTb", product.toMap());
  }

  static Future<int> addInvoice(InvoiceData invoiceData) async {
    final db = await _getDb();
    return await db.insert("invoiceTb", invoiceData.toMap());
  }

  static Future<List<Customer>> getCustomerList() async {
    final db = await _getDb();
    List<Map> cList = await db.rawQuery('Select * FROM customerTb');
    List<Customer> customerList = [];
    for (int i=0; i<cList.length; i++) {
      customerList.add(Customer.fromMap(cList[i].cast()));
    }
    return customerList;
  }

  static Future<List<Product>> getProductList() async {
    final db = await _getDb();
    List<Map> cList = await db.rawQuery('Select * FROM productTb');
    List<Product> productList = [];
    for (int i=0; i<cList.length; i++) {
      productList.add(Product.fromMap(cList[i].cast()));
    }
    return productList;
  }

  static Future<int> getProductListLength() async {
    final db = await _getDb();
    List<Map> cList = await db.rawQuery('Select * FROM productTb');
    return cList.length;
  }

  static Future<List<InvoiceData>> getInvoiceList() async {
    final db = await _getDb();
    List<Map> cList = await db.rawQuery('Select * FROM invoiceTb');
    List<InvoiceData> invoiceList = [];
    for (int i=0; i<cList.length; i++) {
      invoiceList.add(InvoiceData.fromMap(cList[i].cast()));
      //print(InvoiceData.fromMap(cList[i].cast()).toMap());
    }
    return invoiceList;
  }

  static Future<String> getInvoiceNumber() async {
    // int invoiceNumber = 0;
    final db = await _getDb();
    List<Map> cList = await db.rawQuery('Select * FROM invoiceTb');
    List<InvoiceData> invoiceList = [];
    for (int i=0; i<cList.length; i++) {
      invoiceList.add(InvoiceData.fromMap(cList[i].cast()));
    }
    return invoiceList[invoiceList.length-1].invoiceData.toString().substring(18,30);
  }

  static Future<Product?> getProduct(String productBarcode) async {
    final db = await _getDb();
    List<Map> cList = await db.rawQuery('Select * FROM productTb where ProductBarcode = $productBarcode');
    if(cList.isNotEmpty){
      Product fetchedProduct = Product.fromMap(cList[0].cast());
      return fetchedProduct;
    }
    else{
      return null;
    }
  }

  static Future<int> getProductID() async {
    final db = await _getDb();
    List<Map> cList = await db.rawQuery('Select * FROM productTb');
    if(cList.isNotEmpty){
      return cList.length+1;
    }
    else{
      return 0;
    }
  }

  static Future<int> deleteProduct(int id) async {
    final db = await _getDb();
    var result = await db.delete(
      'productTb',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result;
  }

  static Future<int> deleteInvoice(int id) async {
    final db = await _getDb();
    var result = await db.delete(
      'invoiceTb',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result;
  }

  static Future<int?> getProductQuantity(int productId) async {
    final db = await _getDb();
    List<Map> cList = await db.rawQuery('Select * FROM productTb where id = $productId');
    if(cList.isNotEmpty){
      Product fetchedProduct = Product.fromMap(cList[0].cast());
      return int.parse(fetchedProduct.quantity!);
    }
    else{
      return null;
    }
  }

  Future<int> updateProduct(int id, String price, String name, String barcode, String quantity, String mrp) async {
    if(barcode=='null'){
      Database db = await _getDb();
      var result = await db.update(
        'productTb',
        { 'productName': name,
          'productPrice' : price,
          'productQuantity' : quantity,
          'productMrp' : mrp,
        },
        where: 'id = ?',
        whereArgs: [id],
      );
      return result;
    }
    else{
      Database db = await _getDb();
      var result = await db.update(
        'productTb',
        { 'productName': name,
          'productPrice' : price,
          'productBarcode' : barcode,
          'productQuantity' : quantity,
          'productMrp' : mrp,
        },
        where: 'id = ?',
        whereArgs: [id],
      );
      return result;
    }
  }

  Future<int> updateProductQuantity(int id, int quantity) async {
    Database db = await _getDb();
    var result = await db.update(
      'productTb',
      {
        'productQuantity' : quantity,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
    return result;
  }

  Future<int> updateInvoiceData(int id, String data) async {
    Database db = await _getDb();
    var result = await db.update(
      'invoiceTb',
      {
        'InvoiceData' : data,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
    return result;
  }

}