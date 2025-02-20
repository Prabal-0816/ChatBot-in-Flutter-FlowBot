import 'package:flow_bot_json_driven_chat_bot/ChatBot/UI/messageBubble.dart';
import 'package:flutter/cupertino.dart';

class AnimatedMessageBubble extends StatelessWidget {
  final String text;
  final bool isBot;
  final String botImage;
  final DateTime timestamp;

  const AnimatedMessageBubble({
    super.key,
    required this.text,
    required this.isBot,
    required this.botImage,
    required this.timestamp
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 100),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: Offset(isBot ? -1 : 1, 0), // Slide from left (bot) or right (user)
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          )),
          child: child,
        );
      },
      child: MessageBubble(
        key: ValueKey(text), // Unique key for each message
        text: text,
        isBot: isBot,
        botImage: botImage,
        timestamp: timestamp,
      ),
    );
  }
}