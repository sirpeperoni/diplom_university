import 'dart:io';

import 'package:chat_app_diplom/utilities/assets_manager.dart';
import 'package:flutter/material.dart';

class DisplayUserImage extends StatelessWidget {
  final File? finalFileImage;
  
  final double radius;
  
  final VoidCallback onPressed;

  const DisplayUserImage({super.key, required this.finalFileImage, required this.radius, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return finalFileImage == null ?
              Stack(
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
              ) : Stack(
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