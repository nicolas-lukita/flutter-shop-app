import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/widgets/app_drawer.dart';
import '../providers/products_provider.dart';
import '../widgets/user_product_item.dart';
import './edit_product_screen.dart';

class UserProductsScreen extends StatelessWidget {
  static const routeName = '/user-products-screen';

  const UserProductsScreen({Key? key}) : super(key: key);

  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<Products>(context, listen: false)
        .fetchAndSetProducts(true); //pass true to filter by user
  }

  @override
  Widget build(BuildContext context) {
    print('rebuilding...');
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('My Products'),
        actions: [
          IconButton(
              onPressed: () => {
                    Navigator.of(context).pushNamed(EditProductScreen.routeName,
                        arguments: 'noArgs')
                  },
              icon: const Icon(Icons.add)),
        ],
      ),
      body: FutureBuilder(
        future: _refreshProducts(context),
        builder: (ctx, snapshot) => snapshot.connectionState ==
                ConnectionState.waiting
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : RefreshIndicator(
                onRefresh: () =>
                    _refreshProducts(context), //swipe down to refresh
                child: Consumer<Products>(
                  builder: (ctx, productsData, _) => Padding(
                    padding: const EdgeInsets.all(8),
                    child: ListView.builder(
                        itemCount: productsData.items.length,
                        itemBuilder: (ctx, index) {
                          return Column(
                            children: <Widget>[
                              UserProductItem(
                                  id: productsData.items[index].id,
                                  title: productsData.items[index].title,
                                  imgUrl: productsData.items[index].imageUrl),
                              const Divider(),
                            ],
                          );
                        }),
                  ),
                ),
              ),
      ),
    );
  }
}
