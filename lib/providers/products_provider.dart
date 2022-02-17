import 'dart:convert';
import 'package:flutter/material.dart';
import './product.dart';
import '../models/http_exception.dart';
import 'package:http/http.dart' as http;

class Products with ChangeNotifier {
  List<Product> _items = [];

  // var _showFavoritesOnly = false;
  final String authToken;
  final String userId;
  Products(this.authToken, this.userId, this._items);

  List<Product> get items {
    return [
      ..._items
    ]; //this returns copy of _items instead of returning pointer to _items in memory (serperate copy of the original)
  }

  List<Product> get favoriteItems {
    return _items.where((element) => element.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((element) => element.id == id);
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    var _param = <String, String>{
      'auth': authToken,
    };
    if (filterByUser) {
      _param = <String, String>{
        'auth': authToken,
        'orderBy': json.encode('creatorId'),
        'equalTo': json.encode(userId)
      };
    }
    var url = Uri.https('flutter-shop-587b2-default-rtdb.firebaseio.com',
        '/products.json', _param);
    try {
      final response = await http.get(url); // will be in form of {id : {data}}
      final extractedData = json.decode(response.body)
          as Map<String, dynamic>; // now is in form of a Map

      if (extractedData == null) {
        return;
      }

      url = Uri.https('flutter-shop-587b2-default-rtdb.firebaseio.com',
          '/userFavorites/$userId.json', {'auth': authToken});
      final favoriteResponse = await http.get(url);
      final favoriteData = json.decode(favoriteResponse.body);

      final List<Product> loadedProducts = [];
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
          id: prodId,
          title: prodData['title'],
          price: prodData['price'],
          //double ?? is to check whether previous is null or not
          //if null, then do the thing after ??
          isFavorite:
              favoriteData == null ? false : favoriteData[prodId] ?? false,
          imageUrl: prodData['imageUrl'],
          description: prodData['description'],
        )); // add all data to loadedProduct list
        _items = loadedProducts;
        notifyListeners();
      });
    } catch (err) {
      rethrow;
    }
  }

  Future<void> addProduct(Product product) async {
    final url = Uri.https(
        'flutter-shop-587b2-default-rtdb.firebaseio.com', '/products.json', {
      'auth': authToken,
    });

    try {
      final response = await http.post(url,
          body: json.encode({
            'creatorId': userId,
            'title': product.title,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'price': product.price,
          }));
      print(userId);
      final newProduct = Product(
          title: product.title,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl,
          id: DateTime.now().toString());

      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((product) => product.id == id);
    if (prodIndex >= 0) {
      final url = Uri.https(
          'flutter-shop-587b2-default-rtdb.firebaseio.com',
          '/products/$id.json',
          {'auth': authToken}); //dynamically get id of product
      await http.patch(url,
          body: json.encode({
            //edit data in database without recreate all the subtitle
            'title': newProduct.title,
            'description': newProduct.description,
            'imageUrl': newProduct.imageUrl,
            'price': newProduct.price
          }));
      _items[prodIndex] = newProduct; //update in local memory
      notifyListeners();
    } else {
      //...
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = Uri.https('flutter-shop-587b2-default-rtdb.firebaseio.com',
        '/products/$id.json', {'auth': authToken});
    final existingProductIndex = _items.indexWhere((item) => item.id == id);
    Product? existingProduct =
        _items[existingProductIndex]; //create temp backup in memory

    _items.removeAt(existingProductIndex); //remove item from the list
    notifyListeners();

    //optimistic update
    final response = await http.delete(url); //delete from database
    //delete dont get error code
    //so we create own custom error handler
    if (response.statusCode >= 400) {
      //status code of error is 4xx
      _items.insert(existingProductIndex,
          existingProduct); //if delete failed, reinsert back the product to the list
      throw HttpException(
          'Could not delete product.'); //since we throw exception, it will now go to 'catchError'
      //throw also act like return, so when error occured, the function will stop
    }
    existingProduct = null; //if delete success, delete backup from memory
  }
}
