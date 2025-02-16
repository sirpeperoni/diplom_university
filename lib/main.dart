import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:chat_app_diplom/auth/landing_screen.dart';
import 'package:chat_app_diplom/auth/login_screen.dart';
import 'package:chat_app_diplom/auth/otp_screen.dart';
import 'package:chat_app_diplom/auth/user_information_screen.dart';
import 'package:chat_app_diplom/constants.dart';
import 'package:chat_app_diplom/firebase_options.dart';
import 'package:chat_app_diplom/main_screen/chat_screen.dart';
import 'package:chat_app_diplom/main_screen/edit_about_me_page.dart';
import 'package:chat_app_diplom/main_screen/friends_requests_screen.dart';
import 'package:chat_app_diplom/main_screen/friends_screen.dart';
import 'package:chat_app_diplom/main_screen/main_screen.dart';
import 'package:chat_app_diplom/main_screen/profile_screen.dart';
import 'package:chat_app_diplom/main_screen/search/search_chats_page.dart';
import 'package:chat_app_diplom/main_screen/search/search_users_page.dart';
import 'package:chat_app_diplom/providers/auth_provider.dart';
import 'package:chat_app_diplom/providers/chat_provider.dart';
import 'package:chat_app_diplom/widgets/image.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final savedThemeMode = await AdaptiveTheme.getThemeMode();
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (context) => AuthenticationProvider()),
    ChangeNotifierProvider(create: (context) => ChatProvider()),
  ], child: MainApp(savedThemeMode: savedThemeMode)));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key, required this.savedThemeMode});

  final AdaptiveThemeMode? savedThemeMode;

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      initial: savedThemeMode ?? AdaptiveThemeMode.light,
      light: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: Colors.purple,
      ),
      dark: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.purple,
      ),
      builder: (theme, darkTheme) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme,
        darkTheme: darkTheme,
        initialRoute: Constants.landingScreen,
        routes: {
          Constants.landingScreen: (context) => const LandingScreen(),
          Constants.loginScreen: (context) => const LoginScreen(),
          Constants.otpScreen: (context) => const OTPScreen(),
          Constants.userInformationScreen: (context) => const UserInformationScreen(),
          Constants.homeScreen: (context) => const HomeScreen(),
          Constants.profileScreen: (context) => const ProfileScreen(),
          Constants.friendsScreen: (context) => const FriendsScreen(),
          Constants.friendRequestsScreen: (context) => const FriendsRequestsScreen(),
          Constants.chatScreen: (context) => const ChatScreen(),
          Constants.ImageScreen: (context) => const ImageScreen(),
          Constants.searchChats: (context) => const SerchChatsPage(),
          Constants.searchUsers: (context) => const SerchUsersPage(),
          Constants.editAboutMeScreem: (context) => const EditAboutMePage(),
        },
      ),
    );
  }
}
