import 'package:flutter/material.dart';
import 'package:mymerchant/splashscreen.dart';
import 'package:provider/provider.dart';
import 'Screens/UI/OrderListUI.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  // ignore: non_constant_identifier_names


  @override
  Widget build(BuildContext context) {
    const appTitle = 'My Merchant';
    return ChangeNotifierProvider(
      create: (context) => MyList(),
      child: const MaterialApp(
        title: appTitle,
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: splash_screen(),
        ),
      ),
    );
  }
}