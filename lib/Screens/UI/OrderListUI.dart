// ignore_for_file: must_be_immutable, file_names

import 'package:flutter/cupertino.dart';
import 'package:mymerchant/Resources/constant.dart';
import 'package:provider/provider.dart';
import '../../Model/OrderResponse.dart';
import 'OrderItemUI.dart';

class MyList extends ChangeNotifier {
  final List<OrderItem> _items = [];
  List<OrderItem> get items => _items;

  void addItem(OrderItem item) {
    _items.add(item);
    notifyListeners();
  }

  void updateItem(int index, OrderItem item) {
    _items[index] = item;
    notifyListeners();
  }

  void deleteItems(int index){
    _items.removeAt(index);
  }

  void clearItems() {
    _items.clear();
    notifyListeners();
  }



  @override
  void dispose() {
    clearItems();
    super.dispose();
  }
}

// ignore: camel_case_types
// ignore: camel_case_types
class orderListUI extends StatelessWidget {
  List<OrderItem> orderList;
  orderListUI({super.key,required this.orderList});

  void removeItem() async {
    // setState(({
    //
    // }));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MyList>(builder: (context, myList, child) =>
            ListView.builder(
              itemCount: orderList.length,
              itemBuilder: (ctx, index) {
                return Dismissible(
                  key: Key(orderList[index].itemId.toString()),
                  onDismissed: (direction) {
                    orderList.removeAt(index);
                    // setState(() {
                    //   global.formValidate=_formKey.currentState!.validate();
                    // });
                  },
                  background: Container(color: appConstants.errorColor),
                  child:  orderItemUI(
                    index: index+1,
                    orderItem: orderList[index],
                  ),
                );

              },

            )
    );
  }
}


