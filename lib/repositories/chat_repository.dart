import 'package:chat_app_diplom/constants.dart';
import 'package:chat_app_diplom/entity/last_message_model.dart';
import 'package:chat_app_diplom/entity/message_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRepository {
  final FirebaseFirestore _firestore;

  ChatRepository(this._firestore);

  Future<void> saveMessages({
    required MessageModel messageModel,
    required MessageModel contactMessageModel,
    required LastMessageModel senderLastMessage,
    required LastMessageModel contactLastMessage,
    required String contactUID,
  }) async {
    
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
  }

  Stream<int> getUnreadMessagesCount({
    required String userId,
    required String contactUID,
  }) {
    return _firestore
        .collection(Constants.users)
        .doc(userId)
        .collection(Constants.chats)
        .doc(contactUID)
        .collection(Constants.messages)
        .where(Constants.isSeen, isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .where((doc) => doc.data()[Constants.senderUID] != userId)
            .length);
  }
  
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