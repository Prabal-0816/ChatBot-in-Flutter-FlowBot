import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final String text;
  final bool isBot;
  final String botImage;
  final DateTime timestamp;

  const MessageBubble({
    super.key,
    required this.text,
    required this.isBot,
    required this.botImage,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isBot ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Bot Avatar (only for bot messages)
          if (isBot)
            CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(botImage),
              backgroundColor: Colors.blue.shade900,
            ),
          const SizedBox(width: 6), // Space between avatar and message bubble

          // Message Bubble
          Container(
            constraints: BoxConstraints(
              minWidth: MediaQuery.of(context).size.width * 0.25,
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isBot
                    ? [Colors.blue.shade900, Colors.blue.shade700] // Bot message gradient
                    : [Colors.blue.shade300, Colors.blue.shade50], // New user message color
                begin: Alignment.topLeft,
                end: Alignment.bottomRight
              ),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(12),
                topRight: const Radius.circular(12),
                bottomLeft: Radius.circular(isBot ? 0 : 12),
                bottomRight: Radius.circular(isBot ? 12 : 0),
              ),
            ),
            child: IntrinsicWidth(  // To adjust the message bubble according to the text
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      color: isBot ? Colors.white : Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      '${timestamp.hour}:${timestamp.minute}',
                      style: TextStyle(
                        color: isBot ? Colors.white70 : Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
