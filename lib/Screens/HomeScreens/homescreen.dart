
// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:typed_data';

import 'package:mymerchant/Resources/constant.dart';
import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:usb_serial/transaction.dart';
import 'package:usb_serial/usb_serial.dart';
import 'newOrderScreen.dart';


// ignore: must_be_immutable
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  bool isLoading = false;
  // List<OrderList> apiOrderList = [];
  bool isNewOrderLoading = false;
  UsbPort? _port;
  final List<Widget> _serialData = [];
  StreamSubscription<String>? _subscription;
  Transaction<String>? _transaction;
  UsbDevice? _device;

  Future<bool> _connectTo(device) async {
    _serialData.clear();

    if (_subscription != null) {
      _subscription!.cancel();
      _subscription = null;
    }

    if (_transaction != null) {
      _transaction!.dispose();
      _transaction = null;
    }

    if (_port != null) {
      _port!.close();
      _port = null;
    }

    if (device == null) {
      _device = null;
      setState(() {
      });
      return true;
    }

    _port = await device.create();
    if (await (_port!.open()) != true) {
      setState(() {
      });
      return false;
    }
    _device = device;

    await _port!.setDTR(true);
    await _port!.setRTS(true);
    await _port!.setPortParameters(115200, UsbPort.DATABITS_8, UsbPort.STOPBITS_1, UsbPort.PARITY_NONE);

    _transaction = Transaction.stringTerminated(_port!.inputStream as Stream<Uint8List>, Uint8List.fromList([13, 10]));

    _subscription = _transaction!.stream.listen((String line) {
      setState(() {
        _serialData.add(Text(line));
        if (_serialData.length > 20) {
          _serialData.removeAt(0);
        }
      });
    });

    setState(() {
    });
    return true;
  }

  void _getPorts() async {
    List<UsbDevice> devices = await UsbSerial.listDevices();
    if (!devices.contains(_device)) {
      _connectTo(null);
    }

    for (var device in devices) {
      if(device.vid == 6790 && device.pid == 29987){
        _connectTo(device);
        String data ='Welcome to ToyBytes';
        await _port!.write(Uint8List.fromList(data.padLeft(40,' ').codeUnits));
        }
      else{
        showTopSnackBar(
          context,
          const CustomSnackBar.error(
            message: 'Display Not Found',
          ),
        );
      }
      }
  }

  @override void initState() {
    super.initState();
    //_getPorts();
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
        ),
        body: SingleChildScrollView(
          child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children:[
                 const SizedBox(height: 20),
                 Center(
                   child: Text('Welcome ToyBytes !',
                     style: TextStyle(fontFamily: appConstants.fontFamily,fontSize: 32,fontWeight: FontWeight.w800,color: appConstants.indexColor)),
                 ),
                 Padding(
                   padding: const EdgeInsets.only(left: 20.0, right: 20.0,top: 20 ),
                   child: Container(
                     decoration: BoxDecoration(
                       borderRadius: BorderRadius.circular(7.5),
                       color: Colors.white,
                       boxShadow: const [
                         BoxShadow(
                           color: Colors.grey,
                           offset: Offset(0.0, 0.0), //(x,y)
                           blurRadius: 12.0,
                         ),
                       ],
                     ),
                     child: SizedBox(
                       width: double.infinity,
                       height: MediaQuery.of(context).size.height*0.52,
                       child: Image.asset("assets/images/2903544.jpg"),
                     ),
                   ),
                 ),
                 // Padding(
                 //     padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 20),
                 //     child: Container(
                 //       decoration: BoxDecoration(
                 //         borderRadius: BorderRadius.circular(5.0),
                 //         color: Colors.white,
                 //         boxShadow: const [
                 //           BoxShadow(
                 //             color: Colors.grey,
                 //             offset: Offset(0.0, 0.0), //(x,y)
                 //             blurRadius: 8.0,
                 //           ),
                 //         ],
                 //       ),
                 //       child: SizedBox(
                 //         width: double.infinity,
                 //         height: MediaQuery.of(context).size.height*0.08,
                 //         child:Center(child: Text('Sales',style: TextStyle(color: appConstants.defaultColor,fontFamily: appConstants.fontFamily,fontSize: 20))),
                 //       ),
                 //     )),
                 // Padding(
                 //   padding: const EdgeInsets.only(left: 20.0, right: 20.0,top: 20),
                 //   child: SizedBox(
                 //     width: double.infinity,
                 //     height: MediaQuery.of(context).size.height*0.16,
                 //     child: Row(
                 //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                 //       crossAxisAlignment: CrossAxisAlignment.center,
                 //       children: [
                 //         Flexible(
                 //           child: Padding(
                 //             padding: const EdgeInsets.all(6.0),
                 //             child: Container(
                 //               decoration: BoxDecoration(
                 //                 borderRadius: BorderRadius.circular(10.0),
                 //                 color: Colors.white,
                 //                 boxShadow: const [
                 //                   BoxShadow(
                 //                     color: Colors.grey,
                 //                     offset: Offset(0.0, 0.0), //(x,y)
                 //                     blurRadius: 8.0,
                 //                   ),
                 //                 ],
                 //               ),
                 //               child: Center(
                 //                 child: Column(
                 //                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                 //                   children: [
                 //                     Text('Day',style: TextStyle(color: appConstants.blackColor,fontFamily: appConstants.fontFamily,fontSize: 16)),
                 //                     isLoading?
                 //                     Padding(
                 //                       padding: const EdgeInsets.only(top: 8.0),
                 //                       child: CircularProgressIndicator(
                 //                         strokeWidth: 5.0,
                 //                         color: appConstants.circularBackgroundColor,
                 //                       ),
                 //                     ) :
                 //                     CircularPercentIndicator(
                 //                       radius: MediaQuery.of(context).size.width/34,
                 //                       lineWidth: 5.0,
                 //                       percent: dailyInvoiceCount/(weeklyInvoiceCount*2),
                 //                       center: Text(dailyInvoiceCount.toString(),style: TextStyle(color: appConstants.circularProgressColor,fontFamily: appConstants.fontFamily)),
                 //                       progressColor: appConstants.circularProgressColor,
                 //                       backgroundColor: appConstants.circularBackgroundColor,
                 //                     ),
                 //                   ],
                 //                 ),
                 //               ),
                 //             ),
                 //           ),
                 //         ),
                 //         Flexible(
                 //           child: Padding(
                 //             padding: const EdgeInsets.all(6.0),
                 //             child: Container(
                 //               decoration: BoxDecoration(
                 //                 borderRadius: BorderRadius.circular(10.0),
                 //                 color: Colors.white,
                 //                 boxShadow: const [
                 //                   BoxShadow(
                 //                     color: Colors.grey,
                 //                     offset: Offset(0.0, 0.0), //(x,y)
                 //                     blurRadius: 8.0,
                 //                   ),
                 //                 ],
                 //               ),
                 //               child: Center(
                 //                 child: Column(
                 //                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                 //                   children: [
                 //                     Text('Week',style: TextStyle(color: appConstants.blackColor,fontFamily: appConstants.fontFamily,fontSize: 16)),
                 //                     isLoading?
                 //                     SizedBox(
                 //                         height: MediaQuery.of(context).size.width/20.6,
                 //                         width: MediaQuery.of(context).size.width/20.6,
                 //                         child: CircularProgressIndicator(
                 //                           strokeWidth: 5.0,
                 //                           color: appConstants.circularBackgroundColor,
                 //                         )) :
                 //                     CircularPercentIndicator(
                 //                       radius: MediaQuery.of(context).size.width/34,
                 //                       lineWidth: 5.0,
                 //                       percent: weeklyInvoiceCount/monthlyInvoiceCount==1? weeklyInvoiceCount/(monthlyInvoiceCount*2) : weeklyInvoiceCount/monthlyInvoiceCount,
                 //                       center: Text(weeklyInvoiceCount.toString(),style: TextStyle(color: appConstants.circularProgressColor,fontFamily: appConstants.fontFamily)),
                 //                       progressColor: appConstants.circularProgressColor,
                 //                       backgroundColor: appConstants.circularBackgroundColor,
                 //                     ),
                 //                   ],
                 //                 ),
                 //               ),
                 //             ),
                 //           ),
                 //         ),
                 //         Flexible(
                 //           child: Padding(
                 //             padding: const EdgeInsets.all(6.0),
                 //             child: Container(
                 //               decoration: BoxDecoration(
                 //                 borderRadius: BorderRadius.circular(10.0),
                 //                 color: Colors.white,
                 //                 boxShadow: const [
                 //                   BoxShadow(
                 //                     color: Colors.grey,
                 //                     offset: Offset(0.0, 0.0), //(x,y)
                 //                     blurRadius: 8.0,
                 //                   ),
                 //                 ],
                 //               ),
                 //               child: Center(
                 //                 child: Column(
                 //                   mainAxisAlignment: MainAxisAlignment.start,
                 //                   children: [
                 //                     Text('Month',style: TextStyle(color: appConstants.blackColor,fontFamily: appConstants.fontFamily,fontSize: 16)),
                 //                     isLoading?
                 //                     SizedBox(
                 //                         height: MediaQuery.of(context).size.width/20.6,
                 //                         width: MediaQuery.of(context).size.width/20.6,
                 //                         child: CircularProgressIndicator(
                 //                           strokeWidth: 5.0,
                 //                           color: appConstants.circularBackgroundColor,
                 //                         )) :
                 //                     CircularPercentIndicator(
                 //                       radius: MediaQuery.of(context).size.width/34,
                 //                       lineWidth: 5.0,
                 //                       percent: monthlyInvoiceCount/totalInvoiceCount,
                 //                       center: Text(monthlyInvoiceCount.toString(),style: TextStyle(color: appConstants.circularProgressColor,fontFamily: appConstants.fontFamily)),
                 //                       progressColor: appConstants.circularProgressColor,
                 //                       backgroundColor: appConstants.circularBackgroundColor,
                 //                     ),
                 //                   ],
                 //                 ),
                 //               ),
                 //             ),
                 //           ),
                 //         ),
                 //       ],
                 //     ),
                 //   ),
                 // ),
                 Padding(
                     padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 20),
                     child: Container(
                       decoration: BoxDecoration(
                         borderRadius: BorderRadius.circular(10.0),
                         color: Colors.white,
                         boxShadow: const [
                           BoxShadow(
                             color: Colors.grey,
                             offset: Offset(0.0, 0.0), //(x,y)
                             blurRadius: 12.0,
                           ),
                         ],
                       ),
                       child: SizedBox(
                         width: double.infinity,
                         height: MediaQuery.of(context).size.height*0.1,
                         child: ElevatedButton(
                              onPressed: (){
                                Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) => const NewOrderScreen()));
                              },
                              style: ButtonStyle(
                                 backgroundColor: MaterialStateProperty.all<Color>(
                                   appConstants.cirightBlue
                                   ),
                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                     borderRadius: BorderRadius.circular(10.0),
                                       ),
                               ),
                             ),
                             child: isNewOrderLoading?
                             SizedBox(
                               height: 40,
                               width: 40,
                               child: CircularProgressIndicator(
                                 strokeWidth: 6,
                                 color: appConstants.circularBackgroundColor,
                               ),
                             )  :
                             Row(
                                     mainAxisAlignment: MainAxisAlignment.center,
                                       children: [
                                          const Icon(Icons.add_circle),
                                            Padding(
                                              padding: const EdgeInsets.only(left: 10.0),
                                              child: Text("New Invoice",style: TextStyle(fontFamily: appConstants.fontFamily, fontSize: 22)),
                                          ),
                                    ],
                          )),
                       ),
                     )),
               ]
           ),
        ),
      ),
    );
  }
}