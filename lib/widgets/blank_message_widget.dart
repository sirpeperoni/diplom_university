import 'package:chat_app_diplom/auth/encrtyption_service.dart';
import 'package:chat_app_diplom/entity/message_model.dart';
import 'package:chat_app_diplom/enums/enums.dart';
import 'package:chat_app_diplom/widgets/display_message_type.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:swipe_to/swipe_to.dart';

class BlankMessageWidget extends StatelessWidget {
  const BlankMessageWidget({super.key});



  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
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
                  const Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
      
                            DisplayMessageType(
                              type: MessageEnum.text,
                              fileName: "",
                              message: "",
                              overFlow: TextOverflow.ellipsis,
                              viewOnly: false,
                              color: Colors.white,
                              isReply: false,
                              extension: "",
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
                          "12:00",
                          style: GoogleFonts.openSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1.2,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 5,),
                        Icon(
                          false ? Icons.done_all : Icons.done,
                          color: false ? Colors.blue[600] : Colors.grey[600],
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