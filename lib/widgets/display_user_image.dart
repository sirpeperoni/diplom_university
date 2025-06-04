import 'dart:io';

import 'package:chat_app_diplom/entity/user_model.dart';
import 'package:chat_app_diplom/utilities/assets_manager.dart';
import 'package:flutter/material.dart';

class DisplayUserImage extends StatelessWidget {
  final File? finalFileImage;
  
  final double radius;
  
  final VoidCallback onPressed;

  final bool onUpdate;

  final UserModel? userModel;

  const DisplayUserImage({super.key, required this.finalFileImage, required this.radius, required this.onPressed, required this.onUpdate, this.userModel});

  @override
  Widget build(BuildContext context) {
    if(onUpdate && finalFileImage == null){
      return Stack(
                children: [
                  CircleAvatar(
                    radius: radius,
                    backgroundImage: NetworkImage(userModel!.image),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: onPressed,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Theme.of(context).primaryColor,
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              );
    }
    else if (finalFileImage == null && !onUpdate) {
      return Stack(
                children: [
                  CircleAvatar(
                    radius: radius,
                    backgroundImage: const AssetImage(AssetsManager.userImage),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: onPressed,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Theme.of(context).primaryColor,
                        child: const Icon(
                          Icons.camera_alt, 
                          color: Colors.white, 
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              );
    } else {
      return Stack(
                children: [
                  CircleAvatar(
                    radius: radius,
                    backgroundImage: FileImage(File(finalFileImage!.path)),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: onPressed,
                      child: const CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.green,
                        child: Icon(
                          Icons.camera_alt, 
                          color: Colors.white, 
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              );
    }
  }
}