import 'dart:convert';
import 'package:flutter/services.dart';
import 'Model/nodeModel.dart';
import 'package:http/http.dart' as http;

class BotParser {
  // Function that fetches the bot data from the specified file in assets folder
  static Future<Map<String, BotNode>> loadBotFlowFromAssets(String fileName) async {
    try {
      final String response = await rootBundle.loadString('assets/$fileName');
      final Map<String, dynamic> data = jsonDecode(response);
      return data
          .map((key, value) => MapEntry(key, BotNode.fromJson(key, value)));
    }
    catch(e) {
      throw Exception('Error fetching bot flow: $e');
    }
  }

  // Function that fetches the bot data from the specified link of the json file from any server
  static Future<Map<String, BotNode>> loadBotFlowFromServer(String url) async {
    try {
      // Make the HTTP GET request to fetch the JSON file
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Parse the response body as JSON
        final Map<String, dynamic> data = jsonDecode(response.body);

        // Convert JSON data to BotNode objects
        return data
            .map((key, value) => MapEntry(key, BotNode.fromJson(key, value)));
      } else {
        throw Exception('Failed to load bot flow: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching bot flow: $e');
    }
  }
}