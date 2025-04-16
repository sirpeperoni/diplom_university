import 'package:chat_app_diplom/constants.dart';
import 'package:chat_app_diplom/entity/last_message_model.dart';
import 'package:chat_app_diplom/providers/auth_provider.dart';
import 'package:chat_app_diplom/utilities/global_methods.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SerchChatsPage extends StatefulWidget {
  const SerchChatsPage({super.key});

  @override
  State<SerchChatsPage> createState() => _SerchChatsPageState();
}

class _SerchChatsPageState extends State<SerchChatsPage> {
  @override
  Widget build(BuildContext context) {
    final uid = context.watch<AuthenticationProvider>().userModel!.uid;
    final model = context.watch<AuthenticationProvider>();
    return  Scaffold(
      appBar: AppBar(
        title: const Text('Поиск'),
      ),
      body: Padding(
        padding:const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CupertinoSearchTextField(
              placeholder: 'Поиск',
              style: const TextStyle(
                color: Colors.black,
              ),
              onChanged: (value) {
                model.getStreamChats(value, uid);
              },
            ),
            Expanded(
              child: model.streamChats == null ? const Center(
                child: Text(
                  'Нет результатов',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                  ),
                ),
              ) : StreamBuilder<List<LastMessageModel>>(
                stream: model.streamChats, 
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text('Something went wrong'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if(snapshot.hasData){
                    final users = snapshot.data!;
                    return ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, Constants.chatScreen, arguments: {
                                  Constants.contactUID: user.contactUID,
                                  Constants.contactName: user.contactName,
                                  Constants.contactImage: user.contactImage,
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                userImageWidget(imageUrl: user.contactImage, radius: 24, onTap: () {}),
                                const SizedBox(width: 16,),
                                Column(
                                  children: [
                                    Text(user.contactName),
                                    messageToShow(type: user.messageType, message: user.message),
                                  ],
                                ),
                              ],
                            ),
                          ),
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