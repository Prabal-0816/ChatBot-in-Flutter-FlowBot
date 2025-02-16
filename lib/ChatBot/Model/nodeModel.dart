import 'optionModel.dart';

class BotNode {
  final String? nodeName;   // Name of node("Greeting")
  final String? intent;   // keyword for the question which can be further used
  final String? type;   // type of node(radio , label , checkbox , multimedia , navigate)
  final String? botMessage;   // the message to be shown on UI by the Bot
  final String? description;  // Just used for bot
  final List<String>? image; // image urls, also used for bot image (This is used for common images for all options in any case)
  final String? triggerTTs;    // the tts will be triggered when the next button of checkbox is clicked
  late final List<Option>? options;   // options of the node
  final String? nextNode;   // mandatory for each checkbox type node, multimedia node

  BotNode({
    this.nodeName,
    this.intent,
    this.type,
    this.botMessage,
    this.description,
    this.image,
    this.triggerTTs,
    this.options,
    this.nextNode,
  });

  // Factory method to parse from JSON
  factory BotNode.fromJson(String key ,Map<String, dynamic> json) {
    return BotNode(
      nodeName: key,
      intent: json['intent'] as String?,
      type: json['type'] as String?,
      botMessage: json['botMessage'] as String?,
      description: json['description'] as String?,
      image: (json['image'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      triggerTTs: json['triggerTTs'] as String?, // Make sure the JSON field matches
      options: (json['options'] as List?)
          ?.map((option) => Option.fromJson(option as Map<String, dynamic>))
          .toList(),
      nextNode: json['nextNode'] as String?,
    );
  }
}