import 'optionModel.dart';

class BotNode {
  final String? nodeName;   // Name of node("Greeting")
  final String? intent;   // keyword for the question which can be further used
  final String? type;   // type of node(radio , label , checkbox , multimedia , navigate)
  final String? botMessage;   // the message to be shown on UI by the Bot
  final String? description;
  final String? image; // For images from any server
  final String? checkboxOptionTTs;    // the tts will be triggered when the next button of checkbox is clicked
  late final List<Option>? options;   // options of the node
  final String? nextNode;   // to be defined for each option of radio node and for checkbox node once

  BotNode({
    this.nodeName,
    this.intent,
    this.type,
    this.botMessage,
    this.description,
    this.image,
    this.checkboxOptionTTs,
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
      image: json['image'] as String?,
      checkboxOptionTTs: json['checkboxOptionTTs'] as String?, // Make sure the JSON field matches
      options: (json['options'] as List?)
          ?.map((option) => Option.fromJson(option as Map<String, dynamic>))
          .toList(),
      nextNode: json['nextNode'] as String?,
    );
  }
}