import 'dart:convert';
import 'dart:io';

import 'package:chat_app_diplom/constants.dart';
import 'package:chat_app_diplom/entity/last_message_model.dart';
import 'package:chat_app_diplom/entity/user_model.dart';
import 'package:chat_app_diplom/utilities/global_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticationProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isSuccessful = false;
  String? _uid;
  String? _phoneNumber;
  UserModel? _userModel;

  bool get isLoading => _isLoading;
  bool get isSuccessful => _isSuccessful;
  String? get uid => _uid;
  String? get phoneNumber => _phoneNumber;
  UserModel? get userModel => _userModel;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage  _storage = FirebaseStorage.instance;

  //check authentication state
  Future<bool> checkAuthenticationState() async {
    bool isSignedIn = false;
    await Future.delayed(const Duration(seconds: 2));
    if(_auth.currentUser != null) {
      _uid = _auth.currentUser!.uid;
      
      await getUserDataFromFirestore();

      await saveUserDataToSharedPreferences();

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
    DocumentSnapshot documentSnapshot = await _firestore.collection(Constants.users).doc(_uid).get();
    if (documentSnapshot.exists) {
      return true;
    } else {
      return false;
    }
  }

  // update user status
  Future<void> updateUserStatus({required bool value}) async {
    await _firestore
        .collection(Constants.users)
        .doc(_auth.currentUser!.uid)
        .update({Constants.isOnline: value});
  }

  Future<void> updateUserAboutMe({required String value}) async {
    await _firestore
        .collection(Constants.users)
        .doc(_auth.currentUser!.uid)
        .update({Constants.aboutMe: value});
  }

  //get user data from firestore
  Future<void> getUserDataFromFirestore() async {
    DocumentSnapshot documentSnapshot = await _firestore.collection(Constants.users).doc(_uid).get();
    _userModel = UserModel.fromMap(documentSnapshot.data() as Map<String, dynamic>);
    notifyListeners();
  }

  //save user data to shared preferences
  Future<void> saveUserDataToSharedPreferences() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString(Constants.userModel, jsonEncode(userModel!.toMap()));
  }

  //get user data from shared preferences
  Future<void> getUserDataFromSharedPreferences() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String userModelString = sharedPreferences.getString(Constants.userModel) ?? '';
    _userModel = UserModel.fromMap(jsonDecode(userModelString));
    _uid = _userModel!.uid;
    _phoneNumber = _userModel!.phoneNumber;
    notifyListeners();
  }


  //sign in with phone number
  Future<void> signInWithPhoneNumber({required String phoneNumber,required BuildContext context}) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential).then((value) async {
            _uid = value.user!.uid;
            _phoneNumber = value.user!.phoneNumber;
            _isSuccessful = true;
            _isLoading = false;
            notifyListeners();
          });
        },
        verificationFailed: (FirebaseAuthException e) {
          _isSuccessful = false;
          _isLoading = false;
          notifyListeners();
          showSnackBar(context, e.toString());
        },
        codeSent: (String verificationId, int? resendToken) {
          _isLoading = false;
          notifyListeners();
          //navigate to otp screen
          Navigator.pushNamed(context, Constants.otpScreen, arguments: {
            Constants.phoneNumber: phoneNumber,
            Constants.verificationId: verificationId,
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // verify otp code
  Future<void> verifyOTP({
    required String verificationId,
    required String otpCode, 
    required BuildContext context,
    required Function onSuccess  
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: otpCode);
      await _auth.signInWithCredential(credential).then((value) async {
        _uid = value.user!.uid;
        _phoneNumber = value.user!.phoneNumber;
        _isSuccessful = true;
        _isLoading = false;
        onSuccess();
        notifyListeners();
      });
    } catch (e) {
      _isLoading = false;
      _isSuccessful = false;
      notifyListeners();
      showSnackBar(context, e.toString());
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

    try {
      if (fileImage != null) {
        // upload image to storage
        List<String> imageUrl = await storeFileToStorage(file: fileImage, reference:'${Constants.userImages}/${userModel.uid}');

        userModel.image = imageUrl[0];
      }

      userModel.lastSeen = DateTime.now().microsecondsSinceEpoch.toString();
      userModel.createdAt = DateTime.now().microsecondsSinceEpoch.toString();

      _userModel = userModel;
      _uid = userModel.uid;


      // save user data to firestore
      await _firestore
          .collection(Constants.users)
          .doc(userModel.uid)
          .set(userModel.toMap());

      _isLoading = false;
      notifyListeners();
      onSuccess();
      notifyListeners();
    } on FirebaseException catch (e) {
      _isLoading = false;
      notifyListeners();
      onFail(e.toString());
    }
  }

   Stream<DocumentSnapshot> userStream({required String userID}) {
    return _firestore.collection(Constants.users).doc(userID).snapshots();
  }



  Future logout() async {
    await _auth.signOut();
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.clear();
    notifyListeners();
  }

  Stream<QuerySnapshot> getAllUsersStream({required String userID}) {
    return _firestore
        .collection(Constants.users)
        .where(Constants.uid, isNotEqualTo: userID)
        .snapshots();
  }

  //get users who have these words in their name and are not me
  Stream<List<UserModel>>? searchUsers({required String searchTerm, required String userID}) {
    if(searchTerm.isEmpty){
      return null;
    }
    return _firestore
      .collection(Constants.users)  
      .where(
        Constants.name,
        isGreaterThanOrEqualTo: searchTerm,
        isLessThan: searchTerm.substring(0, searchTerm.length - 1) +
          String.fromCharCode(searchTerm.codeUnitAt(searchTerm.length - 1) + 1)
      )
      .snapshots()
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
    return _firestore
      .collection(Constants.users)
      .doc(userID)
      .collection(Constants.chats)
      .where(
        Constants.contactName,
        isGreaterThanOrEqualTo: searchTerm,
        isLessThan: searchTerm.substring(0, searchTerm.length - 1) +
          String.fromCharCode(searchTerm.codeUnitAt(searchTerm.length - 1) + 1)
      )
      .snapshots()
      .map((snapshot) {
        return snapshot.docs
          .map((doc) => LastMessageModel.fromMap(doc.data()))
          .toList();
      });

  }    


  var _streamUsers;
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
    try {
      // add our uid to friends request list
      await _firestore.collection(Constants.users).doc(friendID).update({
        Constants.friendRequestsUIDs: FieldValue.arrayUnion([_uid]),
      });

      // add friend uid to our friend requests sent list
      await _firestore.collection(Constants.users).doc(_uid).update({
        Constants.sentFriendRequestsUIDs: FieldValue.arrayUnion([friendID]),
      });
    } on FirebaseException catch (e) {
      print(e);
    }
  }

  Future<void> cancleFriendRequest({required String friendID}) async {
    try {
      // remove our uid from friends request list
      await _firestore.collection(Constants.users).doc(friendID).update({
        Constants.friendRequestsUIDs: FieldValue.arrayRemove([_uid]),
      });

      // remove friend uid from our friend requests sent list
      await _firestore.collection(Constants.users).doc(_uid).update({
        Constants.sentFriendRequestsUIDs: FieldValue.arrayRemove([friendID]),
      });
    } on FirebaseException catch (e) {
      print(e);
    }
  }

   Future<void> acceptFriendRequest({required String friendID}) async {
    // add our uid to friends list
    await _firestore.collection(Constants.users).doc(friendID).update({
      Constants.friendsUIDs: FieldValue.arrayUnion([_uid]),
    });

    // add friend uid to our friends list
    await _firestore.collection(Constants.users).doc(_uid).update({
      Constants.friendsUIDs: FieldValue.arrayUnion([friendID]),
    });

    // remove our uid from friends request list
    await _firestore.collection(Constants.users).doc(friendID).update({
      Constants.sentFriendRequestsUIDs: FieldValue.arrayRemove([_uid]),
    });

    // remove friend uid from our friend requests sent list
    await _firestore.collection(Constants.users).doc(_uid).update({
      Constants.friendRequestsUIDs: FieldValue.arrayRemove([friendID]),
    });
  }

  // remove friend
  Future<void> removeFriend({required String friendID}) async {
    // remove our uid from friends list
    await _firestore.collection(Constants.users).doc(friendID).update({
      Constants.friendsUIDs: FieldValue.arrayRemove([_uid]),
    });

    // remove friend uid from our friends list
    await _firestore.collection(Constants.users).doc(_uid).update({
      Constants.friendsUIDs: FieldValue.arrayRemove([friendID]),
    });
  }


  // get a list of friends
  Future<List<UserModel>> getFriendsList(
    String uid,
  ) async {
    List<UserModel> friendsList = [];

    DocumentSnapshot documentSnapshot =
        await _firestore.collection(Constants.users).doc(uid).get();

    List<dynamic> friendsUIDs = documentSnapshot.get(Constants.friendsUIDs);

    for (String friendUID in friendsUIDs) {
      DocumentSnapshot documentSnapshot =
          await _firestore.collection(Constants.users).doc(friendUID).get();
      UserModel friend =
          UserModel.fromMap(documentSnapshot.data() as Map<String, dynamic>);
      friendsList.add(friend);
    }

    return friendsList;
  }
  
   // get a list of friend requests
  Future<List<UserModel>> getFriendRequestsList({
    required String uid,
  }) async {
    List<UserModel> friendRequestsList = [];



    DocumentSnapshot documentSnapshot =
        await _firestore.collection(Constants.users).doc(uid).get();

    List<dynamic> friendRequestsUIDs =
        documentSnapshot.get(Constants.friendRequestsUIDs);

    for (String friendRequestUID in friendRequestsUIDs) {
      DocumentSnapshot documentSnapshot = await _firestore
          .collection(Constants.users)
          .doc(friendRequestUID)
          .get();
      UserModel friendRequest =
          UserModel.fromMap(documentSnapshot.data() as Map<String, dynamic>);
      friendRequestsList.add(friendRequest);
    }

    return friendRequestsList;
  }

  
}

