import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:chat_app_diplom/constants.dart';
import 'package:chat_app_diplom/entity/user_model.dart';
import 'package:chat_app_diplom/providers/auth_provider.dart';
import 'package:chat_app_diplom/utilities/global_methods.dart';
import 'package:chat_app_diplom/widgets/app_bar_back_buttons.dart';
import 'package:chat_app_diplom/widgets/info_details.dart';
import 'package:chat_app_diplom/widgets/settings_list_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isDarkMode = false;

  // get the saved theme mode
  void getThemeMode() async {
    // get the saved theme mode
    final savedThemeMode = await AdaptiveTheme.getThemeMode();
    // check if the saved theme mode is dark
    if (savedThemeMode == AdaptiveThemeMode.dark) {
      // set the isDarkMode to true
      setState(() {
        isDarkMode = true;
      });
    } else {
      // set the isDarkMode to false
      setState(() {
        isDarkMode = false;
      });
    }
  }

  @override
  void initState() {
    getThemeMode();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    // get user data from arguments
    final UserPageArguments = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final uid = UserPageArguments['UserPage'];
    final currentUid = UserPageArguments['CurrentUserPage'];
    final model = context.read<AuthenticationProvider>();
    return Scaffold(
      appBar: AppBar(
        leading: AppBarBackButton(
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: const Text('Профиль'),
      ),
      body: StreamBuilder(
        stream: model.userStream(userID: uid),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final userModel =
              UserModel.fromMap(snapshot.data!.data() as Map<String, dynamic>);
          
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InfoDetails(
                    userModel: userModel,
                    currentUser: model.userModel,
                  ),
                  const SizedBox(height: 10),
                  currentUid == uid ? Card(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        decoration: BoxDecoration(
                          color: Colors.deepPurple,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            isDarkMode
                                ? Icons.nightlight_round
                                : Icons.wb_sunny_rounded,
                            color: isDarkMode ? Colors.black : Colors.white,
                          ),
                        ),
                      ),
                      title: const Text('Сменить тему'),
                      trailing: Switch(
                          value: isDarkMode,
                          onChanged: (value) {
                            // set the isDarkMode to the value
                            setState(() {
                              isDarkMode = value;
                            });
                            // check if the value is true
                            if (value) {
                              // set the theme mode to dark
                              AdaptiveTheme.of(context).setDark();
                            } else {
                              // set the theme mode to light
                              AdaptiveTheme.of(context).setLight();
                            }
                          }),
                    ),
                  ) : const SizedBox.shrink(),
                  const SizedBox(height: 10),
                  currentUid == uid ? Card(
                    child: Column(
                      children: [
                        SettingsListTile(
                          title: 'Выйти из аккаунта',
                          icon: Icons.logout_outlined,
                          iconContainerColor: Colors.red,
                          onTap: () {
                            showMyAnimatedDialog(
                              context: context,
                              title: 'Выход',
                              content: 'Вы уверены, что хотите выйти?',
                              textAction: 'Выйти',
                              onActionTap: (value) {
                                if (value) {
                                  // logout
                                  model
                                      .logout()
                                      .whenComplete(() {
                                    Navigator.pop(context);
                                    Navigator.pushNamedAndRemoveUntil(
                                      context,
                                      Constants.loginScreen,
                                      (route) => false,
                                    );
                                  });
                                }
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ) :  const SizedBox.shrink(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}