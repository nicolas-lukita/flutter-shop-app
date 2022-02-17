import 'package:flutter/material.dart';
import 'package:shop_app/screens/cart_screen.dart';
import 'package:shop_app/screens/edit_product_screen.dart';
import 'package:shop_app/screens/product_detail_screen.dart';
import './screens/splash_screen.dart';
import './screens/products_overview_screen.dart';
import './providers/products_provider.dart';
import 'package:provider/provider.dart';
import './providers/cart.dart';
import './providers/orders.dart';
import './screens/orders_screen.dart';
import './screens/user_products_screen.dart';
import './screens/auth_screen.dart';
import './providers/auth.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // in a case where you dont need context, we can use ChangeNotifierProvider.value(value: Products())
    // use ChangeNotifierProvider when you will need to create new object base on the class for efficiency an less unecessary re-render
    // use ChangeNotifierProvider.value when you reuse existing object(for example widgets when you loop through list of data)
    return MultiProvider(
        providers: [
          //ChangeNotifierProvider.value(value: Auth(),),
          ChangeNotifierProvider(create: (ctx) => Auth()),
          //ChangeNotifierProvider(create: (ctx) => Products()),
          ChangeNotifierProxyProvider<Auth, Products>(
            //provider that depends on another provider
            //require <1, 2> 1: class it depends on, 2: type of data will be provided
            create: (ctx) => Products('', '', []),
            update: (ctx, auth, previousProducts) => Products(
                auth.token!,
                auth.userId,
                previousProducts == null ? [] : previousProducts.items),
          ),
          ChangeNotifierProvider(create: (ctx) => Cart()),
          //ChangeNotifierProvider(create: (ctx) => Orders()),
          ChangeNotifierProxyProvider<Auth, Orders>(
              create: (ctx) => Orders('', '', []),
              update: (ctx, auth, previousOrders) => Orders(
                  auth.token!,
                  auth.userId,
                  previousOrders == null ? [] : previousOrders.orders))
        ],
        child: Consumer<Auth>(builder: (ctx, auth, _) {
          checkAuth(targetScreen) => auth.isAuth ? targetScreen : AuthScreen();
          return MaterialApp(
            title: 'Shop App',
            theme: ThemeData(
              primarySwatch: Colors.indigo,
              accentColor: Colors.amber,
              fontFamily: 'Lato',
            ),
            home: auth.isAuth
                ? ProductsOverviewScreen()
                : FutureBuilder(
                    future: auth.tryAutoLogin(),
                    builder: (ctx, authResultSnapshot) =>
                        authResultSnapshot.connectionState ==
                                ConnectionState.waiting
                            ? SplashScreen()
                            : AuthScreen(),
                  ),
            routes: {
              ProductDetailScreen.routeName: (ctx) =>
                  checkAuth(ProductDetailScreen()),
              CartScreen.routeName: (ctx) => checkAuth(CartScreen()),
              OrdersScreen.routeName: (ctx) => checkAuth(OrdersScreen()),
              UserProductsScreen.routeName: (ctx) =>
                  checkAuth(const UserProductsScreen()),
              EditProductScreen.routeName: (ctx) =>
                  checkAuth(const EditProductScreen()),
              //AuthScreen.routeName: (ctx) => AuthScreen(),
            },
          );
        }));
  }
}
