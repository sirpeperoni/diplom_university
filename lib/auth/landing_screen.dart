import 'package:chat_app_diplom/constants.dart';
import 'package:chat_app_diplom/providers/auth_provider.dart';
import 'package:chat_app_diplom/utilities/assets_manager.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  @override
  void initState() {
    checkAuthentication();
    super.initState(); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          height: 400,
          width: 400,
          child: Column(
            children: [
              Lottie.asset(
                AssetsManager.dogStartScreen,
              ),
              Text(
                'Doge Chat',
                style: 
                  GoogleFonts.openSans(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void checkAuthentication() async {
    final model = context.read<AuthenticationProvider>();
    bool isAuthenticated = await model.checkAuthenticationState();
    navigate(isAuthenticated: isAuthenticated);
  }

  void navigate({required bool isAuthenticated}){
    if (isAuthenticated) {
      Navigator.pushReplacementNamed(context, Constants.homeScreen);
    }
    else {
      Navigator.pushReplacementNamed(context, Constants.loginScreen);
    }
  }
}