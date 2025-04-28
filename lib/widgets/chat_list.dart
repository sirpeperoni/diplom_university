import 'package:chat_app_diplom/entity/message_model.dart';
import 'package:chat_app_diplom/entity/message_reply_model.dart';
import 'package:chat_app_diplom/providers/auth_provider.dart';
import 'package:chat_app_diplom/providers/chat_provider.dart';
import 'package:chat_app_diplom/utilities/global_methods.dart';
import 'package:chat_app_diplom/widgets/blank_message_widget.dart';
import 'package:chat_app_diplom/widgets/contact_message_widget.dart';
import 'package:chat_app_diplom/widgets/my_message_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:provider/provider.dart';

class ChatList extends StatefulWidget {
  const ChatList({super.key, required this.contactUID, required this.chatId});
  final String contactUID;
  final String chatId;
  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  //scroll controller
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthenticationProvider>().userModel!.uid; 
    return GestureDetector(
      onVerticalDragDown: (_){
        //FocusScope.of(context).unfocus();
      },
      child: StreamBuilder<List<MessageModel>>(
        stream: context.read<ChatProvider>().getMessagesStream(userId: uid, contactUID: widget.contactUID),
        builder: (context, snapshot){
          if (snapshot.hasError) {
            return const Center(
              child: Text('Something went wrong'),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'Начать разговор',
                textAlign: TextAlign.center,
                style: GoogleFonts.openSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2),
              ),
            );
          }
          //automatically scroll to the bottom on new message
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollController.animateTo(
              _scrollController.position.minScrollExtent,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
            );
          });
          if(snapshot.hasData){
            final messages = snapshot.data!;
            return GroupedListView<dynamic, DateTime>(
              elements: messages, 
              controller: _scrollController,
              groupBy: (element){
                return DateTime(
                  element.timeSent.year,
                  element.timeSent.month,
                  element.timeSent.day
                );
              },
              groupHeaderBuilder: (groupedByValue) =>
                buildDateTime(groupedByValue)
              ,
              itemBuilder: (context, element) {
                 final messageFull = element;
                  if (!messageFull.isSeen && messageFull.senderUID != uid) {
                    context.read<ChatProvider>().setMessageStatus(
                          currentUserId: uid,
                          contactUID: widget.contactUID,
                          messageId: messageFull.messageId,
                        );
                  }
                final isMe = element.senderUID == uid;
                final senderUID = element.senderUID;
                final msg = element.message;
                final senderName = element.senderName;
                final senderImage = element.senderImage;
                final messageType = element.messageType;
                return isMe ? FutureBuilder(
                  future: context.read<ChatProvider>().decryptMessage(msg, widget.contactUID, widget.chatId, uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const BlankMessageWidget();
                    }
                    return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: MyMessageWidget(
                            message: element,
                            decryptedMessage: snapshot.data ?? '',
                            onLeftSwipe: (){
                              final messageReply = MessageReplyModel(
                                senderUID: senderUID,
                                message: msg,
                                senderName: senderName,
                                senderImage: senderImage,
                                messageType: messageType,
                                isMe: isMe,
                                contactId: widget.contactUID,
                                chatId: widget.chatId,
                                
                              );
                              context.read<ChatProvider>().setMessageReplyModel(messageReply);
                      }
                    ) );
                  }
                ) : FutureBuilder(
                  future: context.read<ChatProvider>().decryptMessage(msg, widget.contactUID, widget.chatId, uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const BlankMessageWidget();
                    }
                    return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ContactMessageWidget(
                            message: element,
                            decryptedMessage: snapshot.data ?? '',
                            onLeftSwipe: (){
                              final messageReply = MessageReplyModel(
                                senderUID: senderUID,
                                message: msg,
                                senderName: senderName,
                                senderImage: senderImage,
                                messageType: messageType,
                                isMe: isMe,
                                contactId: widget.contactUID,
                                chatId: widget.chatId,
                              );
                              context.read<ChatProvider>().setMessageReplyModel(messageReply);
                            }
                          ),
                    );
                  }
                );
              },
              groupComparator: (value1, value2) =>
                value2.compareTo(value1),
              floatingHeader: true,
              itemComparator: (item1, item2) {
                var firstItem = item1.timeSent;
                var secondItem = item2.timeSent;
                return secondItem.compareTo(firstItem);
              },
              reverse: true,
              order: GroupedListOrder.ASC,
            );
          }
          return const SizedBox.shrink();
        }),
    );
  }

  
}