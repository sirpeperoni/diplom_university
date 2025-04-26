import 'dart:convert';

import 'package:chat_app_diplom/constants.dart';
import 'package:chat_app_diplom/entity/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesRepository {
  final SharedPreferences _sharedPreferences;

  SharedPreferencesRepository(this._sharedPreferences);

  Future<void> saveUserData(String key, String jsonData) async {
    await _sharedPreferences.setString(key, jsonData);
  }

  Future<UserModel> getUserDataFromSharedPreferences() async {
    String userModelString = _sharedPreferences.getString(Constants.userModel) ?? '';
    return UserModel.fromMap(jsonDecode(userModelString));
  }

  Future<void> saveOTPToSharedPrefernce(String otp) async {
    await _sharedPreferences.setString('otp_code', otp);
    await _sharedPreferences.setInt('otp_timestamp', DateTime.now().millisecondsSinceEpoch);
  }

  Future<bool> checkOTP(String? otp) async {
    final savedOTP = _sharedPreferences.getString('otp_code');
    if(otp == savedOTP){
      return true;
    }
    return false;
  }

  String? getCommonKey( String contactUID) {
    return _sharedPreferences.getString("commonKey_$contactUID");
  }

  Future clear() async {
    await _sharedPreferences.clear();
  }

  String? getChatId(contactUID){
    return _sharedPreferences.getString("chatId_$contactUID");
  }

}