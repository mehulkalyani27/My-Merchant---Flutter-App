import 'package:open_file/open_file.dart';
// ignore: depend_on_referenced_packages
//import 'package:path_provider/path_provider.dart';
import 'dart:io';

Future<void> saveAndLaunchFile(List<int> bytes, String fileName) async {
  String path;
  if (Platform.isIOS) {
      //path = (await getApplicationDocumentsDirectory()).path;
      //final file = File('$path/$fileName');
      //await file.writeAsBytes(bytes, flush: true);
      //OpenFile.open('$path/$fileName');
    } else {
      path = '/storage/emulated/0/Download/';
      final file = File('$path/$fileName');
      await file.writeAsBytes(bytes, flush: false);
  }
}