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
        primarySwatch: Colors.green,
      ),
      home: BotFlowScreen(jsonFileName: 'test1.json')
    );
  }
}