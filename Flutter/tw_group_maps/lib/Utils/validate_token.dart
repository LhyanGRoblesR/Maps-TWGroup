// ignore: file_names
// ignore_for_file: avoid_print

import 'package:shared_preferences/shared_preferences.dart';

class ValidateToken {
  static Future<bool> isAuthenticated() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final int? expiration = prefs.getInt('expiration');

    if (token == null || expiration == null) {
      return false;
    }
  
    final DateTime now = DateTime.now();

    final int secondsSinceEpoch = now.millisecondsSinceEpoch ~/ 1000;

    final int expirationTime = expiration - secondsSinceEpoch;

    print('expirationBool $expirationTime -- $secondsSinceEpoch -- $expiration');  
    if (expirationTime <= 0){ 
      prefs.clear();
      return false;   
    }  
    return true;
  }

}