import 'package:chat_app_diplom/constants.dart';
import 'package:chat_app_diplom/main_screen/my_chats_screen.dart';
import 'package:chat_app_diplom/main_screen/people_screen.dart';
import 'package:chat_app_diplom/providers/auth_provider.dart';
import 'package:chat_app_diplom/utilities/global_methods.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver, TickerProviderStateMixin {
  final PageController pageController = PageController(initialPage: 0);
  int currentIndex = 0;

  final List<Widget> screens = [
    const MyChatsScreen(),
    const PeopleScreen(),
  ];

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // user comes back to the app
        // update user status to online
        context.read<AuthenticationProvider>().updateUserStatus(
              value: true,
        );
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        // app is inactive, paused, detached or hidden
        // update user status to offline
        context.read<AuthenticationProvider>().updateUserStatus(
              value: false,
        );
        break;
      default:
        // handle other states
        break;
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AuthenticationProvider>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Doge Chat"),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: userImageWidget(imageUrl: model.userModel!.image, radius: 20, onTap: (){
              //navigate to user profile
              Navigator.pushNamed(
                context, 
                Constants.profileScreen,
                arguments: {
                  "CurrentUserPage":model.userModel!.uid,
                  "UserPage":model.userModel!.uid
                }
              );
            }),
          )
        ],
      ),
      body: PageView(
        controller: pageController,
        onPageChanged: (value) {
          currentIndex = value;
          setState(() {});
        },
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.chat_bubble_2),
            label: "Чаты",
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.globe),
            label: "Люди",
          ),
        ],
        currentIndex: currentIndex,
        onTap: (index) {
          pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut
          );
          setState(() {
            currentIndex = index;
          });
        },
      )
    );
  }
}

