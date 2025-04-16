import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app_diplom/constants.dart';
import 'package:chat_app_diplom/enums/enums.dart';
import 'package:chat_app_diplom/widgets/audio_player_widget.dart';
import 'package:chat_app_diplom/widgets/video_player_widget.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';


class DisplayMessageType extends StatefulWidget {
  const DisplayMessageType({
    super.key,
    required this.message,
    required this.type,
    required this.color,
    required this.isReply,
    this.maxLines,
    this.overFlow,
    required this.viewOnly,
    this.extension = '',
  });

  final String message;
  final MessageEnum type;
  final Color color;
  final bool isReply;
  final int? maxLines;
  final TextOverflow? overFlow;
  final bool viewOnly;
  final String? extension;

  @override
  State<DisplayMessageType> createState() => _DisplayMessageTypeState();
}

class _DisplayMessageTypeState extends State<DisplayMessageType> {
  @override
  Widget build(BuildContext context) {
    var progress = 0.0;
    bool isLoading = false;
    Widget messageToShow() {
      switch (widget.type) {
        case MessageEnum.text:
          return Text(
            widget.message,
            style: GoogleFonts.openSans(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.2,
              color: Colors.black,
            ),
          );
        case MessageEnum.image:
          return widget.isReply
              ? const Icon(Icons.image)
              : InkWell(
                onTap: () {
                  Navigator.pushNamed(context, Constants.imageScreen, arguments: {
                    Constants.imageLink: widget.message,
                  });
                },
                child: CachedNetworkImage(
                    width: 200,
                    height: 200,
                    imageUrl: widget.message,
                    fit: BoxFit.cover,
                  ),
              );
        case MessageEnum.video:
          return widget.isReply
              ? const Icon(Icons.video_collection)
              : VideoPlayerWidget(
                  videoUrl: widget.message,
                  color: widget.color,
                  viewOnly: widget.viewOnly,
                );
        case MessageEnum.audio:
          return widget.isReply
              ? const Icon(Icons.audiotrack)
              : AudioPlayerWidget(
                  audioUrl: widget.message,
                  color: widget.color,
                  viewOnly: widget.viewOnly,
                );
        case MessageEnum.file:
          return widget.isReply
          ? const Icon(Icons.file_copy)
          : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.extension == null ? "1" : widget.extension!,
                style: GoogleFonts.openSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.2,
                  color: Colors.black,
                ),
                maxLines: widget.maxLines,
                overflow: widget.overFlow,
              ),
              InkWell(
                onTap: () async {
                  final dio = Dio();
                  final downloadDirectory = await getDownloadsDirectory();
                  var filePath = '${downloadDirectory?.path}' '/${widget.message}';
                  setState(() {
                    isLoading = true;
                  });
                  String? ext = widget.extension;
                  if(ext != ''){     
                    filePath = '$filePath.${ext!.substring(ext.indexOf('/') + 1)}';
                  }
                  dio.download(widget.message, filePath, onReceiveProgress: (rcv, total) {
                    // if (total != -1) {
                    //   print(
                    //       'received: ${rcv.toStringAsFixed(0)} out of total: ${total.toStringAsFixed(0)}');
                    // }
                    setState(() {
                      progress = ((rcv / total) * 100);
                    });
                  },);
                  setState(() {
                    isLoading = false;
                  });
                  // Handle the response as needed
                  // For example, you can show a snackbar with the download progress
                },
                child: isLoading ? CircularProgressIndicator(
                  value: progress / 100,
                  color: widget.color,
                ) : const Icon(
                  Icons.file_copy, size: 30,
                )
              ),
            ],
          );
        default:
          return Text(
            widget.message,
            style: GoogleFonts.openSans(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.2,
              color: Colors.black,
            ),
          );
      }
    }

    return messageToShow();
  }
}