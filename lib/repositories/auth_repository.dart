// ignore_for_file: avoid_print

import 'package:chat_app_diplom/constants.dart';
import 'package:chat_app_diplom/entity/auth_response_model.dart';
import 'package:chat_app_diplom/entity/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  AuthRepository(this._firestore, this._auth);

  Future<User?> currentUser() async {
    return _auth.currentUser;
  }

  Future<bool> checkIfUserExists(String? uid) async {
    final docSnapshot = await _firestore
        .collection(Constants.users)
        .doc(uid)
        .get();
    
    return docSnapshot.exists;
  }

  Future<void> updateUserStatus({required bool value, User? currentUser}) async {
    await _firestore
        .collection(Constants.users)
        .doc(currentUser!.uid)
        .update({Constants.isOnline: value});
  }

  Future<void> updateUserAboutMe({required String value, User? currentUser}) async {
    await _firestore
        .collection(Constants.users)
        .doc(currentUser!.uid)
        .update({Constants.aboutMe: value});
  }

   Future<UserModel> getUserData(String uid) async {
    final docSnapshot = await _firestore
        .collection(Constants.users)
        .doc(uid)
        .get();
    
    if (!docSnapshot.exists) {
      throw Exception('User not found');
    }
    
    return UserModel.fromMap(docSnapshot.data() as Map<String, dynamic>);
  }


  Future<AuthResponseModel> sendCodeEmail({
    required String email,
    required String password,
  }) async {
    try {
      // Try to sign in (check if user exists)
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // If successful, user already exists

    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        return AuthResponseModel(
          isSuccessful: false,
          errorMessage: 'wrong-password',
        );
      }
      
      if (e.code == 'user-not-found') {
        // User doesn't exist, send verification email
        return AuthResponseModel(
          isSuccessful: false,
          errorMessage: 'user-not-found',
        );
      }
      
      return AuthResponseModel(
        isSuccessful: false,
        errorMessage: e.message ?? 'Неизвестная ошибка аутентификации',
      );
    } catch (e) {
      return AuthResponseModel(
        isSuccessful: false,
        errorMessage: 'Произошла ошибка при отправке кода',
      );
    }
    return AuthResponseModel(
      isSuccessful: true,
      errorMessage: null,
    );
  }

  Future<AuthResponseModel> signInWithEmailAndPassword({
    required String email,
    required String password, 
  }) async {
    var user = AuthResponseModel(
            isSuccessful: false,
            email: null,
            uid: null,
            errorMessage: null
    );
    try {
      final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      user = AuthResponseModel(
            isSuccessful: true,
            email: credential.user!.email,
            uid: credential.user!.uid,
            errorMessage: null
          );
      return user;
    } on FirebaseAuthException catch (e) {
      if(e.code == 'wrong-password'){
        user = AuthResponseModel(
            isSuccessful: false,
            email: null,
            uid: null,
            errorMessage: "wrong-password"
        );
        return user;
      }
      if(e.code == 'user-not-found'){
        user = AuthResponseModel(
            isSuccessful: false,
            email: null,
            uid: null,
            errorMessage: "user-not-found"
        );
        return user;
      }
    }
    return user;
  }



  Future<AuthResponseModel> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = AuthResponseModel(
        isSuccessful: true,
        email: FirebaseAuth.instance.currentUser!.email,
        uid: FirebaseAuth.instance.currentUser!.uid,
        errorMessage: null,
      );
      return user;
    } on FirebaseAuthException catch (e) {
      final user = AuthResponseModel(
        isSuccessful: false,
        email: FirebaseAuth.instance.currentUser!.email,
        uid: FirebaseAuth.instance.currentUser!.uid,
        errorMessage: e.code,
      );
      return user;
    }
  }

  Future<AuthResponseModel> saveUserDataToFireStore({
    required UserModel userModel,
  }) async {
    try {
      await _firestore
          .collection(Constants.users)
          .doc(userModel.uid)
          .set(userModel.toMap());
      return AuthResponseModel(
            isSuccessful: true,
            errorMessage: null,
      );
    } on FirebaseException catch (e) {
      return AuthResponseModel(
            isSuccessful: false,
            errorMessage: e.code,
      );
    }
  }

  Stream<DocumentSnapshot> userStream({required String userID}) {
    return _firestore.collection(Constants.users).doc(userID).snapshots();
  }

  Future logout() async{
    await _auth.signOut();
  }

  Stream<QuerySnapshot> getAllUsersStream({required String userID}) {
    return _firestore
        .collection(Constants.users)
        .where(Constants.uid, isNotEqualTo: userID)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> searchUsers({required String searchTerm, required String userID}) {
    return _firestore
      .collection(Constants.users)  
      .where(
        Constants.name,
        isGreaterThanOrEqualTo: searchTerm,
        isLessThan: searchTerm.substring(0, searchTerm.length - 1) +
          String.fromCharCode(searchTerm.codeUnitAt(searchTerm.length - 1) + 1)
      )
      .snapshots();
  }
  
  Stream<QuerySnapshot<Map<String, dynamic>>> searchChats({required String searchTerm, required String userID}) {
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
      .snapshots();

  } 

  Future<void> sendFriendRequest({
    required String friendID,
    required String? uid,
  }) async {
    try {
      // add our uid to friends request list
      await _firestore.collection(Constants.users).doc(friendID).update({
        Constants.friendRequestsUIDs: FieldValue.arrayUnion([uid]),
      });

      // add friend uid to our friend requests sent list
      await _firestore.collection(Constants.users).doc(uid).update({
        Constants.sentFriendRequestsUIDs: FieldValue.arrayUnion([friendID]),
      });
    } on FirebaseException catch (e) {
      // ignore: duplicate_ignore
      // ignore: avoid_print
      print(e);
    }
  }


  Future<void> cancelFriendRequest({
    required String friendID,
    required String? uid,
  }) async {
    try {
      // remove our uid from friends request list
      await _firestore.collection(Constants.users).doc(friendID).update({
        Constants.friendRequestsUIDs: FieldValue.arrayRemove([uid]),
      });

      // remove friend uid from our friend requests sent list
      await _firestore.collection(Constants.users).doc(uid).update({
        Constants.sentFriendRequestsUIDs: FieldValue.arrayRemove([friendID]),
      });
    } on FirebaseException catch (e) {
      print(e);
    }
  }

  Future<void> acceptFriendRequest({
    required String friendID,
    required String? uid,
  }) async {
    // add our uid to friends list
    await _firestore.collection(Constants.users).doc(friendID).update({
      Constants.friendsUIDs: FieldValue.arrayUnion([uid]),
    });

    // add friend uid to our friends list
    await _firestore.collection(Constants.users).doc(uid).update({
      Constants.friendsUIDs: FieldValue.arrayUnion([friendID]),
    });

    // remove our uid from friends request list
    await _firestore.collection(Constants.users).doc(friendID).update({
      Constants.sentFriendRequestsUIDs: FieldValue.arrayRemove([uid]),
    });

    // remove friend uid from our friend requests sent list
    await _firestore.collection(Constants.users).doc(uid).update({
      Constants.friendRequestsUIDs: FieldValue.arrayRemove([friendID]),
    });
  }


  Future<void> removeFriend({
    required String friendID,
    required String? uid
  }) async {
    // remove our uid from friends list
    await _firestore.collection(Constants.users).doc(friendID).update({
      Constants.friendsUIDs: FieldValue.arrayRemove([uid]),
    });

    // remove friend uid from our friends list
    await _firestore.collection(Constants.users).doc(uid).update({
      Constants.friendsUIDs: FieldValue.arrayRemove([friendID]),
    });
  }


  Future<List<dynamic>> getListUIDs(
    String uid,
    String typeCollection,
    String typeSnapshot
  ) async {

    DocumentSnapshot documentSnapshot =
        await _firestore.collection(typeCollection).doc(uid).get();

    List<dynamic> friendsUIDs = documentSnapshot.get(typeSnapshot);

    return friendsUIDs;
  }

  Future<Map<String, dynamic>> getDocumentInCollectionUsers(
    // ignore: non_constant_identifier_names
    String UID,
  ) async {

    DocumentSnapshot documentSnapshot =
          await _firestore.collection(Constants.users).doc(UID).get();
          
    return documentSnapshot.data() as Map<String, dynamic>;
  }

  


}

