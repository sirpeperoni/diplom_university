import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isDarkMode = false;

  // get the saved theme mode
  void getThemeMode() async {
    final savedThemeMode = await AdaptiveTheme.getThemeMode();
    if(savedThemeMode == AdaptiveThemeMode.dark){
      setState(() {
        isDarkMode = true;
      });
    } else {
      setState(() {
        isDarkMode = false;
      });
    }
  }

  @override
  void initState() {
    getThemeMode();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Чаты"),
      ),
      body: Center(
        child: Card(
          child: SwitchListTile(
            title: const Text("Сменить тему"),
            secondary: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.white : Colors.black,
                shape: BoxShape.circle
              ),
              child: Icon(isDarkMode ? Icons.nightlight_round : Icons.sunny, color: isDarkMode ? Colors.black : Colors.white),
            ),
            value: isDarkMode,
            onChanged: (value) {
              setState(() {
                isDarkMode = value;
                if(value){
                  AdaptiveTheme.of(context).setDark();
                } else {
                  AdaptiveTheme.of(context).setLight();
                }
              });
            },
          ),
        ),
      ),
    );
  }
}