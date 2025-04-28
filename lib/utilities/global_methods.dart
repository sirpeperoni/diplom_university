// show snackbar
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app_diplom/enums/enums.dart';
import 'package:chat_app_diplom/utilities/assets_manager.dart';
import 'package:date_format/date_format.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

void showSnackBar(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(text),
    ),
  );
}

Widget userImageWidget(
  {
    required String imageUrl,
    required double radius,
    required Function() onTap
  }
){
  return GestureDetector(
    onTap: onTap,
    child: CircleAvatar(
      backgroundColor: Colors.grey[300],
      radius: radius,
      backgroundImage: imageUrl.isNotEmpty
        ? CachedNetworkImageProvider(imageUrl)
        : const  AssetImage(AssetsManager.userImage) as ImageProvider,
    ),
  );
  
}

// store file to storage and return file url
Future<String> storeFileToStorage({
  required File file,
  required String reference,
}) async {
  UploadTask uploadTask =
      FirebaseStorage.instance.ref().child(reference).putFile(file);
  
  TaskSnapshot taskSnapshot = await uploadTask;
  String fileUrl = await taskSnapshot.ref.getDownloadURL();
  FullMetadata metadata = await taskSnapshot.ref.getMetadata();
  String? extension = metadata.contentType;
  return fileUrl;
}

Widget messageToShow({required MessageEnum? type, required String message}) {
  switch (type) {
    case MessageEnum.text:
      return Text(
        message,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    case MessageEnum.image:
      return const Row(
        children: [
          Icon(Icons.image_outlined),
          SizedBox(width: 10),
          Text(
            'Изображение',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    case MessageEnum.video:
      return const Row(
        children: [
          Icon(Icons.video_library_outlined),
          SizedBox(width: 10),
          Text(
            'Видео',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    case MessageEnum.audio:
      return const Row(
        children: [
          Icon(Icons.audiotrack_outlined),
          SizedBox(width: 10),
          Text(
            'Аудио',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    case MessageEnum.file:
    return const Row(
        children: [
          Icon(Icons.file_present_outlined),
          SizedBox(width: 10),
          Text(
            'Файл',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    default:
      return Text(
        message,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
  }
}


// pick image from gallery or camera
Future<File?> pickImage({
  required bool fromCamera, 
  required Function(String) onFail
}) async {
  File? fileImage;
  if(fromCamera) {
    try {
      final pickedImage = await ImagePicker().pickImage(source: ImageSource.camera);
      if(pickedImage != null) {
        fileImage = File(pickedImage.path);
      } else{
        onFail('Не выбрана картинка');
      }
    } catch(e) {
      onFail(e.toString());
    }
  } else {
    try {
      final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
      if(pickedImage != null) {
        fileImage = File(pickedImage.path);
      } else {
        onFail('Не выбрана картинка');
      }
    } catch(e) {
      onFail(e.toString());
    }
  }

  return fileImage;
}

// pick video from gallery
Future<File?> pickVideo({
  required Function(String) onFail,
}) async {
  File? fileVideo;
  try {
    final pickedFile =
        await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (pickedFile == null) {
      onFail('Не выбрано видео');
    } else {
      fileVideo = File(pickedFile.path);
    }
  } catch (e) {
    onFail(e.toString());
  }

  return fileVideo;
}

//pick file from device
Future<File?> pickFile({
  required Function(String) onFail,
}) async {
  File? file;
  try {
    final pickedFile = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );
    if (pickedFile == null) {
      onFail('Не выбран файл');
    } else {
      file = File(pickedFile.files.single.path!);
      // ignore: avoid_print
      print(file);
    }
  } catch (e) {
    onFail(e.toString());
  }
  return file;
}



void showMyAnimatedDialog({
  required BuildContext context,
  required String title,
  required String content,
  required String textAction,
  required Function(bool) onActionTap,
}) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: '',
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (context, animation1, animation2) {
      return Container();
    },
    transitionBuilder: (context, animation1, animation2, child) {
      return ScaleTransition(
          scale: Tween<double>(begin: 0.5, end: 1.0).animate(animation1),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.5, end: 1.0).animate(animation1),
            child: AlertDialog(
              title: Text(
                title,
              ),
              content: Text(
                content,
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onActionTap(false);
                      },
                      child: const Text('Отмена'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onActionTap(true);
                      },
                      child: Text(textAction),
                    ),
                  ],
                ),
              ],
            ),
          ));
    },
  );
}

Container buildDateTime(groupedByValue) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        formatDate(groupedByValue.timeSent, [dd, ' ', M, ', ', yyyy]),
        textAlign: TextAlign.center,
        style: GoogleFonts.openSans(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }


