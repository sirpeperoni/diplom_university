import 'package:chat_app_diplom/entity/message_model.dart';
import 'package:chat_app_diplom/widgets/display_message_type.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:swipe_to/swipe_to.dart';

class MyMessageWidget extends StatelessWidget {
  const MyMessageWidget({super.key, required this.message, required this.onLeftSwipe, required this.decryptedMessage});
  final MessageModel message;

  final String decryptedMessage;
  final Function() onLeftSwipe;
  @override
  Widget build(BuildContext context) {
    final time = formatDate(message.timeSent, [hh, ':', nn, ' ']);
    final isReplying = message.repliedTo.isNotEmpty;
    return SwipeTo(
      onLeftSwipe: (details) {
        onLeftSwipe();
      },
      child: Align(
        alignment: Alignment.centerRight,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
            minWidth: MediaQuery.of(context).size.width * 0.3,
          ),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              children: [
                Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if(isReplying) ...[
                            Container(
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
                                        Text(message.senderName, style: GoogleFonts.openSans(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),),
                                        Text(
                                              message.repliedMessage,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                          DisplayMessageType(
                            type: message.messageType,
                            fileName: message.fileName,
                            message: decryptedMessage,
                            overFlow: TextOverflow.ellipsis,
                            viewOnly: false,
                            color: Colors.white,
                            isReply: false,
                            extension: message.fileType,
                          )
                        ],
                      ),
                ),
                Positioned(
                  bottom: 4,
                  right: 10,
                  child: Row(
                    children: [
                      Text(
                        time,
                        style: GoogleFonts.openSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.2,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 5,),
                      Icon(
                        message.isSeen ? Icons.done_all : Icons.done,
                        color: message.isSeen ? Colors.blue[600] : Colors.grey[600],
                        size: 15,           
                      )
                    ],
                  ),
                ),
              ],
            ),
          )
        ),
        
      ),
    );
  }
}