import 'dart:io';

import 'package:chat_app_diplom/constants.dart';
import 'package:chat_app_diplom/entity/last_message_model.dart';
import 'package:chat_app_diplom/entity/message_model.dart';
import 'package:chat_app_diplom/entity/message_reply_model.dart';
import 'package:chat_app_diplom/entity/user_model.dart';
import 'package:chat_app_diplom/enums/enums.dart';
import 'package:chat_app_diplom/utilities/global_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class ChatProvider extends ChangeNotifier {
  bool _isLoading = false;
  MessageReplyModel? messageReplyModel;
  final dio = Dio();

  bool get isLoading => _isLoading;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseStorage _storage = FirebaseStorage.instance;

  // set message reply model
  void setMessageReplyModel(MessageReplyModel? messageReply){
    messageReplyModel = messageReply;
    notifyListeners();
  }

  // send text message to firestore
  Future<void> sendTextMessage({
    required UserModel sender,
    required String contactUID,
    required String contactName,
    required String contactImage,
    required String message,
    required MessageEnum messageType,
    required Function onSucess,
    required Function(String) onError,
  }) async {
    // set loading to true
    setLoading(true);
    try {
      var messageId = const Uuid().v4();

      // 1. check if its a message reply and add the replied message to the message
      String repliedMessage = messageReplyModel?.message ?? '';
      String repliedTo = messageReplyModel == null
          ? ''
          : messageReplyModel!.isMe
              ? 'You'
              : messageReplyModel!.senderName;
      MessageEnum repliedMessageType =
          messageReplyModel?.messageType ?? MessageEnum.text;

      // 2. update/set the messagemodel
      final messageModel = MessageModel(
        senderUID: sender.uid,
        senderName: sender.name,
        senderImage: sender.image,
        contactUID: contactUID,
        message: message,
        messageType: messageType,
        timeSent: DateTime.now(),
        messageId: messageId,
        isSeen: false,
        repliedMessage: repliedMessage,
        repliedTo: repliedTo,
        repliedMessageType: repliedMessageType,
        reactions: [],
        isSeenBy: [sender.uid],
        deletedBy: [],
      );


        // handle contact message
        await handleContactMessage(
          messageModel: messageModel,
          contactUID: contactUID,
          contactName: contactName,
          contactImage: contactImage,
          onSucess: onSucess,
          onError: onError,
        );

        // set message reply model to null
        setMessageReplyModel(null);
      }
      catch (e) {
      // set loading to true
      setLoading(false);
      onError(e.toString());
    }
  }


    // send file message to firestore
  Future<void> sendFileMessage({
    required UserModel sender,
    required String contactUID,
    required String contactName,
    required String contactImage,
    required File file,
    required MessageEnum messageType,
    required Function onSucess,
    required Function(String) onError,
  }) async {
    // set loading to true
    setLoading(true);
    try {
      var messageId = const Uuid().v4();

      // 1. check if its a message reply and add the replied message to the message
      String repliedMessage = messageReplyModel?.message ?? '';
      String repliedTo = messageReplyModel == null
          ? ''
          : messageReplyModel!.isMe
              ? 'You'
              : messageReplyModel!.senderName;
      MessageEnum repliedMessageType =
          messageReplyModel?.messageType ?? MessageEnum.text;

      // 2. upload file to firebase storage
      final ref =
          '${Constants.chatFiles}/${messageType.name}/${sender.uid}/$contactUID/$messageId';
      List<String> fileUrl = await storeFileToStorage(file: file, reference: ref);

      // 3. update/set the messagemodel
      final messageModel = MessageModel(
        senderUID: sender.uid,
        senderName: sender.name,
        senderImage: sender.image,
        contactUID: contactUID,
        message: fileUrl[0],
        messageType: messageType,
        timeSent: DateTime.now(),
        messageId: messageId,
        isSeen: false,
        repliedMessage: repliedMessage,
        repliedTo: repliedTo,
        repliedMessageType: repliedMessageType,
        reactions: [],
        isSeenBy: [sender.uid],
        deletedBy: [],
        fileType: fileUrl[1],
      );


        // handle contact message
        await handleContactMessage(
          messageModel: messageModel,
          contactUID: contactUID,
          contactName: contactName,
          contactImage: contactImage,
          onSucess: onSucess,
          onError: onError,
        );

        // set message reply model to null
        setMessageReplyModel(null);
      }
     catch (e) {
      // set loading to true
      setLoading(false);
      onError(e.toString());
    }
  }

  Future<void> handleContactMessage({
    required MessageModel messageModel,
    required String contactUID,
    required String contactName,
    required String contactImage,
    required Function onSucess,
    required Function(String p1) onError,
  }) async {
    try {
      // 0. contact messageModel
      final contactMessageModel = messageModel.copyWith(
        userId: messageModel.senderUID,
      );

      // 1. initialize last message for the sender
      final senderLastMessage = LastMessageModel(
        senderUID: messageModel.senderUID,
        contactUID: contactUID,
        contactName: contactName,
        contactImage: contactImage,
        message: messageModel.message,
        messageType: messageModel.messageType,
        timeSent: messageModel.timeSent,
        isSeen: false,
      );

      // 2. initialize last message for the contact
      final contactLastMessage = senderLastMessage.copyWith(
        contactUID: messageModel.senderUID,
        contactName: messageModel.senderName,
        contactImage: messageModel.senderImage,
      );
      // 3. send message to sender firestore location
      await _firestore
          .collection(Constants.users)
          .doc(messageModel.senderUID)
          .collection(Constants.chats)
          .doc(contactUID)
          .collection(Constants.messages)
          .doc(messageModel.messageId)
          .set(messageModel.toMap());
      // 4. send message to contact firestore location
      await _firestore
          .collection(Constants.users)
          .doc(contactUID)
          .collection(Constants.chats)
          .doc(messageModel.senderUID)
          .collection(Constants.messages)
          .doc(messageModel.messageId)
          .set(contactMessageModel.toMap());

      // 5. send the last message to sender firestore location
      await _firestore
          .collection(Constants.users)
          .doc(messageModel.senderUID)
          .collection(Constants.chats)
          .doc(contactUID)
          .set(senderLastMessage.toMap());

      // 6. send the last message to contact firestore location
      await _firestore
          .collection(Constants.users)
          .doc(contactUID)
          .collection(Constants.chats)
          .doc(messageModel.senderUID)
          .set(contactLastMessage.toMap());
      // 7.call onSucess
      // set loading to false
      setLoading(false);
      onSucess();
    } on FirebaseException catch (e) {
      // set loading to false
      setLoading(false);
      onError(e.message ?? e.toString());
    } catch (e) {
      // set loading to false
      setLoading(false);
      onError(e.toString());
    }
  }

    // stream the unread messages for this user
  Stream<int> getUnreadMessagesStream({
    required String userId,
    required String contactUID,
  }) {

      // handle contact message
      return _firestore
        .collection(Constants.users)
        .doc(userId)
        .collection(Constants.chats)
        .doc(contactUID)
        .collection(Constants.messages)
        .where(Constants.isSeen, isEqualTo: false)
        .snapshots()
        .map((event) {
          final a = event.docs.where((element) {
            return element.data()[Constants.senderUID] != userId;
          }).toList();
          return a.length;
        });
  }

  // set message status
  Future<void> setMessageStatus({
    required String currentUserId,
    required String contactUID,
    required String messageId,
  }) async {

      // handle contact message
      // 2. update the current message as seen
      await _firestore
          .collection(Constants.users)
          .doc(currentUserId)
          .collection(Constants.chats)
          .doc(contactUID)
          .collection(Constants.messages)
          .doc(messageId)
          .update({Constants.isSeen: true});
      // 3. update the contact message as seen
      await _firestore
          .collection(Constants.users)
          .doc(contactUID)
          .collection(Constants.chats)
          .doc(currentUserId)
          .collection(Constants.messages)
          .doc(messageId)
          .update({Constants.isSeen: true});

      // 4. update the last message as seen for current user
      await _firestore
          .collection(Constants.users)
          .doc(currentUserId)
          .collection(Constants.chats)
          .doc(contactUID)
          .update({Constants.isSeen: true});

      // 5. update the last message as seen for contact
      await _firestore
          .collection(Constants.users)
          .doc(contactUID)
          .collection(Constants.chats)
          .doc(currentUserId)
          .update({Constants.isSeen: true});
  }
  


  //get chatslist stream
  Stream<List<LastMessageModel>> getChatsListStream(String userId) {
    return _firestore
      .collection(Constants.users)
      .doc(userId)
      .collection(Constants.chats)
      .orderBy(Constants.timeSent, descending: true)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) {
          return LastMessageModel.fromMap(doc.data());
      }).toList();
    });
  }


    // stream messages from chat collection
  Stream<List<MessageModel>> getMessagesStream({
    required String userId,
    required String contactUID,
  }) {
      // handle contact message
      return _firestore
        .collection(Constants.users)
        .doc(userId)
        .collection(Constants.chats)
        .doc(contactUID)
        .collection(Constants.messages)
        //.orderBy(Constants.timeSent, descending: false)
        .snapshots()
        .map((snapshot) {
        return snapshot.docs.map((doc) {
            return MessageModel.fromMap(doc.data());
          }).toList();
        });
    }
}






  