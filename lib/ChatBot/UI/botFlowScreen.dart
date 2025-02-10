import 'dart:async';
import 'dart:io';
import 'package:flow_bot_json_driven_chat_bot/ChatBot/UI/videoCapture.dart';
import 'package:flutter/material.dart';
import '../APIs/uploadFile.dart';
import '../Model/nodeModel.dart';
import '../Model/optionModel.dart';
import '../botParser.dart';
import 'CustomCarousel.dart';
import 'VideoPlayer.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'audioPlayer.dart';
import 'imageCapture.dart';

class BotFlowScreen extends StatefulWidget {
  final String jsonFileName;
  final bool fromServer;

  BotFlowScreen({
    required this.jsonFileName,
    required this.fromServer
  });
  @override
  _BotFlowScreenState createState() => _BotFlowScreenState();
}

class _BotFlowScreenState extends State<BotFlowScreen> {
  late final String jsonFileName = widget.jsonFileName;
  String currentNodeKey = 'Load Bot';
  late final String botType;
  late final String botName;
  late final String botImage;

  // Storing the intent and answer of the flow
  Map<String, List<String>> intentAnswer = {};

  // Map in which the whole json file after parsing will be stored
  Map<String, BotNode>? botFlow;

  // List in which the selected option/options will be stored after each node execution
  List<String> selectedOptions = [];

  // To store chat messages which will be shown to UI
  List<Map<String, String>> messages = [];

  final ScrollController _scrollController = ScrollController();
  final FlutterTts _flutterTts = FlutterTts();
  bool showOptions = false;  // Will be used when to show the options and when to hide on the UI

  // For multimedia files to be stored
  List<File> capturedImages = [];
  List<File> capturedVideo = [];

  // map in which the url of the captured media will be stored in below format
  // Images : ['url1' , 'url2' , ...] , Video : url , Audio : url ,
  Map<String, dynamic> uploadedFiles = {};
  bool anyFileCaptured = false; // Checks whether any file is uploaded or not

  @override
  void initState() {
    super.initState();
    _loadBotFlow();

    // configure TTs
    _flutterTts.setLanguage("en-IN");
    _flutterTts.setPitch(0.8);
    _flutterTts.setSpeechRate(0.5);
  }

