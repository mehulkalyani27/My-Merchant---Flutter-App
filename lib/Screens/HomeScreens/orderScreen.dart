// ignore_for_file: file_names
import 'dart:convert';
import 'package:mymerchant/Database/databaseController.dart';
import 'package:mymerchant/Model/Invoice.dart';
import 'package:mymerchant/Model/OrderResponse.dart';
import 'package:mymerchant/Resources/constant.dart';
import 'package:flutter/material.dart';
import 'package:mymerchant/Screens/UI/SalesProductUI.dart';
import 'package:shimmer/shimmer.dart';
import '../UI/orderUI.dart';


class OrderScreen extends StatefulWidget {
  const OrderScreen({Key? key}) : super(key: key);
  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {

  List<Invoice> invoiceList = [];
  List<SalesOrderItem> salesProductList = [];
  List<SalesOrderItem> filterSalesProductList = [];
  List<Invoice> filteredData = [];
  bool isFilter = false;
  bool isLoading = true;
  bool isProduct = false;
  List<InvoiceData> invoiceDataList = [];
  List<OrderItem> productList = [];
  TextEditingController searchInvoiceTE = TextEditingController(text: '');
  TextEditingController searchProductTE = TextEditingController(text: '');

  //Loading Screen
  Widget _buildLoadingScreen() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 7,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(5.0),
            child: Card(
              margin: const EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 0),
              elevation: 1.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: const SizedBox(height: 84),
            ),
          );
        },
      ),
    );
  }

  //Order List View
  Widget _buildListView(List<Invoice> invoiceList ) {
    return invoiceList.isNotEmpty ? ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      scrollDirection: Axis.vertical,
      itemCount: invoiceList.length,
      itemBuilder: (ctx, index) {
        return orderUI(
          index: index+1,
          invoiceData: invoiceList[index],
        );
      },
    ) :
    Center(child: Text("No Invoice",style: TextStyle(color: appConstants.defaultColor, fontWeight: FontWeight.w600, fontFamily: appConstants.fontFamily,fontSize: 16)));
  }

  Widget _buildSalesProductView(List<SalesOrderItem> productList ) {
    return productList.isNotEmpty ? ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      scrollDirection: Axis.vertical,
      itemCount: productList.length,
      itemBuilder: (ctx, index) {
        return salesProductUI(
           salesOrderItem: productList[index],
        );
      },
    ) :
    Center(child: Text("No Products", style: TextStyle(color: appConstants.defaultColor, fontWeight: FontWeight.w600, fontFamily: appConstants.fontFamily,fontSize: 16)));
  }

  @override void initState() {
    super.initState();
    getData();
  }

  @override void dispose() {
    super.dispose();
  }

  void deleteInvoice() async {
    // List<InvoiceData> invoiceODataList = [];
    // invoiceODataList = await DbManager.getInvoiceList();
    // print(invoiceODataList.length);
    // invoiceODataList.sublist(2528,2530).forEach((element) async {
    //   print(element.id);
    //   print(element.invoiceData.toString());
    //   String change = element.invoiceData.toString();
    //   String g = change.replaceFirst("2024-06-14", "2024-06-13");
    //   int d = await DbManager().updateInvoiceData(element.id!, g);
    //   print(d);
    // });
    //DbManager.deleteInvoice(1933);
  }

  void getData() async {
    setState(() {
      isLoading = true;
      searchInvoiceTE.clear();
    });
    invoiceDataList = await DbManager.getInvoiceList();
    invoiceList.clear();
    for (var element in invoiceDataList) {
        String dataString = element.invoiceData.toString();
        List<String> stringInvoice = element.invoiceData.toString().split(", InvoiceProductList").first.toString().replaceAll("{","").replaceAll("}","").split(",");
        Map<String,dynamic> result = {};
        for(int i=0;i<stringInvoice.length;i++){
          List<String> s = stringInvoice[i].split(":");
          result.putIfAbsent(s[0].trim(), () => s[1].trim());
        }
        String productListString = dataString.split(", InvoiceProductList: ").last.toString();
        List<dynamic> jsonList = json.decode(productListString.substring(0, productListString.length-1));
        setState(() {
          productList = jsonList.map((json) => OrderItem.fromJson(json)).toList();
        });
        Invoice invoice = Invoice.fromMap(result);
        setState(() {
          invoice.invoiceListProduct = productList;
        });
        invoiceList.add(invoice);
    }
    setState(() {
      invoiceList = invoiceList.reversed.toList();
      filteredData.addAll(invoiceList);
    });
    Future.delayed(const Duration(milliseconds: 500),(){
      setState(() {
        isLoading = false;
      });
    });
  }

  void displaySalesByProducts() async {
    setState(() {
      isProduct = !isProduct;
    });
    getData();
    setState(() {
      searchProductTE.clear();
      isLoading = true;
      salesProductList.clear();
      filterSalesProductList.clear();
    });
    for (var iElement in invoiceList) {
      iElement.invoiceListProduct?.forEach((element) {
        SalesOrderItem orderItem = SalesOrderItem
          (
            invoiceDate: iElement.invoiceDate!,
            invoiceNumber: iElement.invoiceNumber!,
            paymentMode: iElement.invoicePaymentMode!,
            itemName: element.itemName,
            mrp: element.mrp,
            qty: element.qty,
            price: element.price,
            total: element.total,
            itemId: element.itemId,
        );
        salesProductList.add(orderItem);
      });
    }
    filterSalesProductList.addAll(salesProductList);
    setState(() {
      isLoading = true;
    });
  }

  void filterSearchResults(String query) {
    List<Invoice> filterList = [];
    setState(() {
      filterList.addAll(invoiceList.toList());
      filteredData = filterList
          .where((item) =>
      item.invoiceNumber.toString().toLowerCase().contains(query.toString()) ||
          item.invoiceCustomer.toString().toLowerCase().contains(query.toString().toLowerCase())
      )
          .toList();
    });
  }

  void filterSearchResultsProducts(String query) {
    List<SalesOrderItem> filterList = [];
    setState(() {
      filterList.clear();
      filterList.addAll(salesProductList.toList());
      filterSalesProductList = filterList
          .where((item) =>
      item.itemName.toString().toLowerCase().contains(query.toString().toLowerCase())
      )
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope( onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(appConstants.appTitle,style: TextStyle(fontFamily: appConstants.fontFamily)),
          backgroundColor: appConstants.defaultColor,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(onPressed: deleteInvoice, icon: const Icon(Icons.delete)),
            IconButton(onPressed: displaySalesByProducts, icon: isProduct? Icon(Icons.insert_chart,color: appConstants.whiteColor) : Icon(Icons.production_quantity_limits_sharp,color: appConstants.whiteColor)),
          ],

        ),
        body: SingleChildScrollView(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:[
                const SizedBox(height: 2),
                Card(
                    child: SizedBox(
                        height: MediaQuery.of(context).size.height*0.05,
                        width: MediaQuery.of(context).size.width,
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.note,color: appConstants.defaultColor),
                              Padding(
                                padding: const EdgeInsets.only(left: 5.0),
                                child: Text('Invoice',style: TextStyle(color: appConstants.defaultColor, fontWeight: FontWeight.w600, fontFamily: appConstants.fontFamily,fontSize: 22)),
                              ),
                            ],
                          ),
                        )
                    )
                ),
                Card(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height*0.042,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        isProduct? Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 20.0),
                                child: Text('#',style: TextStyle(color: appConstants.defaultColor, fontWeight: FontWeight.w600, fontFamily: appConstants.fontFamily,fontSize: 16)),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 60.0),
                                child: Text('Product Info',style: TextStyle(color: appConstants.defaultColor, fontWeight: FontWeight.w600, fontFamily: appConstants.fontFamily,fontSize: 16)),
                              ),
                          ],
                        )
                            :
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 20.0),
                              child: Text('#',style: TextStyle(color: appConstants.defaultColor, fontWeight: FontWeight.w600, fontFamily: appConstants.fontFamily,fontSize: 16)),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 60.0),
                              child: Text('Invoice Info',style: TextStyle(color: appConstants.defaultColor, fontWeight: FontWeight.w600, fontFamily: appConstants.fontFamily,fontSize: 16)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                isProduct? Padding(
                  padding: const EdgeInsets.only(top: 10, right: 50.0,left: 50.0),
                  child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: appConstants.circularBackgroundColor)
                      ),
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height*0.07,
                      child: TextFormField(
                        decoration: const InputDecoration(
                          hintText: 'Search Product',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                        ),
                        controller: searchProductTE,
                        onChanged: (value) {
                          filterSearchResultsProducts(value);
                        },
                      )
                  ),
                )
                    : Padding(
                  padding: const EdgeInsets.only(top: 10, right: 50.0,left: 50.0),
                  child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: appConstants.circularBackgroundColor)
                      ),
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height*0.07,
                      child: TextFormField(
                        decoration: const InputDecoration(
                          hintText: 'Search Invoice',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                        ),
                        controller: searchInvoiceTE,
                        onChanged: (value) {
                          filterSearchResults(value);
                        },
                      )
                  ),
                ),
                SizedBox(
                  height: 420,
                  width: MediaQuery.of(context).size.width,
                  child: isLoading? _buildLoadingScreen() : isProduct? _buildSalesProductView(filterSalesProductList) : _buildListView(filteredData),
                ),
            ]
          ),
        ),
      ),
    );
  }
}