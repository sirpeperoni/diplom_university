import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app_diplom/constants.dart';
import 'package:flutter/material.dart';

class ImageScreen extends StatefulWidget {
  const ImageScreen({super.key});
  @override
  State<ImageScreen> createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {
  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
    final imageLink = arguments[Constants.imageLink];
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: CachedNetworkImage(
          imageUrl: imageLink,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}