import 'package:chat_app_diplom/constants.dart';
import 'package:chat_app_diplom/providers/auth_provider.dart';
import 'package:chat_app_diplom/utilities/assets_manager.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';



class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final  TextEditingController _emailController = TextEditingController();
  final  TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final model = context.watch<AuthenticationProvider>();
    final RoundedLoadingButtonController _btnCodeController = RoundedLoadingButtonController();
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                const SizedBox(height: 50,),
                SizedBox(
                  height: 200,
                  width: 200,
                  child: Lottie.asset(
                    AssetsManager.dogStartScreen,
                  ),
                ),
                Text(
                  'Doge Chat',
                  style: 
                    GoogleFonts.openSans(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                ),
                const SizedBox(height: 20,),
                Text(
                  'Войдите с помощью вашего email и пароля', 
                  textAlign: TextAlign.center,
                  style: 
                    GoogleFonts.openSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                ),
                
                const SizedBox(height: 20,),
                TextFormField(
                  controller: _emailController,
                  onChanged: (value){
                    setState(() {
                      _emailController.text = value;
                    });
                  },
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: 'Email',
                    suffixIcon: RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(_emailController.text) ? Container(
                                height: 35,
                                width: 35,
                                margin: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.done,
                                  color: Colors.white,
                                  size: 25,
                                ),
                              ) : null,
                    hintStyle: GoogleFonts.openSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  )
                ),
                const SizedBox(height: 20,),
                TextFormField(
                  controller: _passwordController,
                  onChanged: (value){
                    setState(() {
                      _passwordController.text = value;
                    });
                  },
                  textInputAction: TextInputAction.done,
                  obscureText: true,
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: 'Пароль',
                    suffixIcon: _passwordController.text.length >= 6 ? Container(
                                height: 35,
                                width: 35,
                                margin: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.done,
                                  color: Colors.white,
                                  size: 25,
                                ),
                              ) : null,
                    hintStyle: GoogleFonts.openSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  )
                ),
                TextButton(onPressed: () {
                  Navigator.pushNamed(context, Constants.registerScreen);
                }, child: Text("Нету аккаунта? Зарегистрироваться", style: GoogleFonts.openSans(fontSize: 16, fontWeight: FontWeight.w500),)),

                SizedBox(
                    width: double.infinity,
                    child: RoundedLoadingButton(
                      controller: _btnCodeController,
                      onPressed: !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(_emailController.text) || _passwordController.text.length < 6 ? null : () async {
                        model.signInWithEmailAndPassword(
                            email: _emailController.text, 
                            password: _passwordController.text, 
                            context: context,
                            onSuccess: () async {
                              //1 провереть, есть ли в firestore пользователь с таким номером телефона
                              bool userExists = await model.checkIfUserExists();
                              if(userExists) {
                                await model.getUserDataFromFirestore(); 
                                // * сохранить данные пользователя в shared preferences / provi
                                await model.saveUserData();
                                //перейти на экран home screen
                                // ignore: use_build_context_synchronously
                                Navigator.pushNamedAndRemoveUntil(context, Constants.homeScreen, (route) => false); 
                              } else {
                                // ignore: use_build_context_synchronously
                                Navigator.pushNamed(context, Constants.userInformationScreen);
                              }                   
                            }
                          );
                      },
                      successIcon: Icons.check,
                      successColor: Colors.green,
                      errorColor: Colors.red,
                      color: Theme.of(context).primaryColor,
                      child: const Text(
                        'Войти',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500
                        )
                      ),
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}