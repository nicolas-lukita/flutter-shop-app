import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/http_exception.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  String _token = ''; //will expire
  DateTime _expiryDate = DateTime.now();
  String _userId = '';

  bool get isAuth {
    return token != '';
  }

  String? get token {
    if (_expiryDate.isAfter(DateTime.now()) && _token != '') {
      return _token;
    } else {
      return '';
    }
  }

  String get userId {
    return _userId;
  }

  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, 'signUp');
    //without return, it will still return a Future but,
    //it will not wait _authenticate to do its job
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    //check if any data stored
    if (!prefs.containsKey('userData')) return false;
    //get data from storage mem and make a list
    final extractedUserData =
        jsonDecode(prefs.getString('userData')!) as Map<String, Object>;
    final expiryDate =
        DateTime.parse(extractedUserData['expiryDate'] as String);
    //check if its not expired yet
    if (expiryDate.isBefore(DateTime.now())) return false;
    //assign token etc
    _token = extractedUserData['token'] as String;
    _userId = extractedUserData['userId'] as String;
    _expiryDate = expiryDate;
    notifyListeners();
    _autoLogout();
    return true;
  }

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    final url = Uri.parse(
        "https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyBTgVbUEV-ugAB39o2lXRR8imh651eqTP4");

    try {
      final response = await http.post(url,
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true
          }));

      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      //get token, id, expiry date (firebase auth rest api documentation)
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now()
          .add(Duration(seconds: int.parse(responseData['expiresIn'])));
      _autoLogout();
      notifyListeners();
      //stay login:
      //use shared_preferences to access device storage
      //shared_preferences use async await
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _expiryDate.toIso8601String()
      });
      //use prefs to write data
      prefs.setString('userData', userData);
    } catch (err) {
      rethrow;
    }
  }

  void logout() async {
    _token = '';
    _userId = '';
    _expiryDate = DateTime.now();
    notifyListeners();

    //clear all data in shared preferences
    final prefs = await SharedPreferences.getInstance();
    //prefs.remove('userData);
    prefs.clear();
  }

  void _autoLogout() {
    late Timer _authTimer;
    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }
}
