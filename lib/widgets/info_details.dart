import 'package:chat_app_diplom/constants.dart';
import 'package:chat_app_diplom/entity/user_model.dart';
import 'package:chat_app_diplom/providers/auth_provider.dart';
import 'package:chat_app_diplom/utilities/global_methods.dart';
import 'package:chat_app_diplom/widgets/profile_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class InfoDetails extends StatelessWidget {
  const InfoDetails({
    super.key,
    this.isAdmin,
    this.userModel,
    this.currentUser
  });

  final bool? isAdmin;
  final UserModel? userModel;
  final UserModel? currentUser;

  @override
  Widget build(BuildContext context) {
    // get current user
    final currentUser = context.read<AuthenticationProvider>().userModel!;
    // get profile image
    final profileImage = userModel!.image;
    // get profile name
    final profileName = userModel!.name;

    // get group description
    final aboutMe = userModel!.aboutMe;
    return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 20,
            ),
            child: Column(
              children: [
                Center(
                  child: userImageWidget(
                    imageUrl: profileImage,
                    radius: 90,
                    onTap: () {
                      // navigate to user profile with uis as arguments
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  profileName,
                  style: GoogleFonts.openSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                // display phone number
                currentUser.uid == userModel!.uid
                    ? Text(
                        userModel!.phoneNumber,
                        style: GoogleFonts.openSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    : const SizedBox.shrink(),
                const SizedBox(height: 10),
                FriendRequestButton(userModel: userModel!, currentUser: currentUser),
    
                const SizedBox(height: 10),
                FriendsButton(userModel: userModel!, currentUser: currentUser,),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 40,
                      width: 40,
                      child: Divider(
                        color: Colors.grey,
                        thickness: 1,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Обо мне',
                      style: GoogleFonts.openSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const SizedBox(
                      height: 40,
                      width: 40,
                      child: Divider(
                        color: Colors.grey,
                        thickness: 1,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.75,
                      child: Text(
                        userModel!.aboutMe,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.openSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if(currentUser.uid == userModel!.uid)...{
                      IconButton(icon: Icon(Icons.edit), onPressed: () {
                          // navigate to edit profile screen
                          Navigator.of(context).pushNamed(Constants.editAboutMeScreem, arguments: userModel);
                      }),
                    }
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 40,
                      width: 40,
                      child: Divider(
                        color: Colors.grey,
                        thickness: 1,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Друзья',
                      style: GoogleFonts.openSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const SizedBox(
                      height: 40,
                      width: 40,
                      child: Divider(
                        color: Colors.grey,
                        thickness: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
  }
}