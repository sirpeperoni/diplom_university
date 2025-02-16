
import 'package:chat_app_diplom/entity/last_message_model.dart';
import 'package:chat_app_diplom/providers/auth_provider.dart';
import 'package:chat_app_diplom/utilities/global_methods.dart';
import 'package:chat_app_diplom/widgets/unread_message_counter.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatWidget extends StatelessWidget {
  const ChatWidget({
    super.key,
    this.chat,
    required this.onTap,
  });

  final LastMessageModel? chat;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthenticationProvider>().userModel!.uid;
    // get the last message
    final lastMessage = chat!.message;
    // get the senderUID
    final senderUID = chat!.senderUID;

    // get the date and time
    final timeSent = chat!.timeSent;
    final dateTime= formatDate(timeSent, [ HH, ':', nn]);

    // get the image url
    final imageUrl = chat!.contactImage;

    // get the name
    final name = chat!.contactName;

    // get the contactUID
    final contactUID = chat!.contactUID;
    // get the messageType
    final messageType = chat!.messageType;
    return ListTile(
      leading: userImageWidget(
        imageUrl: imageUrl,
        radius: 40,
        onTap: () {},
      ),
      contentPadding: EdgeInsets.zero,
      title: Text(name),
      subtitle: Row(
        children: [
          uid == senderUID
              ? const Text(
                  'Вы:',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                )
              : const SizedBox(),
          const SizedBox(width: 5),
          messageToShow(
            type: messageType,
            message: lastMessage,
          ),
        ],
      ),
      trailing: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(dateTime),
            UnreadMessageCounter(
              uid: uid,
              contactUID: contactUID,
            )
          ],
        ),
      ),
      onTap: onTap,
    );
  }
}