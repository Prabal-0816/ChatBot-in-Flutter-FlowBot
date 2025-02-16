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
            titleTextStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          // Define the default elevated button theme
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: Colors.blue.shade900,
              textStyle: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),

          // Define the default text theme
          textTheme: TextTheme(
            bodyLarge: TextStyle(fontSize: 16, color: Colors.black),
            bodyMedium: TextStyle(fontSize: 14, color: Colors.black),
          ),
        ),
        home: BotFlowScreen(jsonFileName: 'test1.json'));
  }
}
