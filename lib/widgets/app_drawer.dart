import 'package:flutter/material.dart';
import 'package:shop_app/screens/user_products_screen.dart';
import '../screens/orders_screen.dart';
import '../providers/auth.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            title: const Text('Navigate'),
            automaticallyImplyLeading: false,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.shop),
            title: const Text('Shop'),
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.credit_card),
            title: const Text('My Orders'),
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(OrdersScreen.routeName);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Manage Products'),
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(UserProductsScreen.routeName);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Logout'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/');
              Provider.of<Auth>(context, listen: false).logout();
            },
          ),
        ],
      ),
    );
  }
}
