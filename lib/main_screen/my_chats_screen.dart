import 'package:chat_app_diplom/constants.dart';
import 'package:chat_app_diplom/entity/last_message_model.dart';
import 'package:chat_app_diplom/providers/auth_provider.dart';
import 'package:chat_app_diplom/providers/chat_provider.dart';
import 'package:chat_app_diplom/utilities/global_methods.dart';
import 'package:chat_app_diplom/widgets/chat_widget.dart';
import 'package:chat_app_diplom/widgets/unread_message_counter.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyChatsScreen extends StatefulWidget {
  const MyChatsScreen({super.key});

  @override
  State<MyChatsScreen> createState() => _MyChatsScreenState();
}

class _MyChatsScreenState extends State<MyChatsScreen> {
  @override
  Widget build(BuildContext context) {
    final uid = context.watch<AuthenticationProvider>().userModel!.uid;
    return  Scaffold(
      body: Padding(
        padding:const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CupertinoSearchTextField(
              placeholder: 'Поиск',
              style: const TextStyle(
                color: Colors.white,
              ),
              onChanged: (value) => print(value),
              onTap: () {
                Navigator.pushNamed(context, Constants.searchChats);
              },
            ),
            Expanded(
              child: StreamBuilder<List<LastMessageModel>>(
                stream: context.read<ChatProvider>().getChatsListStream(uid), 
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text('Something went wrong'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if(snapshot.hasData){
                    final chats = snapshot.data!;
                    return ListView.builder(
                      itemCount: chats.length,
                      itemBuilder: (context, index) {
                        final chat = chats[index];
                        return ChatWidget(
                          chat: chat,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              Constants.chatScreen,
                              arguments: {
                                Constants.contactUID: chat.contactUID,
                                Constants.contactName: chat.contactName,
                                Constants.contactImage: chat.contactImage,
                              },
                            );
                          },
                        );
                      }
                    );
                  }
                  return const Center(child: Text('Нет чатов'));
                }
              )
            )
          ],
        )
      ),
    );
  }
}