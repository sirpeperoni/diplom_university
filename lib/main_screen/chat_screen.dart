import 'package:chat_app_diplom/auth/encrtyption_service.dart';
import 'package:chat_app_diplom/auth/landing_screen.dart';
import 'package:chat_app_diplom/constants.dart';
import 'package:chat_app_diplom/providers/auth_provider.dart';
import 'package:chat_app_diplom/providers/chat_provider.dart';
import 'package:chat_app_diplom/widgets/bottom_chat_field.dart';
import 'package:chat_app_diplom/widgets/chat_app_bar.dart';
import 'package:chat_app_diplom/widgets/chat_list.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    final commonKey = arguments[Constants.commonKey];
    return Scaffold(
      appBar: AppBar(
        title: ChatAppBar(contactId: contactUID),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ChatList(contactUID: contactUID),
            ),
          ),
          BottomChatField(contactUID: contactUID, contactName: contactName, contactImage: contactImage, chatId: chatId!)
        ],
      )
    );
  }
}