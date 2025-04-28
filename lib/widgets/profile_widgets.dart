// ignore_for_file: use_build_context_synchronously

import 'package:chat_app_diplom/constants.dart';
import 'package:chat_app_diplom/entity/user_model.dart';
import 'package:chat_app_diplom/providers/auth_provider.dart';
import 'package:chat_app_diplom/providers/chat_provider.dart';
import 'package:chat_app_diplom/utilities/global_methods.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';



class ProfileStatusWidget extends StatelessWidget {
  const ProfileStatusWidget({
    super.key,
    required this.userModel,
    required this.currentUser,
  });

  final UserModel userModel;
  final UserModel currentUser;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        FriendRequestButton(
          currentUser: currentUser,
          userModel: userModel,
        ),
        const SizedBox(height: 10),
        FriendsButton(
          currentUser: currentUser,
          userModel: userModel,
        ),
      ],
    );
  }
}


class FriendRequestButton extends StatelessWidget {
  const FriendRequestButton({
    super.key,
    required this.userModel,
    required this.currentUser,
  });

  final UserModel userModel;
  final UserModel currentUser;

  @override
  Widget build(BuildContext context) {
    // friend request button
    Widget buildFriendRequestButton() {
      if (currentUser.uid == userModel.uid &&
          userModel.friendRequestsUIDs.isNotEmpty) {
        return MyElevatedButton(
          onPressed: () {
            // navigate to friend requests screen
            Navigator.pushNamed(
              context,
              Constants.friendRequestsScreen,
            );
          },
          label: 'Запросы',
          width: MediaQuery.of(context).size.width * 0.4,
          backgroundColor: Theme.of(context).cardColor,
          textColor: Theme.of(context).colorScheme.primary,
        );
      } else {
        // not in our profile
        return const SizedBox.shrink();
      }
    }

    return buildFriendRequestButton();
  }
}


class MyElevatedButton extends StatelessWidget {
  const MyElevatedButton({
    super.key,
    required this.onPressed,
    required this.label,
    required this.width,
    required this.backgroundColor,
    required this.textColor,
  });

  final VoidCallback onPressed;
  final String label;
  final double width;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    Widget buildElevatedButton() {
      return SizedBox(
        width: width,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: 5,
            backgroundColor: backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          onPressed: onPressed,
          child: Text(
            label.toUpperCase(),
            style: GoogleFonts.openSans(
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      );
    }

    return buildElevatedButton();
  }
}


class FriendsButton extends StatelessWidget {
  const FriendsButton({
    super.key,
    required this.userModel,
    required this.currentUser,
  });

  final UserModel userModel;
  final UserModel currentUser;

  @override
  Widget build(BuildContext context) {
    // friends button
    Widget buildFriendsButton() {
      if (currentUser.uid == userModel.uid &&
          userModel.friendsUIDs.isNotEmpty) {
        return MyElevatedButton(
          onPressed: () {
            // navigate to friends screen
            Navigator.pushNamed(
              context,
              Constants.friendsScreen,
            );
          },
          label: 'Друзья',
          width: MediaQuery.of(context).size.width * 0.4,
          backgroundColor: Theme.of(context).cardColor,
          textColor: Theme.of(context).colorScheme.primary,
        );
      } else {
        if (currentUser.uid != userModel.uid) {
          // show cancle friend request button if the user sent us friend request
          // else show send friend request button
          if (userModel.friendRequestsUIDs.contains(currentUser.uid)) {
            // show send friend request button
            return MyElevatedButton(
              onPressed: () async {
                await context
                    .read<AuthenticationProvider>()
                    .cancelFriendRequest(friendID: userModel.uid)
                    .whenComplete(() {
                  showSnackBar(context, 'Запрос на добавление в друзья отменен');
                });
              },
              label: 'Отменить запрос',
              width: MediaQuery.of(context).size.width * 0.5,
              backgroundColor: Theme.of(context).cardColor,
              textColor: Theme.of(context).colorScheme.primary,
            );
          } else if (userModel.sentFriendRequestsUIDs
              .contains(currentUser.uid)) {
            return MyElevatedButton(
              onPressed: () async {
                await context
                    .read<AuthenticationProvider>()
                    .acceptFriendRequest(friendID: userModel.uid)
                    .whenComplete(() {
                  showSnackBar(
                      context, 'Теперь вы друзьях с ${userModel.name}');
                });
              },
              label: 'Принять запрос',
              width: MediaQuery.of(context).size.width * 0.5,
              backgroundColor: Theme.of(context).cardColor,
              textColor: Theme.of(context).colorScheme.primary,
            );
          } else if (userModel.friendsUIDs.contains(currentUser.uid)) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                MyElevatedButton(
                  onPressed: () async {
                    // show unfriend dialog to ask the user if he is sure to unfriend
                    // create a dialog to confirm logout
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text(
                          'Удалить из друзей',
                          textAlign: TextAlign.center,
                        ),
                        content: Text(
                          'Вы уверены, что хотите удалить друзей ${userModel.name}?',
                          textAlign: TextAlign.center,
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Отмена'),
                          ),
                          TextButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              // remove friend
                              await context
                                  .read<AuthenticationProvider>()
                                  .removeFriend(friendID: userModel.uid)
                                  .whenComplete(() {
                                    showSnackBar(
                                        context, 'Вы больше не друзья.');
                                  });
                            },
                            child: const Text('Да'),
                          ),
                        ],
                      ),
                    );
                  },
                  label: 'Удалить из друзей',
                  width: MediaQuery.of(context).size.width * 0.6,
                  backgroundColor: Theme.of(context).cardColor,
                  textColor: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 10),
                MyElevatedButton(
                  onPressed: () async {
                    // navigate to chat screen
                    // navigate to chat screen with the folowing arguments
                    // 1. friend uid 2. friend name 3. friend image 
                    final commonKey = context.read<ChatProvider>().getCommonKey(userModel.uid);
                    String? chatId = '';
                    if(commonKey == null) {
                      final userID = context.read<AuthenticationProvider>().uid;
                      context.read<AuthenticationProvider>().createCommomKeyForSender(userModel.uid, userID!);
                    }
                    chatId = context.read<ChatProvider>().getChatId(userModel.uid);
                    Navigator.pushNamed(context, Constants.chatScreen,
                        arguments: {
                          Constants.contactUID: userModel.uid,
                          Constants.contactName: userModel.name,
                          Constants.contactImage: userModel.image,
                          Constants.chatId: chatId,
                          Constants.commonKey: commonKey,
                        });
                  },
                  label: 'Чат',
                  width: MediaQuery.of(context).size.width * 0.2,
                  backgroundColor: Theme.of(context).cardColor,
                  textColor: Theme.of(context).colorScheme.primary,
                ),
              ],
            );
          } else {
            return MyElevatedButton(
              onPressed: () async {
                await context
                  .read<AuthenticationProvider>()
                  .sendFriendRequest(friendID: userModel.uid)
                  .whenComplete(() {
                    showSnackBar(context, 'Запрос на добавление в друзья отправлен');
                  });
              },
              label: 'Отправить запрос',
              width: MediaQuery.of(context).size.width * 0.7,
              backgroundColor: Theme.of(context).cardColor,
              textColor: Theme.of(context).colorScheme.primary,
            );
          }
        } else {
          return const SizedBox.shrink();
        }
      }
    }

    return buildFriendsButton();
  }
}

