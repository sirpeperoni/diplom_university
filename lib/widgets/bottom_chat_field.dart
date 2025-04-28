import 'dart:io';

import 'package:chat_app_diplom/enums/enums.dart';
import 'package:chat_app_diplom/providers/auth_provider.dart';
import 'package:chat_app_diplom/providers/chat_provider.dart';
import 'package:chat_app_diplom/utilities/global_methods.dart';
import 'package:chat_app_diplom/widgets/message_reply_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound_record/flutter_sound_record.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class BottomChatField extends StatefulWidget {
  final String contactUID;
  
  final String contactName;
  
  final String contactImage;

  final String chatId;

  const BottomChatField({super.key, required this.contactUID, required this.contactName, required this.contactImage, required this.chatId});

  @override
  State<BottomChatField> createState() => _BottomChatFieldState();
}

class _BottomChatFieldState extends State<BottomChatField> {

  late final TextEditingController _textEditingController;
  FlutterSoundRecord? _soundRecord;
  late final FocusNode _focusNode;
  File? finalFileImage;


  String filePath = '';
  bool isRecording = false;
  bool isShowSendButton = false;
  bool isSendingAudio = false;

  @override
  void initState() {
    _textEditingController = TextEditingController();
    _soundRecord = FlutterSoundRecord();
    _focusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _soundRecord?.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // check microphone permission
  Future<bool> checkMicrophonePermission() async {
    bool hasPermission = await Permission.microphone.isGranted;
    final status = await Permission.microphone.request();
    if (status == PermissionStatus.granted) {
      hasPermission = true;
    } else {
      hasPermission = false;
    }

    return hasPermission;
  }

  // start recording audio
  void startRecording() async {
    setState(() {
      isShowSendButton = true;
    });
    final hasPermission = await checkMicrophonePermission();
    if (hasPermission) {
      var tempDir = await getTemporaryDirectory();
      filePath = '${tempDir.path}/flutter_sound.aac';
      await _soundRecord!.start(
        path: filePath,
      );
      setState(() {
        isRecording = true;
      });
    }
  }

  // stop recording audio
  void stopRecording() async {
    await _soundRecord!.stop();
    setState(() {
      isRecording = false;
      isSendingAudio = true;
    });
    // send audio message to firestore
    sendFileMessage(
      messageType: MessageEnum.audio,
    );
    setState(() {
      isShowSendButton = false;
    });
  }

  void selectImage(bool fromCamera) async {
    finalFileImage = await pickImage(
      fromCamera: fromCamera,
      onFail: (String message) {
        showSnackBar(context, message);
      },
    );

    // crop image
    await cropImage(finalFileImage?.path);

    popContext();
  }

  // select a video file from device
  void selectVideo() async {
    File? fileVideo = await pickVideo(
      onFail: (String message) {
        showSnackBar(context, message);
      },
    );

    popContext();

    if (fileVideo != null) {
      filePath = fileVideo.path;
      // send video message to firestore
      sendFileMessage(
        messageType: MessageEnum.video,
      );
    }
  }

  //select file from device
  void selectFile() async {
    File? file = await pickFile(
      onFail: (String message) {
        showSnackBar(context, message);
      },
    );
    popContext();
    if (file != null) {
      filePath = file.path;
      // send file message to firestore
      sendFileMessage(
        messageType: MessageEnum.file,
      );
    }
  }

  popContext() {
    Navigator.pop(context);
  }

  Future<void> cropImage(croppedFilePath) async {
    if (croppedFilePath != null) {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: croppedFilePath,
        maxHeight: 800,
        maxWidth: 800,
        compressQuality: 90,
      );

      if (croppedFile != null) {
        filePath = croppedFile.path;
        // send image message to firestore
        sendFileMessage(
          messageType: MessageEnum.image,
        );
      }
    }
  }

  // send image message to firestore
  void sendFileMessage({
    required MessageEnum messageType,
  }) async {
    final currentUser = context.read<AuthenticationProvider>().userModel!;
    final chatProvider = context.read<ChatProvider>();

    chatProvider.sendFileMessage(
      sender: currentUser,
      contactUID: widget.contactUID,
      contactName: widget.contactName,
      contactImage: widget.contactImage,
      file: File(filePath),
      messageType: messageType,
      chatId: widget.chatId,
      onSucess: () {
        _textEditingController.clear();
        _focusNode.unfocus();
        setState(() {
          isSendingAudio = false;
        });
      },
      onError: (error) {
        setState(() {
          isSendingAudio = false;
        });
        showSnackBar(context, error);
      },
    );
  }

  //send text message to firestore
  void sendTextMessage() async {
    final currentUser = context.read<AuthenticationProvider>().userModel!;
    final chatProvider = context.read<ChatProvider>();
    final text = _textEditingController.text;
    final encryptedMessage = await context.read<ChatProvider>().encryptMessage(text, widget.chatId, currentUser.uid, widget.contactUID);
    _textEditingController.clear();
    chatProvider.sendTextMessage(
      sender: currentUser, 
      contactUID: widget.contactUID, 
      contactName: widget.contactName, 
      contactImage: widget.contactImage, 
      message: encryptedMessage, 
      chatId: widget.chatId,
      messageType: MessageEnum.text, 
      onSucess: (){
        _focusNode.requestFocus();
      }, 
      onError: (error){
        _textEditingController.text = text;
        showSnackBar(context, error);  
      }
    );
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        final messageReply = chatProvider.messageReplyModel;
        final isMessageReply = messageReply != null;
        return Column(
          children: [
            isMessageReply ? const MessageReplyPreview()
              : const SizedBox.shrink(),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                ),
                child: Row(
                  children: [
                    IconButton(onPressed: isSendingAudio ? null : (){
                      showModalBottomSheet(
                        context: context, 
                        builder: (context){
                          return SizedBox(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // select image from camera
                                  ListTile(
                                    leading:
                                        const Icon(Icons.camera_alt),
                                    title: const Text('Камера'),
                                    onTap: () {
                                      selectImage(true);
                                    },
                                  ),
                                  // select image from gallery
                                  ListTile(
                                    leading: const Icon(Icons.image),
                                    title: const Text('Галлерея'),
                                    onTap: () {
                                      selectImage(false);
                                    },
                                  ),
                                  // select a video file from device
                                  ListTile(
                                    leading: const Icon(
                                        Icons.video_library),
                                    title: const Text('Видео'),
                                    onTap: selectVideo,
                                  ),
                                  ListTile(
                                    leading: const Icon(
                                        Icons.file_copy),
                                    title: const Text('Файл'),
                                    onTap: selectFile,
                                  ),
                                ],
                              ),
                            ),
                        );
                        });
                    }, icon: const Icon(Icons.attachment)),
                    Expanded(
                      child: TextFormField(
                        controller: _textEditingController,
                        focusNode: _focusNode,
                        decoration: const InputDecoration.collapsed(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                            borderSide: BorderSide.none,
                          ),
                          hintText: 'Сообщение',
                        ),
                      ),
                    ),
                    chatProvider.isLoading
                          ? const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(),
                            )
                          :
                    GestureDetector(
                      onTap: sendTextMessage,
                      onLongPress:
                                  isShowSendButton ? null : startRecording,
                      onLongPressUp: stopRecording,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        margin: const EdgeInsets.all(5),
                        child: isShowSendButton ? const Icon(Icons.mic) : const Icon(Icons.send),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}