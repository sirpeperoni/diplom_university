
import 'package:chat_app_diplom/constants.dart';
import 'package:chat_app_diplom/enums/enums.dart';

class MessageReplyModel {
  final String message;
  final String senderUID;
  final String senderName;
  final String senderImage;
  final String chatId;
  final String contactId;
  final MessageEnum messageType;
  final bool isMe;

  MessageReplyModel({
    required this.message,
    required this.senderUID,
    required this.senderName,
    required this.senderImage,
    required this.messageType,
    required this.isMe,
    required this.chatId,
    required this.contactId,
  });

  // to map
  Map<String, dynamic> toMap() {
    return {
      Constants.message: message,
      Constants.senderUID: senderUID,
      Constants.senderName: senderName,
      Constants.senderImage: senderImage,
      Constants.messageType: messageType.name,
      Constants.isMe: isMe,
      Constants.chatId: chatId,
      Constants.contactUID: contactId,
    };
  }

  // from map
  factory MessageReplyModel.fromMap(Map<String, dynamic> map) {
    return MessageReplyModel(
      message: map[Constants.message] ?? '',
      senderUID: map[Constants.senderUID] ?? '',
      senderName: map[Constants.senderName] ?? '',
      senderImage: map[Constants.senderImage] ?? '',
      messageType: map[Constants.messageType].toString().toMessageEnum(),
      isMe: map[Constants.isMe] ?? false,
      chatId: map[Constants.chatId] ?? '',
      contactId: map[Constants.contactUID] ?? '',
    );
  }
}