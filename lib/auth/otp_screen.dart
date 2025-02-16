import 'package:chat_app_diplom/constants.dart';
import 'package:chat_app_diplom/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';


class OTPScreen extends StatefulWidget {
  const OTPScreen({super.key});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final TextEditingController _pinPutController = TextEditingController();
  final FocusNode _pinPutFocusNode = FocusNode();
  String? otpCode;

  @override
  void dispose() {
    _pinPutController.dispose();
    _pinPutFocusNode.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final phoneNumber = args[Constants.phoneNumber] as String;
    final verificationId = args[Constants.verificationId] as String;

    final model = context.watch<AuthenticationProvider>();
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: GoogleFonts.openSans(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).primaryColor
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade200,
        border: Border.all(
          color: Colors.transparent
        )
      ),
    );
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              children: [
                const SizedBox(height: 50,),
                Text(
                  'Верефикация',
                  style: GoogleFonts.openSans(
                    fontSize: 28,
                    fontWeight: FontWeight.bold
                  ),
                ),
                const SizedBox(height: 30,),
                Text(
                  'Введите 6-значный код, отправленный на ваш номер.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.openSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w500
                  ),
                ),
                const SizedBox(height: 10,),
                Text(
                  phoneNumber,
                  style: GoogleFonts.openSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w500
                  ),
                ),
                const SizedBox(height: 30,),
                SizedBox(
                  height: 68,
                  child: Pinput(
                    length: 6,
                    controller: _pinPutController,
                    focusNode: _pinPutFocusNode,
                    defaultPinTheme: defaultPinTheme,
                    onCompleted: (pin){
                      setState(() {
                        otpCode = pin;
                      });
                      verifyOTPCode(verificationId: verificationId, otpCode:otpCode!);
                    },
                    focusedPinTheme: defaultPinTheme.copyWith(
                      height: 68,
                      width: 64,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey.shade200,
                        border: Border.all(
                          color: Colors.deepPurple
                        )
                      ),
                    ),
                    errorPinTheme: defaultPinTheme.copyWith(
                      height: 68,
                      width: 64,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey.shade200,
                        border: Border.all(
                          color: Colors.red
                        )
                      ),
                    )
                  ),
                ),
                const SizedBox(height: 30,),
                model.isLoading 
                  ? const CircularProgressIndicator() 
                  : const SizedBox.shrink(),

                model.isSuccessful ? Container(
                  height: 50,
                  width: 50,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 30,
                  )
                ) : const SizedBox.shrink(),

                model.isLoading ? const SizedBox.shrink() :
                Text(
                  'Не пришёл код?',
                  style: GoogleFonts.openSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w500
                  ),
                ),
                const SizedBox(height: 10,),
                TextButton(
                  onPressed: () {
                    //todo resend otp code
                  }, 
                  child: Text(
                    'Отправить повторно', 
                    style: GoogleFonts.openSans(
                      fontSize: 16, 
                      fontWeight: FontWeight.w600, 
                    ),
                  )
                )
              ]
            ),
          )
        ),
      ),
    );
  }

  void verifyOTPCode({required String verificationId,required String otpCode}) async {
    final model = context.read<AuthenticationProvider>();
    model.verifyOTP(
      verificationId: verificationId, 
      otpCode: otpCode, 
      context: context, 
      onSuccess: () async {
        //1 провереть, есть ли в firestore пользователь с таким номером телефона
        bool userExists = await model.checkIfUserExists();

        //2 если есть, то 
        if(userExists) {
          // * получить данные пользователя из firestore
          await model.getUserDataFromFirestore(); 
          // * сохранить данные пользователя в shared preferences / provi
          await model.saveUserDataToSharedPreferences();
          //перейти на экран home screen
          navigate(userExists: true);
        }
        else {
          // 3 если нет, то перейти на экран создания профиля
          navigate(userExists: false);
        }      
      }
    );
  }

  void navigate({required bool userExists}) {
    if(userExists) {
      Navigator.pushNamedAndRemoveUntil(context, Constants.homeScreen, (route) => false);
    }
    else {
      Navigator.pushNamed(context, Constants.userInformationScreen);
    }
  }

}