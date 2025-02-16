import 'package:chat_app_diplom/providers/auth_provider.dart';
import 'package:chat_app_diplom/utilities/assets_manager.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';



class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final  TextEditingController _phoneNumberController = TextEditingController();
  Country selectedCountry = Country(
    phoneCode: "7",
    countryCode: "RU",
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: "Russia",
    example: "Russia",
    displayName: "Russia",
    displayNameNoCountryCode: "RU",
    e164Key: "",
  );

  @override
  void dispose() {
    _phoneNumberController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final model = context.watch<AuthenticationProvider>();
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Column(
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
                'Добавьте свой номер телефона, и вам будет отправлен код для подтверждения.',
                textAlign: TextAlign.center,
                style: 
                  GoogleFonts.openSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
              ),
              const SizedBox(height: 20,),
              TextFormField(
                controller: _phoneNumberController,
                onChanged: (value){
                  setState(() {
                    _phoneNumberController.text = value;
                  });
                },
                maxLength: 10,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  counterText: '',
                  hintText: 'Номер телефона',
                  hintStyle: GoogleFonts.openSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  prefixIcon: Container(
                    padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
                    child: InkWell(
                      onTap: () {
                        showCountryPicker(
                          context: context,
                          showPhoneCode: true,
                          countryListTheme: CountryListThemeData(
                            textStyle: GoogleFonts.openSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            )
                          ),
                          onSelect: (value) {
                            setState(() {
                              selectedCountry = value;
                            });
                          },
                        );
                      },
                      child: Text(
                        '${selectedCountry.flagEmoji} +${selectedCountry.phoneCode}',
                        style: GoogleFonts.openSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  suffixIcon:_phoneNumberController.text.length > 9 
                  ? model.isLoading 
                  ? const CircularProgressIndicator(color: Colors.white,) :              
                  InkWell(
                    onTap: () {
                      model.signInWithPhoneNumber(phoneNumber: '+${selectedCountry.phoneCode}${_phoneNumberController.text}', context: context);
                    },
                    child: Container(
                      height: 35,
                      width: 35,
                      margin: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle
                      ),
                      child: const Icon(Icons.done, color: Colors.white, size: 25,),
                    ),
                  ) : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}