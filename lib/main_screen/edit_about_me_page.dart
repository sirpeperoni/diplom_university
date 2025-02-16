import 'package:chat_app_diplom/entity/user_model.dart';
import 'package:chat_app_diplom/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditAboutMePage extends StatefulWidget {
  const EditAboutMePage({super.key});

  @override
  State<EditAboutMePage> createState() => _EditAboutMePageState();
}

class _EditAboutMePageState extends State<EditAboutMePage> {
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as UserModel;
    final aboutMe = args.aboutMe;
    final TextEditingController controller = TextEditingController(text: aboutMe);
    final model = context.read<AuthenticationProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Обо мне"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          model.updateUserAboutMe(value: controller.text);
          Navigator.pop(context, controller.text);
        },
        child: const Icon(Icons.check),
      ),
      body: Center(
        child: Expanded(
          child: TextField(
            controller: controller,
            maxLines: 9999,
          ),
        ),
      ),
    );
  }
}