import 'package:flutter/material.dart';
import '../screens/product_detail_screen.dart';
import 'package:provider/provider.dart';
import '../providers/product.dart';
import '../providers/cart.dart';
import '../providers/auth.dart';

class ProductItem extends StatelessWidget {
  // final String id;
  // final String title;
  // final String imageUrl;

  // ProductItem(this.id, this.title, this.imageUrl);

  @override
  Widget build(BuildContext context) {
    final scaffold = ScaffoldMessenger.of(context);

    // listen:false so when data changes, it will not rebuild the app except for the widget that's wrapped by the Consumer(favorite button bellow)
    final product = Provider.of<Product>(context, listen: false);
    final cart = Provider.of<Cart>(context, listen: false);
    // consumer is used as listener that will listen to the nearest provider of the specified type in the widget tree
    // this works exacly the same as if we use Provider.of(context)
    // but when you use Provider.of(context), the whole build method will rerun when a data changes
    // but if you only want to change a sub-part of the widget tree when the data changes, you can use Consumer to wrap the widget that you want to change

    final authData = Provider.of<Auth>(context, listen: false);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(ProductDetailScreen.routeName,
                arguments: product.id);
          },
          child: Image.network(
            product.imageUrl,
            fit: BoxFit.cover,
          ),
        ),
        footer: GridTileBar(
          title: Text(
            product.title,
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.black87,
          // the favorite button is wrapped in Consumer so when data in Product changes, only this button listen and rebuild
          leading: Consumer<Product>(
            // you can add child that will not rebuild when a data changes from the provider
            builder: (ctx, product, child) => IconButton(
              onPressed: () async {
                try {
                  product.toggleFavoriteStatus(
                      authData.token!, authData.userId);
                } catch (err) {
                  scaffold.showSnackBar(
                      const SnackBar(content: Text('Error occured')));
                }
              },
              //label: child,
              icon: product.isFavorite
                  ? Icon(Icons.favorite)
                  : Icon(Icons.favorite_border),
              color: Theme.of(context).accentColor,
            ),
            //child: Text('this will not change'),
          ),
          trailing: IconButton(
            onPressed: () {
              cart.addItem(product.id, product.price, product.title);
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('${product.title} added to your cart!'),
                duration: Duration(seconds: 2),
                action: SnackBarAction(
                    label: 'Undo',
                    onPressed: () {
                      cart.removeSingleItem(product.id);
                    }),
              ));
            },
            icon: const Icon(Icons.shopping_cart),
            color: Theme.of(context).accentColor,
          ),
        ),
      ),
    );
  }
}
