import 'dart:convert';
import 'package:sales_app/models/login_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  // final box = GetStorage();
  var pref = SharedPreferences.getInstance();
  var userKey = "user";
  var tokenKey = "token";
  var loginKey = "login";
  var passsword = 'password';
  var islogin = 'isLoggedIn';
  var date = 'date';

  getPref() async {
    return await SharedPreferences.getInstance();
  }

  read() async {
    pref = SharedPreferences.getInstance();
  }

  void saveSignInInfo(User? data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (data != null) {
      await prefs.setString(
        loginKey, // now "loginData"
        json.encode(data.toJson()),
      );
    }
  }

  Future<User?> getSignInInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString(loginKey); // now "loginData"
    if (jsonString != null) {
      Map<String, dynamic> jsonMap = json.decode(jsonString);
      return User.fromJson(jsonMap);
    }
    return null;
  }

  Future<void> setisLogin(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(islogin, value); // now "isLoggedIn"
  }

  Future<bool> getLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(islogin) ?? false; // now "isLoggedIn"
  }

  Future<void> setPassword(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(passsword, value);
  }

  Future<String> getPassword() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(passsword) ?? "";
  }

  Future<void> setDate(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(date, value);
  }

  Future<String> getDate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(date) ?? "";
  }

  Future<void> setToken(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, value);
  }

  Future<String> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey) ?? "";
  }

  Future<void> setUserType(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(userKey, value);
  }

  Future<String> getUserType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userKey) ?? "";
  }

  void logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
