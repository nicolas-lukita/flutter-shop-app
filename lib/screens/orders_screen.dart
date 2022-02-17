//import 'dart:ffi';

import 'package:flutter/material.dart';
import '../providers/orders.dart';
import 'package:provider/provider.dart';
import '../widgets/order_item.dart' as singleOrderItem;
import '../widgets/app_drawer.dart';

class OrdersScreen extends StatelessWidget {
  static const String routeName = '/orders-screen';

  @override
  Widget build(BuildContext context) {
    print('building orders...');

    //If is a stateful widget, we can do like this:
    // Future _ordersFuture;
    // Future _obtainOrdersFuture() {
    //   return Provider.of<Orders>(context, listen: false).fetchAndSetOrder();
    // }

    // @override
    // void initState() {
    //   _ordersFuture = _obtainOrdersFuture();
    //   super.initState();
    // }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Orders'),
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: Provider.of<Orders>(context, listen: false).fetchAndSetOrder(),
        //future: _ordersFuture,
        builder: (ctx, dataSnapshot) {
          if (dataSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            if (dataSnapshot.error != null) {
              //...
              //do error handling here
              return (Text('error occured'));
            } else {
              return Consumer<Orders>(
                builder: (ctx, orderData, child) => ListView.builder(
                    itemCount: orderData.orders.length,
                    itemBuilder: (ctx, index) =>
                        singleOrderItem.OrderItem(orderData.orders[index])),
              );
            }
          }
        },
      ),
    );
  }
}
