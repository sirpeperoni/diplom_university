// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:chat_app_diplom/constants.dart';
import 'package:chat_app_diplom/entity/auth_response_model.dart';
import 'package:chat_app_diplom/entity/email_data.dart';
import 'package:chat_app_diplom/entity/last_message_model.dart';
import 'package:chat_app_diplom/entity/user_model.dart';
import 'package:chat_app_diplom/repositories/auth_repository.dart';
import 'package:chat_app_diplom/repositories/email_repository.dart';
import 'package:chat_app_diplom/repositories/shared_preferences_repository.dart';
import 'package:chat_app_diplom/utilities/global_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class AuthenticationProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  final SharedPreferencesRepository _sharedPreferencesRepository;
  final EmailRepository _emailRepository;
  AuthenticationProvider(this._authRepository, this._sharedPreferencesRepository, this._emailRepository);

  bool _isLoading = false;
  bool _isSuccessful = false;
  String? _uid;
  String? _email;
  UserModel? _userModel;

  bool get isLoading => _isLoading;
  bool get isSuccessful => _isSuccessful;
  String? get uid => _uid;
  String? get email => _email;
  UserModel? get userModel => _userModel;

  final dio = Dio();
  
  //check authentication state
  Future<bool> checkAuthenticationState() async {
    bool isSignedIn = false;
    await Future.delayed(const Duration(seconds: 2));
    if(await _authRepository.currentUser() != null) {
      final currentUser = await _authRepository.currentUser();
      _uid = currentUser!.uid;
      
      await getUserDataFromFirestore();

      await saveUserData();

      notifyListeners();
      isSignedIn = true;
    } else {
      isSignedIn = false;
    }
    notifyListeners();
    return isSignedIn;
  }

  // check if user exists
  Future<bool> checkIfUserExists() async {
    return _authRepository.checkIfUserExists(uid);
  }

  

  // update user status
  Future<void> updateUserStatus({required bool value}) async {
    await _authRepository.updateUserStatus(value: value, currentUser: await _authRepository.currentUser());
  }

  Future<void> updateUserAboutMe({required String value}) async {
    await _authRepository.updateUserAboutMe(value: value, currentUser: await _authRepository.currentUser());
  }

  //get user data from firestore
  Future<void> getUserDataFromFirestore() async {
    _userModel = await _authRepository.getUserData(uid!);
    notifyListeners();
  }

  //save user data to shared preferences
  Future<void> saveUserData() async {
    if (userModel == null) {
      throw Exception("UserModel is null");
    }
    final jsonData = jsonEncode(userModel!.toMap());
    await _sharedPreferencesRepository.saveUserData(Constants.userModel, jsonData);
  }

  //get user data from shared preferences
  Future<void> getUserDataFromSharedPreferences() async {
    _userModel = await _sharedPreferencesRepository.getUserDataFromSharedPreferences();
    _uid = _userModel!.uid;
    _email = _userModel!.email;
    notifyListeners();
  }

  //sign in with email and password
  String generateOTP() {
    return (100000 + Random().nextInt(900000)).toString();
  }

  Future<void> saveOTPToSharedPrefernce(String otp) async {
    // Сохраняем OTP в SharedPreferences
    _sharedPreferencesRepository.saveOTPToSharedPrefernce(otp);
  }

  

  //sign in with phone number
  Future<void> sendCodeEmail({
    required String email,
    required String password,
    required String otp,
    required BuildContext context
  }) async {
    _isLoading = true;
    notifyListeners();
    final responseModel = await _authRepository.sendCodeEmail(
      email: email, 
      password: password
    );
    if(responseModel.isSuccessful){
      _isSuccessful = responseModel.isSuccessful;
      _isLoading = false;
      // ignore: duplicate_ignore
      // ignore: use_build_context_synchronously
      showSnackBar(context, 'Такой пользователь уже зарегистрирован');
      notifyListeners();
    }
    if(responseModel.errorMessage == 'wrong-password'){
      _isSuccessful = false;
      _isLoading = false;
      showSnackBar(context, 'Такой пользователь уже зарегистрирован');
      notifyListeners();
    }
    if(responseModel.errorMessage == 'user-not-found'){  
      final requestModel = EmailData(
        email: email, 
        otp: otp
      );
      await _emailRepository.sendOtpCode(requestModel);
      
      Navigator.pushNamed(context, Constants.otpScreen, arguments: {
          Constants.email: email,
          Constants.password: password,
      });
    } 
  }

  Future<bool> checkOTP(String? otp) async {
    return _sharedPreferencesRepository.checkOTP(otp);
  }

  // verify otp code
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password, 
    required BuildContext context,
    required Function onSuccess
  }) async {
    _isLoading = true;
    notifyListeners();
    final user = await _authRepository.signInWithEmailAndPassword(email: email, password: password);
    if(user.isSuccessful){
      _uid = user.uid;
      _email = user.email;
      _isSuccessful = true;
      _isLoading = false;
      onSuccess();
      notifyListeners();
    }
    if(user.errorMessage == "wrong-password"){
      showSnackBarAndSetLoadingAndSuccessful(context, user, "Неправильный email или пароль", false);
    }
    if(user.errorMessage == 'user-not-found'){
      showSnackBarAndSetLoadingAndSuccessful(context, user, "Такого пользователя не существует", false);
    }
  }

  void showSnackBarAndSetLoadingAndSuccessful(BuildContext context, AuthResponseModel user, String message, bool isLoading) {
    showSnackBar(context, message);
    _isLoading = false;
    _isSuccessful = user.isSuccessful;
    notifyListeners();
  }

  //register with email and password
  Future<void> registerWithEmailAndPassword({
    required String email,
    required String password,
    required BuildContext context,
    required Function onSuccess
  }) async {
    _isLoading = true;
    notifyListeners();
    final user = await _authRepository.registerWithEmailAndPassword(email: email, password: password);
    
    if(user.isSuccessful){
      _isLoading = false;
      _uid = user.uid;
      _email = user.email;
      notifyListeners();
      onSuccess();
    } else {
      showSnackBar(context, 'Неизвестная ошибка при создании аккаунта');
      _isLoading = false;
      _isSuccessful = true;
      notifyListeners();
    }

  }
  
  //save user data to firestore
  void saveUserDataToFireStore({
    required UserModel userModel,
    required File? fileImage,
    required Function onSuccess,
    required Function onFail,
  }) async {
    _isLoading = true;
    notifyListeners();
    if (fileImage != null) {
      // upload image to storage
      List<String> imageUrl = await storeFileToStorage(file: fileImage, reference:'${Constants.userImages}/${userModel.uid}');
      userModel.image = imageUrl[0];
    }
    userModel.lastSeen = DateTime.now().microsecondsSinceEpoch.toString();
    userModel.createdAt = DateTime.now().microsecondsSinceEpoch.toString();
    _userModel = userModel;
    _uid = userModel.uid;
    final result = await _authRepository.saveUserDataToFireStore(userModel: userModel);
    
    if(result.isSuccessful){
      _isLoading = false;
      _isSuccessful = true;
      notifyListeners();
      onSuccess();
    } else {
      _isLoading = false;
      _isSuccessful = false;
      notifyListeners();
      onFail();
    }

  }

  Stream<DocumentSnapshot> userStream({required String userID}) {
    return _authRepository.userStream(userID: userID);
  }



  Future logout() async {
    _authRepository.logout();
    _uid = null;
    _email = null;
    //_sharedPreferencesRepository.clear();
    notifyListeners();
  }

  Stream<QuerySnapshot> getAllUsersStream({required String userID}) {
    return _authRepository.getAllUsersStream(userID: userID);
  }

  //get users who have these words in their name and are not me
  Stream<List<UserModel>>? searchUsers({required String searchTerm, required String userID}) {
    if(searchTerm.isEmpty){
      return null;
    }
    return _authRepository.searchUsers(searchTerm: searchTerm, userID: userID)
      .map((snapshot) {
        return snapshot.docs
              .where((doc) => doc.id != userID)
              .map((doc) => UserModel.fromMap(doc.data()))
              .toList();
      });
  }

  Stream<List<LastMessageModel>>? searchChats({required String searchTerm, required String userID}) {
    if(searchTerm.isEmpty){
      return null;
    }
    return _authRepository.searchChats(searchTerm: searchTerm, userID: userID)
      .map((snapshot) {
        return snapshot.docs
          .map((doc) => LastMessageModel.fromMap(doc.data()))
          .toList();
      });
  }    


  // ignore: prefer_typing_uninitialized_variables
  var _streamUsers;
  // ignore: prefer_typing_uninitialized_variables
  var _streamChats;

  get streamUsers => _streamUsers;
  get streamChats => _streamChats;

  void getStreamChats(String searchTerm, String userID) {
    _streamChats = searchChats(searchTerm: searchTerm, userID: userID);
    notifyListeners();
  }

  void getStreamUsers(String searchTerm, String userID) {
    _streamUsers = searchUsers(searchTerm: searchTerm, userID: userID);
    notifyListeners();
  }


  // send friend request
  Future<void> sendFriendRequest({
    required String friendID,
  }) async {
    _authRepository.sendFriendRequest(friendID: friendID, uid: _uid);
  }

  Future<void> cancelFriendRequest({required String friendID}) async {
    _authRepository.cancelFriendRequest(friendID: friendID, uid: _uid);
  }

  Future<void> acceptFriendRequest({required String friendID}) async {
    _authRepository.acceptFriendRequest(friendID: friendID, uid: _uid);
  }

  // remove friend
  Future<void> removeFriend({required String friendID}) async {
    _authRepository.removeFriend(friendID: friendID, uid: _uid);
  }


  // get a list of friends
  Future<List<UserModel>> getFriendsList(
    String uid,
  ) async {
    List<UserModel> friendsList = [];

    final friendsUIDs = await _authRepository.getListUIDs(uid, Constants.users, Constants.friendsUIDs);

    for (String friendUID in friendsUIDs) {
      UserModel friend =
          UserModel.fromMap(await _authRepository.getDocumentInCollectionUsers(friendUID));
      friendsList.add(friend);
    }

    return friendsList;
  }
  
   // get a list of friend requests
  Future<List<UserModel>> getFriendRequestsList({
    required String uid,
  }) async {
    List<UserModel> friendRequestsList = [];

    List<dynamic> friendRequestsUIDs = await _authRepository.getListUIDs(uid, Constants.users, Constants.friendRequestsUIDs);

    for (String friendRequestUID in friendRequestsUIDs) {
      UserModel friendRequest =
          UserModel.fromMap(await _authRepository.getDocumentInCollectionUsers(friendRequestUID));
      friendRequestsList.add(friendRequest);
    }

    return friendRequestsList;
  }

  
}

