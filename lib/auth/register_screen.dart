import 'package:chat_app_diplom/constants.dart';
import 'package:chat_app_diplom/providers/auth_provider.dart';
import 'package:chat_app_diplom/utilities/assets_manager.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';



class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final  TextEditingController _emailController = TextEditingController();
  final  TextEditingController _passwordController = TextEditingController();
  final  TextEditingController _repeatPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final model = context.watch<AuthenticationProvider>();
    final RoundedLoadingButtonController btnCodeController = RoundedLoadingButtonController();
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
                  'Добавьте свой Email, и вам будет отправлен код для подтверждения.',
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
                const SizedBox(height: 20,),
                TextFormField(
                  controller: _repeatPasswordController,
                  onChanged: (value){
                    setState(() {
                      _repeatPasswordController.text = value;
                    });
                  },
                  textInputAction: TextInputAction.done,
                  obscureText: true,
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: 'Повторите пароль',
                    suffixIcon: _repeatPasswordController.text.length >= 6 && _repeatPasswordController.text == _passwordController.text ? Container(
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
                  Navigator.pushNamed(context, Constants.loginScreen);
                }, child: Text("Уже есть аккаунт? Войти", style: GoogleFonts.openSans(fontSize: 16, fontWeight: FontWeight.w500),)),
                // ElevatedButton(
                //   style: ButtonStyle(
                //     shape: WidgetStateProperty.all(
                //       RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(5),
                //       ),
                //     ),
                //   ),
                //   onPressed: !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(_emailController.text) || _passwordController.text.length < 6 ? null : () async {
                //     bool userExists = await model.checkIfUserExists();
                //     if(userExists){
                //       // ignore: use_build_context_synchronously
                //       Navigator.pushNamedAndRemoveUntil(context, Constants.homeScreen, (route) => false);
                //     } else {
                //       final otp = model.generateOTP();
                //       model.saveOTPToSharedPrefernce(otp);
                //       // ignore: use_build_context_synchronously
                //       model.sendCodeEmail(email: _emailController.text, password: _passwordController.text, otp: otp, context: context);
                //     }
                    
                //   },
                //   child: const Text(
                //     "Зарегистрироваться",
                //   ),
                // ),
                SizedBox(
                    width: double.infinity,
                    child: RoundedLoadingButton(
                      controller: btnCodeController,
                      onPressed: !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(_emailController.text) || _passwordController.text.length < 6 ? null : () async {
                          bool userExists = await model.checkIfUserExists();
                          if(userExists){
                            // ignore: use_build_context_synchronously
                            Navigator.pushNamedAndRemoveUntil(context, Constants.homeScreen, (route) => false);
                          } else {
                            final otp = model.generateOTP();
                            model.saveOTPToSharedPrefernce(otp);
                            // ignore: use_build_context_synchronously
                            model.sendCodeEmail(email: _emailController.text, password: _passwordController.text, otp: otp, context: context);
                          }
                          
                      },
                      successIcon: Icons.check,
                      successColor: Colors.green,
                      errorColor: Colors.red,
                      color: Theme.of(context).primaryColor,
                      child: const Text(
                        'Зарегистрироваться',
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