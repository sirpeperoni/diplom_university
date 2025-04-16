import 'dart:io';

import 'package:chat_app_diplom/constants.dart';
import 'package:chat_app_diplom/entity/user_model.dart';
import 'package:chat_app_diplom/providers/auth_provider.dart';
import 'package:chat_app_diplom/utilities/global_methods.dart';
import 'package:chat_app_diplom/widgets/app_bar_back_buttons.dart';
import 'package:chat_app_diplom/widgets/display_user_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';

class UserInformationScreen extends StatefulWidget {
  const UserInformationScreen({super.key});

  @override
  State<UserInformationScreen> createState() => _UserInformationScreenState();
}

class _UserInformationScreenState extends State<UserInformationScreen> {
  final RoundedLoadingButtonController _btnCodeController = RoundedLoadingButtonController();
  final TextEditingController _nameController = TextEditingController();
  File? finalFileImage;
  String userImage = '';
  @override
  void dispose() {
    _nameController.dispose();
    _btnCodeController.stop();
    super.dispose();
  }

  void selectImage(bool fromCamera) async {
    finalFileImage = await pickImage(fromCamera: fromCamera, onFail: (String message){
      showSnackBar(context, message);
    });
    cropImage(finalFileImage?.path);

    popContext();
  }

  popContext(){
    Navigator.pop(context);
  }

  Future<void> cropImage(filePath) async {
    if(filePath != null) {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: filePath,
        compressQuality: 90,
        maxWidth: 800,
        maxHeight: 800,
      );

      if(croppedFile != null) {
        setState(() {
          finalFileImage = File(croppedFile.path);
        });
      }
    }
  }



  void showBottomSheet(){
    showModalBottomSheet(context: context, builder: (context) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Камера'),
            onTap: () {
              selectImage(true);
            },
          ),
          ListTile(
            leading: const Icon(Icons.image),
            title: const Text('Галерея'),
            onTap: () {
              selectImage(false);
            },
          ),
        ]);
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Добавьте информацию о себе', style: GoogleFonts.openSans(fontSize: 18, fontWeight: FontWeight.w500),),
        leading: AppBarBackButton(
          onPressed: () {
            Navigator.pop(context);
          },
        )
      ),
      body:  Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              DisplayUserImage(finalFileImage: finalFileImage, radius: 60, onPressed: (){showBottomSheet();}),
              const SizedBox(height: 30,),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Имя',
                  hintText: 'Имя',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(height: 30,),
              SizedBox(
                width: double.infinity,
                child: RoundedLoadingButton(
                  controller: _btnCodeController,
                  onPressed: () async {
                    if(_nameController.text.length < 3){
                      showSnackBar(context, 'Имя должно быть больше 3 символов');
                      _btnCodeController.reset();
                      return;
                    }
                    if(_nameController.text.isNotEmpty && finalFileImage != null) {
                      saveUserDataToFireStore();
                    } else {
                      showSnackBar(context, 'Заполните все поля');
                      _btnCodeController.reset();
                      return;
                    }
                  },
                  successIcon: Icons.check,
                  successColor: Colors.green,
                  errorColor: Colors.red,
                  color: Theme.of(context).primaryColor,
                  child: const Text(
                    'Продолжить',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500
                    )
                  ),
                ),
              )
            ]
          ),
        ),
      ),
    );
  }
  
  //save user data to firestore
  void saveUserDataToFireStore() async {
    final model = context.read<AuthenticationProvider>();

    UserModel userModel = UserModel(
      uid: model.uid!,
      name: _nameController.text.trim(),
      email: model.email!,
      image: '',
      token: '',
      aboutMe: 'Привет, Я использую приложение Doge Chat',
      lastSeen: '',
      createdAt: '',
      isOnline: true,
      friendsUIDs: [],
      friendRequestsUIDs: [],
      sentFriendRequestsUIDs: [],
    );

    model.saveUserDataToFireStore(
      userModel: userModel,
      fileImage: finalFileImage,
      onSuccess: () async {
        // save user data to shared preferences
        await model.saveUserData();

        navigateToHomeScreen();
      },
      onFail: () async {
        showSnackBar(context, 'Не удалось сохранить данные пользователя');
      },
    );
  }

  void navigateToHomeScreen() {
    // navigate to home screen and remove all previous screens
    Navigator.of(context).pushNamedAndRemoveUntil(
      Constants.homeScreen,
      (route) => false,
    );
  }

}