import 'package:chat_app_diplom/entity/user_model.dart';
import 'package:chat_app_diplom/enums/enums.dart';
import 'package:chat_app_diplom/providers/auth_provider.dart';
import 'package:chat_app_diplom/widgets/friend_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SerchUsersPage extends StatefulWidget {
  const SerchUsersPage({super.key});

  @override
  State<SerchUsersPage> createState() => _SerchUsersPageState();
}

class _SerchUsersPageState extends State<SerchUsersPage> {
  @override
  Widget build(BuildContext context) {
    final uid = context.watch<AuthenticationProvider>().userModel!.uid;
    final model = context.watch<AuthenticationProvider>();
    initState(){
      super.initState();
    }
    return  Scaffold(
      appBar: AppBar(
        title: const Text('Поиск'),
      ),
      body: Padding(
        padding:const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CupertinoSearchTextField(
              placeholder: 'Поиск',
              style: const TextStyle(
                color: Colors.black,
              ),
              onChanged: (value) {
                model.getStreamUsers(value, uid);
              },
            ),
            Expanded(
              child: model.streamUsers == null ? const Center(
                child: Text(
                  'Нет результатов',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                  ),
                ),
              ) : StreamBuilder<List<UserModel>>(
                stream: model.streamUsers, 
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text('Something went wrong'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if(snapshot.hasData){
                    final users = snapshot.data!;
                    return ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return FriendWidget(
                          friend: user, viewType: FriendViewType.allUsers);
                      }
                    );
                  }
                  return const Center(child: Text('Нет чатов'));
                }
              )
            )
          ],
        )
      ),
    );
  }
}