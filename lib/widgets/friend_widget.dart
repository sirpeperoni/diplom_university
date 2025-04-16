import 'package:chat_app_diplom/constants.dart';
import 'package:chat_app_diplom/entity/user_model.dart';
import 'package:chat_app_diplom/enums/enums.dart';
import 'package:chat_app_diplom/providers/auth_provider.dart';
import 'package:chat_app_diplom/utilities/global_methods.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FriendWidget extends StatelessWidget {
  const FriendWidget({
    super.key,
    required this.friend,
    required this.viewType,
  });

  final UserModel friend;
  final FriendViewType viewType;


  @override
  Widget build(BuildContext context) {
    final uid = context.watch<AuthenticationProvider>().userModel!.uid;
    final name = uid == friend.uid ? 'Вы' : friend.name;

    return ListTile(
      minLeadingWidth: 0.0,
      leading:
          userImageWidget(imageUrl: friend.image, radius: 40, onTap: () {}),
      title: Text(name),
      subtitle: Text(
        friend.aboutMe,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: viewType == FriendViewType.friendRequests
          ? ElevatedButton(
              onPressed: () async {
                  // accept friend request
                  await context
                      .read<AuthenticationProvider>()
                      .acceptFriendRequest(friendID: friend.uid)
                      .whenComplete(() {
                    showSnackBar(
                        // ignore: use_build_context_synchronously
                        context, 'Теперь вы друзья с ${friend.name}');
                  });
              },
              child: const Text('Принять'),
            ) : null,
          
      onTap: () {
        if (viewType == FriendViewType.friends) {
          // navigate to chat screen with the folowing arguments
          // 1. friend uid 2. friend name 3. friend image 
          Navigator.pushNamed(context, Constants.chatScreen, arguments: {
            Constants.contactUID: friend.uid,
            Constants.contactName: friend.name,
            Constants.contactImage: friend.image,
          });
        } else if (viewType == FriendViewType.allUsers) {
          // navite to this user's profile screen
          Navigator.pushNamed(
            context,
            Constants.profileScreen,
            arguments: {
              "CurrentUserPage":uid,
              "UserPage":friend.uid
            },
          );
        } 
      },
    );
  }
}