  // Load the bot flow data
  void _loadBotFlow() async {
    try {
      String startMessage = '';
      if(widget.fromServer) {
        botFlow = await BotParser.loadBotFlowFromServer(jsonFileName);
      }
      else {
        botFlow = await BotParser.loadBotFlowFromAssets(jsonFileName);
      }
      if (botFlow != null && botFlow!.containsKey(currentNodeKey)) {
        botType = botFlow?[currentNodeKey]!.type ?? '';
        botImage = botFlow?[currentNodeKey]!.image ?? '';
        botName = botFlow?[currentNodeKey]!.description ?? '';
        currentNodeKey = botFlow?[currentNodeKey]!.nextNode ?? '';
        startMessage = botFlow?[currentNodeKey]!.botMessage ?? '';
        List<String> words = startMessage.split(' ');
        String displayedMessage = '';

        setState(() {
          messages.add({
            'type': 'bot',
            'text': '',
          });
          _speak(startMessage);
        });
        for(String word in words) {
          await Future.delayed(const Duration(milliseconds: 200));
          displayedMessage += '$word ';
          setState(() {
            messages[messages.length - 1]['text'] = displayedMessage;
          });
        }
        showOptions = true;
      } else {
        print(
            "Error: Bot flow data is not available or does not contain the key '$currentNodeKey'.");
      }
    } catch (e) {
      print("Error loading bot flow: $e");
    }
  }

  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    if (botFlow == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final currentNode = botFlow![currentNodeKey];

    if (currentNode == null) {
      return Scaffold(
          body: Center(
              child: Text("Error: Current node '$currentNodeKey' not found.")));
    }

    return Scaffold(
      appBar: AppBar(
          backgroundColor: const Color(0xFFAB2138),
          title: Text(botType, // nodeName
              style: const TextStyle(color: Colors.white))),
      body: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.all(8.0),
        children: [
          // Bot Avatar and Name at the top of the scrollable view
          Column(
            children: [
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 50, // Adjust the size of the avatar
                backgroundImage: NetworkImage(botImage), // Your bot image path
                backgroundColor: const Color(0xFFAB2138),
              ),
              const SizedBox(height: 10),
              Text(
                botName, // Bot name under the avatar (nodeName.description)
                style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
          // Show messages (from the bot and user)
          ...messages.map((message) {
            final isBot = message['type'] == 'bot';
            return Align(
              alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
              child: Column(
                children: [
                  if (isBot) const SizedBox(height: 40),
                  Stack(
                    clipBehavior: Clip
                        .none, // Allows overlapping outside the Stack bounds
                    children: [
                      // Message Bubble
                      Row(
                        mainAxisAlignment: isBot
                            ? MainAxisAlignment.start
                            : MainAxisAlignment.end,
                        children: [
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 19.0, vertical: 10.0),
                              margin: const EdgeInsets.only(
                                  top: 10.0), // Small margin for spacing
                              decoration: BoxDecoration(
                                color: isBot
                                    ? Colors.white
                                    : const Color(0xFFAB2138),
                                borderRadius: BorderRadius.circular(16),
                                border: isBot
                                    ? Border.all(
                                    color: Colors.black, width: 1.5)
                                    : null,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black
                                        .withOpacity(0.2), // Shadow color
                                    offset: const Offset(
                                        2, 4), // Offset in X and Y direction
                                    blurRadius: 4, // Spread of the shadow
                                    spreadRadius: 1, // Intensity of the shadow
                                  ),
                                ],
                              ),
                              child: Text(
                                message['text'] ?? '',
                                style: TextStyle(
                                    color:
                                    isBot ? Colors.black87 : Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Bot Avatar
                      if (isBot)
                        Positioned(
                          left: -5, // Adjust for horizontal overlap
                          top: -24, // Adjust for vertical overlap
                          child: CircleAvatar(
                            radius: 16,
                            backgroundImage: NetworkImage(botImage),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),

          // Display the current node (bot options or content)
          // if (currentNode != null)
          //   _buildBotNode(currentNode),
          // if(count == 0)
          _buildBotNode(currentNode),
        ],
      ),
    );
  }

  // Handle option selection
  Future<void> _onOptionSelected(String? nextNodeKey, String? optionAudio,
      [bool? showMessage, List<String>? apiInfo])  async {
    // for showMessage true reflect the response on the ui and if false then store it
    // ApiInfo is a list ['type(book ticket , dispose Appliance , etc)' , 'apiUrl' , 'keywords to be searched']

    // Updation of UI for the user's response
    setState(() {
      showOptions = false;
      for (String options in selectedOptions) {
        messages.add({'type': 'user', 'text': options});
      }

      // Add intent and options in intentAnswer
      final String? intent = botFlow?[currentNodeKey]?.intent;
      if(intent != null) {
        // If the intent already exists then add the selectedOptions to that existing intent
        if(intentAnswer.containsKey(intent)) {
          intentAnswer[intent]?.addAll(selectedOptions);
        }
        // Else create a new entry in intentAnswer
        else {
          intentAnswer[intent] = List.from(selectedOptions);
        }
      }

      selectedOptions = [];
    });


    if ((optionAudio != null && optionAudio != '')) {
      _speak(optionAudio);
    }

    setState(() {
      messages.add({'type': 'bot', 'text': '...'});
    });
    await Future.delayed(Duration(milliseconds: 3000));

    // Navigate to the next node
    if (nextNodeKey != null) {
      currentNodeKey = nextNodeKey;
      final currentNode = botFlow![currentNodeKey];

      if (currentNode != null) {
        String botMessage = currentNode.botMessage ?? '';

        // Display bot message word by word
        List<String> words = botMessage.split(' ');
        String displayedMessage = '';

        // Start the speaking task and typing animation
        _speak(botMessage);

        for(String word in words) {
          await Future.delayed(const Duration(milliseconds: 200));
          displayedMessage += '$word ';
          setState(() {
            messages[messages.length - 1]['text'] = displayedMessage;
          });
        }

        // Once the message is fully displayed, show the options for the new node
        setState(() {
          messages[messages.length - 1]['text'] = botMessage;
          showOptions = true;
        });
      }
    }
  }

  String _completeApiRequest(List<String> apiInfo) {
    String result = '';
    String apiUrl = apiInfo[1];
    switch (apiInfo[0]) {
      case 'Create_order':
      case 'Order_status':
      case 'Find_deal':
      case 'Dispose_Appliance':
      case 'Book_Ticket':
    }
    return result;
  }

  // Build dynamic bot node based on type
  Widget _buildBotNode(BotNode node) {
    if(!showOptions) {
      return const SizedBox.shrink();
    }
    switch (node.type) {
      case 'navigate':
        return _buildNavigatorNode(node);
      case 'label':
        return _buildLabelNode(node);
      case 'productNameSelection':
        return _buildProductNameSelectionNode(node);
      case 'variantNameSelection':
        return _buildVariantNameSelection(node);
      case 'radioType1':
        return _buildRadioNode1(node);
      case 'radioType2':
        return _buildRadioNode2(node);
      case 'checkboxType1':
        return _buildCheckboxNode1(node);
      case 'checkboxType2':
        return _buildCheckboxNode2(node);
      case 'checkboxWithPopUp':
        return _buildCheckboxNodeWithPopUp(node);
      case 'multimedia':
        return _buildMultiMediaNode(node);
      default:
        return const Text('Unknown node type');
    }
  }

  // Build navigator node for page navigation
  Widget _buildNavigatorNode(BotNode node) {
    // Automatically navigate to the target page when this node is triggered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (node.nodeName != null) {
        Navigator.pushNamed(
          context,
          node.nodeName!,
          arguments: messages,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Target page not defined for this node.')));
      }
    });
    return const SizedBox.shrink();
  }

  // Build label node (simple text)
  Widget _buildLabelNode(BotNode node) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        if (node.nextNode != null)
          ElevatedButton(
            onPressed: () => _onOptionSelected(node.nextNode, ''),
            child: const Text('Next'),
          ),
      ],
    );
  }

  // Node for product name selection
  Widget _buildProductNameSelectionNode(BotNode node) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Wrap(
          spacing: 8.0, // Space between buttons horizontally
          runSpacing: 8.0, // Space between buttons vertically
          children: node.options!.map((option) {
            // Each option is clickable like a radio button
            return GestureDetector(
              onTap: () {
                selectedOptions.add(option.value!);
                _onOptionSelected(option.nextNode, option.radioOptionTTs);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 15.0,
                    vertical: 8.0), // Padding inside the button
                decoration: BoxDecoration(
                  color: Colors.white, // Highlight when selected
                  borderRadius: BorderRadius.circular(18.0), // Rounded corners
                  border: Border.all(
                    color: const Color(
                        0xFFAB2138), // Border color changes on selection
                    width: 2.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2), // Shadow color
                      offset: const Offset(2, 4), // Offset in X and Y direction
                      blurRadius: 4, // Spread of the shadow
                      spreadRadius: 1, // Intensity of the shadow
                    ),
                  ],
                ),
                child: Text(
                  option.label ?? 'No Label',
                  style: const TextStyle(fontSize: 14.0, color: Colors.black
                    // Color(0xFFAB2138), // Change text color when selected
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Node for variant selection
  Widget _buildVariantNameSelection(BotNode node) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Wrap(
          spacing: 8.0, // Space between buttons horizontally
          runSpacing: 8.0, // Space between buttons vertically
          children: node.options!.map((option) {
            // Each option is clickable like a radio button
            return GestureDetector(
              onTap: () {
                selectedOptions.add(option.value!);
                _onOptionSelected(option.nextNode, option.radioOptionTTs);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 15.0,
                    vertical: 8.0), // Padding inside the button
                decoration: BoxDecoration(
                  color: Colors.white, // Highlight when selected
                  borderRadius: BorderRadius.circular(18.0), // Rounded corners
                  border: Border.all(
                    color: const Color(
                        0xFFAB2138), // Border color changes on selection
                    width: 2.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2), // Shadow color
                      offset: const Offset(2, 4), // Offset in X and Y direction
                      blurRadius: 4, // Spread of the shadow
                      spreadRadius: 1, // Intensity of the shadow
                    ),
                  ],
                ),
                child: Text(
                  option.label ?? 'No Label',
                  style: const TextStyle(fontSize: 14.0, color: Colors.black
                    // Color(0xFFAB2138), // Change text color when selected
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Build radio node of Type1(single choice)
  Widget _buildRadioNode1(BotNode node) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: node.options!.map((option) {
          final isSelected = selectedOptions.contains(option.value);

          return Padding(
            padding: const EdgeInsets.symmetric(
                vertical: 4.0), // Add vertical space between options
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Show images above the button if they exist
                if (option.images != null &&
                    option.images!.isNotEmpty &&
                    option.images!.length > 1)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: CarouselSliderWidget(
                      imageUrls: option.images!,
                    ),
                  ),

                // if(option.images != null && option.images!.isNotEmpty && option.images!.length == 1)
                //  Single image case to be completed

                // Display audio player if audio is available
                if (option.audioClip != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: AudioPlayerWidget(audioUrl: option.audioClip!),
                  ),

                // Display video player if video is available
                if (option.video != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: VideoPlayerWidget(videoUrl: option.video!),
                  ),

                // Radio button option
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(),
                    child: GestureDetector(
                      onTap: () {
                        selectedOptions.add(option.value!);
                        if (option.apiCall != null &&
                            option.apiCall!.isNotEmpty) {
                          _onOptionSelected(option.nextNode,
                              option.radioOptionTTs, false, option.apiCall);
                        } else if (option.showApiMessage != null &&
                            option.showApiMessage!.isNotEmpty) {
                          _onOptionSelected(option.nextNode,
                              option.radioOptionTTs, true, option.apiCall);
                        } else {
                          _onOptionSelected(option.nextNode,
                              option.radioOptionTTs);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15.0, vertical: 8.0),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blueAccent : Colors.white,
                          borderRadius: BorderRadius.circular(18.0),
                          border: Border.all(
                            color: const Color(0xFFAB2138),
                            // isSelected ? Colors.blueAccent : Colors.grey,
                            width: 2.0,
                          ),
                        ),
                        child: Text(
                          option.label ?? 'No Label',
                          style: const TextStyle(
                            fontSize: 14.0,
                            color: Color(0xFFAB2138),
                            // isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // Build radio node of Type2(single choice)
  Widget _buildRadioNode2(BotNode node) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Wrap(
          spacing: 8.0, // Space between buttons horizontally
          runSpacing: 8.0, // Space between buttons vertically
          children: node.options!.map((option) {
            // Each option is clickable like a radio button
            return GestureDetector(
              onTap: () {
                selectedOptions.add(option.value!);
                _onOptionSelected(
                    option.nextNode, option.radioOptionTTs);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 15.0,
                    vertical: 8.0), // Padding inside the button
                decoration: BoxDecoration(
                  color: Colors.white, // Highlight when selected
                  borderRadius: BorderRadius.circular(18.0), // Rounded corners
                  border: Border.all(
                    color: const Color(
                        0xFFAB2138), // Border color changes on selection
                    width: 2.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2), // Shadow color
                      offset: const Offset(2, 4),
                      // Offset in X and Y direction
                      blurRadius: 4, // Spread of the shadow
                      spreadRadius: 1, // Intensity of the shadow
                    ),
                  ],
                ),
                child: Text(
                  option.label ?? 'No Label',
                  style: const TextStyle(fontSize: 14.0, color: Colors.black
                    // Color(0xFFAB2138), // Change text color when selected
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Build checkbox node (multiple choice)
  Widget _buildCheckboxNode1(BotNode node) {
    return SingleChildScrollView(
      // Makes the content scrollable
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          // Iterate through the options and build checkboxes for each
          ...node.options!.map((option) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: _buildCheckboxOption1(option),
            );
          }).toList(),

          // Display "Next" button if there's a next node available
          if (node.nextNode != null)
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () => _onOptionSelected(node.nextNode, node.checkboxOptionTTs),
                  child: const Text('Next'),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCheckboxOption1(Option option) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and Checkbox
              CheckboxListTile(
                title: Text(
                  option.label ?? 'No Label',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                contentPadding: const EdgeInsets.fromLTRB(10, 10, 20, 0),
                value: selectedOptions.contains(option.value),
                activeColor: const Color(0xFFAB2138),
                // tileColor: Color(0xFFAB2138),
                selectedTileColor: const Color(0xFFAB2138),
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (bool? value) {
                  setState(() {
                    if (value != null && value) {
                      selectedOptions.add(option.value ?? '');
                    } else {
                      selectedOptions.remove(option.value);
                    }
                  });
                },
              ),

              // Display images if available
              if (option.images != null && option.images!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: CarouselSliderWidget(
                    imageUrls: option.images!
                  ),
                ),

              // Display audio player if available
              if (option.audioClip != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: AudioPlayerWidget(audioUrl: option.audioClip!),
                ),

              // Display video player if available
              if (option.video != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: VideoPlayerWidget(videoUrl: option.video!),
                ),

              // Subtitle displayed below attachments
              if (option.description != null && option.description!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                  child: Text(
                    option.description!,
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

// Build checkbox node (multiple choice)
  Widget _buildCheckboxNode2(BotNode node) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          // Build each checkbox option as a card
          ...node.options!.map((option) {
            return _buildCheckboxOption2(option);
          }).toList(),
          // Display "Next" button if there's a next node available
          if (node.nextNode != null)
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () => _onOptionSelected(node.nextNode, node.checkboxOptionTTs),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFAB2138),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 12.0),
                  ),
                  child: const Text(
                    'Next',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        backgroundColor: Color(0xFFAB2138)),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCheckboxOption2(Option option) {
    return StatefulBuilder(
      builder: (context, setState) {
        final isSelected = selectedOptions.contains(option.value);

        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: GestureDetector(
            onTap: () {
              setState(() {
                if (isSelected) {
                  selectedOptions.remove(option.value);
                } else {
                  selectedOptions.add(option.value ?? '');
                }
              });
            },
            child: Card(
              elevation: 4,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
                side: BorderSide(
                  color: isSelected ? const Color(0xFFAB2138) : Colors.white,
                  width: 2,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Checkbox Icon with Label and Description
                    Row(
                      children: [
                        Icon(
                          isSelected ? Icons.check_circle : Icons.check_circle,
                          color: isSelected
                              ? const Color(0xFFAB2138)
                              : Colors.grey.shade300,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                option.label ?? 'No Label',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (option.description != null &&
                                  option.description!.isNotEmpty)
                                Text(
                                  option.description!,
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 14,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Multimedia Section
                    if ((option.images != null && option.images!.isNotEmpty) ||
                        option.audioClip != null ||
                        option.video != null)
                      Column(
                        children: [
                          if (option.images != null &&
                              option.images!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: CarouselSliderWidget(
                                imageUrls: option.images!
                              ),
                            ),
                          if (option.audioClip != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: AudioPlayerWidget(
                                  audioUrl: option.audioClip!),
                            ),
                          if (option.video != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: VideoPlayerWidget(videoUrl: option.video!),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Build checkbox node (multiple choice)
  Widget _buildCheckboxNodeWithPopUp(BotNode node) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          // Build each checkbox option as a card
          ...node.options!.map((option) {
            return _buildCheckboxWithPopUpOption(option);
          }).toList(),
          // Display "Next" button if there's a next node available
          if (node.nextNode != null)
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () => _onOptionSelected(node.nextNode, node.checkboxOptionTTs),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFAB2138),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 12.0),
                  ),
                  child: const Text(
                    'Next',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        backgroundColor: Color(0xFFAB2138)),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCheckboxWithPopUpOption(Option option) {
    return StatefulBuilder(
      builder: (context, setState) {
        final isSelected = selectedOptions.contains(option.value);

        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: GestureDetector(
            onTap: () {
              setState(() {
                if (isSelected) {
                  selectedOptions.remove(option.value);
                } else {
                  selectedOptions.add(option.value ?? '');
                }
              });
            },
            child: Card(
              elevation: 4,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
                side: BorderSide(
                  color: isSelected ? const Color(0xFFAB2138) : Colors.white,
                  width: 2,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Checkbox Icon with Label and Description
                    Row(
                      children: [
                        Icon(
                          isSelected ? Icons.check_circle : Icons.check_circle,
                          color: isSelected
                              ? const Color(0xFFAB2138)
                              : Colors.grey.shade300,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                option.label ?? 'No Label',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Multimedia Section
                    if ((option.images != null && option.images!.isNotEmpty) ||
                        option.audioClip != null ||
                        option.video != null)
                      GestureDetector(
                        onTap: () => showDialog(
                          context: context,
                          builder: (context) {
                            return Dialog(
                              backgroundColor: Colors
                                  .transparent, // Make background transparent
                              child: Stack(
                                children: [
                                  // Full-Screen Popup Content
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 16.0, vertical: 24.0),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    child: SingleChildScrollView(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          // Description
                                          Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Text(
                                              option.description ??
                                                  'No description available.',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 20),

                                          // Multimedia Content
                                          if (option.images != null &&
                                              option.images!.isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 8.0),
                                              child: CarouselSliderWidget(
                                                imageUrls: option.images!
                                              ),
                                            ),
                                          if (option.audioClip != null)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 16.0),
                                              child: AudioPlayerWidget(
                                                  audioUrl: option.audioClip!),
                                            ),
                                          if (option.video != null)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 16.0),
                                              child: VideoPlayerWidget(
                                                  videoUrl: option.video!),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Close Button
                                  Positioned(
                                    top: 10,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: () => Navigator.of(context).pop(),
                                      child: const CircleAvatar(
                                        backgroundColor: Colors.white,
                                        child: Icon(
                                          Icons.close,
                                          color: Color(0xFFAB2138),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        child: const Text(
                          'View More>',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Build Multimedia Node for recording audio, video and capturing images
  Widget _buildMultiMediaNode(BotNode node) {
    return SingleChildScrollView(
      // Makes the content scrollable
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handling Options
          if (node.options != null)
            for (Option option in node.options!) _buildMultimediaOption(option),

          // Next button
          if (node.nextNode != null)
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () async {
                    await _uploadMultimediaFiles();
                    anyFileCaptured == true
                        ? selectedOptions.add("File upload Successfully")
                        : selectedOptions.add("No Files Uploaded");
                    _onOptionSelected(node.nextNode, node.checkboxOptionTTs);
                  },
                  child: const Text('Next'),
                ),
              ),
            )
        ],
      ),
    );
  }

  // Build the required Options for Multimedia Node
  Widget _buildMultimediaOption(Option option) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (option.recordVideo != null && option.value == "Yes")
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: VideoCaptureWidget(
                    label: option.recordVideo!, capturedVideo: capturedVideo),
              ),
            if (option.clickPhoto != null && option.value == "Yes")
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ImageCaptureWidget(
                    capturedImages: capturedImages),
              )
          ],
        );
      },
    );
  }

  // Parses each files in capturedImages[] , capturedOcrImages[] , video , audio and uploads it
  Future<void> _uploadMultimediaFiles() async {
    // Upload images if present
    if (capturedImages.isNotEmpty) {
      anyFileCaptured = true;
      for (File image in capturedImages) {
        String? imageUrl = await uploadMediaToServer(image, "image/jpeg");
        if (imageUrl != null) {
          uploadedFiles.putIfAbsent("Images", () => []);
          uploadedFiles["Images"]?.add(imageUrl);
        }
      }
    }
    // Upload video if present
    if (capturedVideo.isNotEmpty) {
      anyFileCaptured = true;
      String? videoUrl =
      await uploadMediaToServer(capturedVideo[0], "video/mp4");
      if (videoUrl != null) {
        uploadedFiles.putIfAbsent("Video", () => []);
        uploadedFiles["Video"]?.add(videoUrl);
      }
    }
  }
}
