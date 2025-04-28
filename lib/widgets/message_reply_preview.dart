import 'package:chat_app_diplom/providers/auth_provider.dart';
import 'package:chat_app_diplom/providers/chat_provider.dart';
import 'package:chat_app_diplom/utilities/global_methods.dart';
import 'package:chat_app_diplom/widgets/blank_message_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class MessageReplyPreview extends StatelessWidget {
  const MessageReplyPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        final messageReply = chatProvider.messageReplyModel;
        final type = messageReply?.messageType;
        final uid = context.read<AuthenticationProvider>().uid!;
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.2),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(messageReply!.senderName, style: GoogleFonts.openSans(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),),
                    FutureBuilder(
                      future: context.read<ChatProvider>().decryptMessage(messageReply.message, messageReply.contactId, messageReply.chatId, uid),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const BlankMessageWidget();
                        }
                        return messageToShow(type: type, message: snapshot.data ?? '');
                      }
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: (){
                  chatProvider.setMessageReplyModel(null);
                }, 
                icon: const Icon(Icons.close)
              ),
            ],
          ),
        );
      }
    );
  }
}