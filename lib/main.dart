import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:chat_app_diplom/auth/encrtyption_service.dart';
import 'package:chat_app_diplom/auth/landing_screen.dart';
import 'package:chat_app_diplom/auth/login_screen.dart';
import 'package:chat_app_diplom/auth/otp_screen.dart';
import 'package:chat_app_diplom/auth/register_screen.dart';
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
import 'package:chat_app_diplom/repositories/auth_repository.dart';
import 'package:chat_app_diplom/repositories/chat_repository.dart';
import 'package:chat_app_diplom/repositories/download_repository.dart';
import 'package:chat_app_diplom/repositories/email_repository.dart';
import 'package:chat_app_diplom/repositories/shared_preferences_repository.dart';
import 'package:chat_app_diplom/widgets/image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "api_keys.env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final savedThemeMode = await AdaptiveTheme.getThemeMode();
  final sharedPreferences = await SharedPreferences.getInstance();
  await FlutterDownloader.initialize(
    debug: true, // optional: set to false to disable printing logs to console (default: true)
    ignoreSsl: true // option: set to false to disable working with http links (default: false)
  );

  runApp(MultiProvider(providers: [
    Provider(create: (_) => FirebaseAuth.instance),
    Provider(create: (_) => FirebaseFirestore.instance),
    Provider(create: (_) => Dio()),
    Provider<SharedPreferences>(
      create: (context) => sharedPreferences,
    ),
    Provider(create: (ctx) => EncryptionService(ctx.read<FirebaseFirestore>(), ctx.read<SharedPreferences>())),
    Provider(create: (ctx) => AuthRepository(ctx.read<FirebaseFirestore>(), ctx.read<FirebaseAuth>())),
    Provider(create: (ctx) => ChatRepository(ctx.read<FirebaseFirestore>())),
    Provider(create: (ctx) => EmailRepository(ctx.read<Dio>())),
    Provider(create: (ctx) => SharedPreferencesRepository(ctx.read<SharedPreferences>())),
    ChangeNotifierProvider(
            create: (_) => DownloadRepository(),
    ),
    ChangeNotifierProvider(create: (ctx) => AuthenticationProvider(ctx.read<AuthRepository>(), ctx.read<SharedPreferencesRepository>(), ctx.read<EmailRepository>())),
    ChangeNotifierProvider(create: (ctx) => ChatProvider(ctx.read<ChatRepository>(), ctx.read<SharedPreferencesRepository>(), ctx.read<EncryptionService>())),
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
          Constants.registerScreen: (context) => const RegisterScreen(),
          Constants.otpScreen: (context) => const OTPScreen(),
          Constants.userInformationScreen: (context) => const UserInformationScreen(),
          Constants.homeScreen: (context) => const HomeScreen(),
          Constants.profileScreen: (context) => const ProfileScreen(),
          Constants.friendsScreen: (context) => const FriendsScreen(),
          Constants.friendRequestsScreen: (context) => const FriendsRequestsScreen(),
          Constants.chatScreen: (context) => const ChatScreen(),
          Constants.imageScreen: (context) => const ImageScreen(),
          Constants.searchChats: (context) => const SerchChatsPage(),
          Constants.searchUsers: (context) => const SerchUsersPage(),
          Constants.editAboutMeScreem: (context) => const EditAboutMePage(),
        },
      ),
    );
  }
}
