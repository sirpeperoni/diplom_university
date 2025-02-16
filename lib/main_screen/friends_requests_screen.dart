import 'package:chat_app_diplom/enums/enums.dart';
import 'package:chat_app_diplom/widgets/friends_list.dart';
import 'package:flutter/material.dart';

class FriendsRequestsScreen extends StatefulWidget {
  const FriendsRequestsScreen({super.key});

  @override
  State<FriendsRequestsScreen> createState() => _FriendsRequestsScreenState();
}

class _FriendsRequestsScreenState extends State<FriendsRequestsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Заявки в друзья'),
      ),
      body: const FriendsList(viewType: FriendViewType.friendRequests,),
    );
  }
}