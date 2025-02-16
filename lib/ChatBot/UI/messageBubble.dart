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
    return Align(
      alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75, // Limit bubble width
        ),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: isBot
              ? [Colors.blue.shade900, Colors.blue.shade700]
              : [Colors.white, Colors.grey.shade100]
          ),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: Radius.circular(isBot ? 0 : 12),
            bottomRight: Radius.circular(isBot ? 12 : 0),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: TextStyle(
                color: !isBot ? Colors.black87 : Colors.white,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4), // Spacing between text and timestamp
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                '${timestamp.hour}:${timestamp.minute}',
                style: TextStyle(
                  color: !isBot ? Colors.black54 : Colors.white70,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
