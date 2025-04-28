import 'dart:io';

import 'package:chat_app_diplom/repositories/encrtyption_service.dart';
import 'package:chat_app_diplom/constants.dart';
import 'package:chat_app_diplom/entity/last_message_model.dart';
import 'package:chat_app_diplom/entity/message_model.dart';
import 'package:chat_app_diplom/entity/message_reply_model.dart';
import 'package:chat_app_diplom/entity/user_model.dart';
import 'package:chat_app_diplom/enums/enums.dart';
import 'package:chat_app_diplom/repositories/chat_repository.dart';
import 'package:chat_app_diplom/repositories/shared_preferences_repository.dart';
import 'package:chat_app_diplom/utilities/global_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class ChatProvider extends ChangeNotifier {
  bool _isLoading = false;
  final ChatRepository _repository;
  final SharedPreferencesRepository _sharedPreferencesRepository;
  final EncryptionService _encryptionService;
  ChatProvider(this._repository, this._sharedPreferencesRepository, this._encryptionService);
  MessageReplyModel? messageReplyModel;


  bool get isLoading => _isLoading;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }


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
    required String chatId,
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
          chatId: chatId
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
    required String chatId,
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
      String fileUrl = await storeFileToStorage(file: file, reference: ref);
      String fileName  = file.path.split('/').last;
      String extension =  fileName .split('.').last;
      final encryptedMessage = await _encryptionService.encryptMessage(fileUrl, chatId, sender.uid, contactUID);
      // 3. update/set the messagemodel
      final messageModel = MessageModel(
        senderUID: sender.uid,
        senderName: sender.name,
        senderImage: sender.image,
        contactUID: contactUID,
        message: encryptedMessage,
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
        fileType: extension,
        fileName: fileName 
      );


        // handle contact message
        await handleContactMessage(
          messageModel: messageModel,
          contactUID: contactUID,
          contactName: contactName,
          contactImage: contactImage,
          onSucess: onSucess,
          onError: onError,
          chatId: chatId
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
    required String chatId,
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
        chatId: chatId
      );

      // 2. initialize last message for the contact
      final contactLastMessage = senderLastMessage.copyWith(
        contactUID: messageModel.senderUID,
        contactName: messageModel.senderName,
        contactImage: messageModel.senderImage,
      );

      await _repository.saveMessages(
        messageModel: messageModel,
        contactMessageModel: contactMessageModel,
        senderLastMessage: senderLastMessage,
        contactLastMessage: contactLastMessage,
        contactUID: contactUID
      );
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
  Stream<int> getUnreadMessagesCount({
    required String userId,
    required String contactUID,
  }) {
    return _repository.getUnreadMessagesCount(
      userId: userId,
      contactUID: contactUID,
    );
  }

  // set message status
  Future<void> setMessageStatus({
    required String currentUserId,
    required String contactUID,
    required String messageId,
  }) async {

      _repository.setMessageStatus(
        currentUserId: currentUserId,
        contactUID: contactUID,
        messageId: messageId,
      );
  }
  


  //get chatslist stream
  Stream<List<LastMessageModel>> getChatsListStream(String userId) {
    return _repository.getChatsListStream(userId);
  }


    // stream messages from chat collection
  Stream<List<MessageModel>> getMessagesStream({
    required String userId,
    required String contactUID,
  }) {
      // handle contact message
      return _repository.getMessagesStream(
        userId: userId,
        contactUID: contactUID,
      );
    }

  String? getCommonKey(String contactUID) {
    return _sharedPreferencesRepository.getCommonKey(contactUID);
  }

  String? getChatId(String contactUID) {
    return _sharedPreferencesRepository.getChatId(contactUID);
  }

  Future<String> encryptMessage(String text, String chatId, String uid, String contactUID){
    return _encryptionService.encryptMessage(text, chatId, uid, contactUID);
  }

  Future<String> decryptMessage(String encryptedData,  String contactUID, String chatId,String uid) async {
    return _encryptionService.decryptMessage(encryptedData, contactUID, chatId, uid);
  }
}






  