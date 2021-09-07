import 'package:flutter/material.dart';
import 'package:flutter_auth_app/utils/api_urls.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';


enum Status { Uninitialized, Authenticated, Authenticating, Unauthenticated }

class AuthProvider with ChangeNotifier {

  Status _status = Status.Uninitialized;
  late String _token;

  Status get status => _status;
  String get token => _token;

  initAuthProvider() async {
    String token = await getToken();
    if (token != null) {
      _token = token;
      _status = Status.Authenticated;
    } else {
      _status = Status.Unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _status = Status.Authenticating;
    notifyListeners();
    final url = Uri.parse(ApiUrls.login);

    Map<String, String> body = {
      'email': email,
      'password': password,
    };

    Map<String, String> headers = {
      'accept': 'application/json'
    };
    final response = await http.post(url, body: body, headers: headers);
    print(response.statusCode);

    if (response.statusCode == 200) {
      Map<String, dynamic> apiResponse = json.decode(response.body);
      _status = Status.Authenticated;
      _token = apiResponse['token'];
      await storeUserData(apiResponse);
      notifyListeners();
      return true;
    }

    if (response.statusCode == 404) {
      _status = Status.Unauthenticated;
      notifyListeners();
      print('failed');
      return false;
    }

    _status = Status.Unauthenticated;
    notifyListeners();
    return false;
  }

  Future<bool> register(String name, String email, String password, String passwordConfirm) async {
    final url = Uri.parse(ApiUrls.register);

    Map<String, String> body = {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirm,
    };

    Map<String, String> headers = {
      'accept': 'application/json'
    };

    Map<String, dynamic> result = {
      "success": false,
      "message": 'Unknown error.'
    };

    final response = await http.post( url, body: body, headers: headers);

    if (response.statusCode == 201) {
      Map<String, dynamic> apiResponse = json.decode(response.body);
      _status = Status.Authenticated;
      _token = apiResponse['token'];
      print(apiResponse);
      await storeUserData(apiResponse);
      notifyListeners();
      return true;
    }

    if (response.statusCode == 409) {
      _status = Status.Unauthenticated;
      notifyListeners();
      print('failed');
      return false;
    }

    _status = Status.Unauthenticated;
    notifyListeners();
    return false;
  }

  storeUserData(apiResponse) async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    await storage.setString('token', apiResponse['token']);
    await storage.setString('name', apiResponse['user']['name']);
    await storage.setString('email', apiResponse['user']['email']);
    await storage.setInt('id', apiResponse['user']['id']);
  }

  Future<String> getToken() async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    String? token = storage.getString('token');
    return token ?? '';
  }

  logOut() async {
    _status = Status.Unauthenticated;
    notifyListeners();
    final url = Uri.parse(ApiUrls.logout);
    String token = await getToken();
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final response = await http.post( url, headers: headers);
    SharedPreferences storage = await SharedPreferences.getInstance();
    await storage.clear();
  }

}