import 'package:chat_app_diplom/constants.dart';
import 'package:chat_app_diplom/entity/user_model.dart';
import 'package:chat_app_diplom/enums/enums.dart';
import 'package:chat_app_diplom/providers/auth_provider.dart';
import 'package:chat_app_diplom/widgets/friend_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class PeopleScreen extends StatefulWidget {
  const PeopleScreen({super.key});

  @override
  State<PeopleScreen> createState() => _PeopleScreenState();
}


class _PeopleScreenState extends State<PeopleScreen> {
  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthenticationProvider>().userModel!;
    return Scaffold(
        body: SafeArea(
      child: Column(
        children: [
          // cupertino search bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CupertinoSearchTextField(
              placeholder: 'Поиск',
              onChanged: (value) {
                // search for users
                
              },
              onTap: () {
                Navigator.pushNamed(context, Constants.searchUsers);
              },
            ),
          ),

          // list of users
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: context
                  .read<AuthenticationProvider>()
                  .getAllUsersStream(userID: currentUser.uid),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Something went wrong'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'No users found',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.openSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.2),
                    ),
                  );
                }

                return ListView(
                  children: snapshot.data!.docs.map((DocumentSnapshot document) {
                    final data = UserModel.fromMap(
                        document.data()! as Map<String, dynamic>);
                    return FriendWidget(
                        friend: data, viewType: FriendViewType.allUsers);
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    ));
  }
}