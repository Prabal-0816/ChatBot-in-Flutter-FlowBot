import 'package:flutter/material.dart';
import 'ChatBot/UI/botFlowScreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Chatbot',
        theme: ThemeData(
          brightness: Brightness.light,
          primaryColor: Colors.blue.shade900,

          // Default app bar theme
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.blue.shade900,
            titleTextStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          // Define the default elevated button theme
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: Colors.blue.shade900,
              textStyle: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        home: BotFlowScreen(jsonFileName: 'travel.json'));
  }
}
