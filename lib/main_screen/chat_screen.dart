import 'package:chat_app_diplom/constants.dart';
import 'package:chat_app_diplom/widgets/bottom_chat_field.dart';
import 'package:chat_app_diplom/widgets/chat_app_bar.dart';
import 'package:chat_app_diplom/widgets/chat_list.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
    final contactUID = arguments[Constants.contactUID];
    final contactName = arguments[Constants.contactName];
    final contactImage = arguments[Constants.contactImage];
    final chatId = arguments[Constants.chatId];
    return Scaffold(
      appBar: AppBar(
        title: ChatAppBar(contactId: contactUID),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ChatList(contactUID: contactUID, chatId: chatId ?? ''),
            ),
          ),
          BottomChatField(contactUID: contactUID, contactName: contactName, contactImage: contactImage, chatId: chatId!)
        ],
      )
    );
  }
}