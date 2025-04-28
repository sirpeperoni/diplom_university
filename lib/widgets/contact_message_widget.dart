import 'package:chat_app_diplom/entity/message_model.dart';
import 'package:chat_app_diplom/widgets/display_message_type.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:swipe_to/swipe_to.dart';

class ContactMessageWidget extends StatelessWidget {
  const ContactMessageWidget({super.key, required this.message, required this.onLeftSwipe, required this.decryptedMessage});
  final Function() onLeftSwipe;
  final MessageModel message;
  final String decryptedMessage;


  @override
  Widget build(BuildContext context) {
    final time = formatDate(message.timeSent, [hh, ':', nn, ' ']);
    final isReplying = message.repliedTo.isNotEmpty;
    //final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return SwipeTo(
      onLeftSwipe: (details) {
        onLeftSwipe();
      },
      child: Align(
        alignment: Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
            minWidth: MediaQuery.of(context).size.width * 0.3,
          ),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              children: [
                Padding(
                      padding: const EdgeInsets.only(left: 10, right: 30, top: 5, bottom: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if(isReplying) ...[
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.grey[400],
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
                                              style: GoogleFonts.openSans(
                                                fontSize: 13,
                                                color:  Colors.black,
                                                fontWeight: FontWeight.bold,
                                              ),
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
                            ),

                        ],
                      ),
                ),
                Positioned(
                  bottom: 4,
                  left: 11,
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