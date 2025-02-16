import 'package:chat_app_diplom/enums/enums.dart';
import 'package:chat_app_diplom/widgets/app_bar_back_buttons.dart';
import 'package:chat_app_diplom/widgets/friends_list.dart';
import 'package:flutter/material.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AppBarBackButton(onPressed: () {
          Navigator.pop(context);
        }),
        centerTitle: true,
        title: const Text('Друзья'),
      ),
      body: const FriendsList(viewType: FriendViewType.friends,),
      );
  }
}