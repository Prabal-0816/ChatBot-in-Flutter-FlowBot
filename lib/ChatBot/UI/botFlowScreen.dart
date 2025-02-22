import 'dart:async';
import 'dart:io';
import 'package:flow_bot_json_driven_chat_bot/ChatBot/UI/animatedMessageBubble.dart';
import 'package:flow_bot_json_driven_chat_bot/ChatBot/UI/audioCapture.dart';
import 'package:flow_bot_json_driven_chat_bot/ChatBot/UI/messageBubble.dart';
import 'package:flow_bot_json_driven_chat_bot/ChatBot/UI/thinkingAnimation.dart';
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
import 'multimediaPage.dart';

class BotFlowScreen extends StatefulWidget {
  final String jsonFileName;

  BotFlowScreen({required this.jsonFileName});

  @override
  _BotFlowScreenState createState() => _BotFlowScreenState();
}

class _BotFlowScreenState extends State<BotFlowScreen> {
  String currentNodeKey = 'Load Bot';
  late final String botType;
  late final String botName;
  late final String botImage;
  bool isServerLink = false;

  // Storing the intent and answer of the flow
  Map<String, List<String>> intentAnswer = {};

  // Map in which the whole json file after parsing will be stored
  Map<String, BotNode>? botFlow;

  // List in which the selected option/options will be stored after each node execution
  List<String> selectedOptions = [];

  // To store chat messages which will be shown to UI
  List<Map<String, dynamic>> messages = [];

  late ScrollController _scrollController;
  final FlutterTts _flutterTts = FlutterTts();
  bool showOptions = false;  // Will be used when to show the options and when to hide on the UI

  // For multimedia files to be stored
  List<File> capturedImages = [];
  List<File> capturedVideo = [];
  List<File> capturedAudio = [];

  // map in which the url of the captured media will be stored in below format
  // Images : ['url1' , 'url2' , ...] , Video : url , Audio : url ,
  Map<String, dynamic> uploadedFiles = {};
  bool anyFileCaptured = false; // Checks whether any file is uploaded or not

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _loadBotFlow();
    isServerLink = widget.jsonFileName.contains('.http') || widget.jsonFileName.contains('.com');

    // configure TTs
    _flutterTts.setLanguage("en-IN");
    _flutterTts.setPitch(0.8);
    _flutterTts.setSpeechRate(0.5);
  }

  // Use in case the options are less than the screen size
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Use in case the options occupy more space than the screen
  void _scrollToMessage() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        final double maxScroll = _scrollController.position.maxScrollExtent;
        final double viewportHeight = _scrollController.position.viewportDimension;

        //  If the content height is greater than the screen size, scroll 1/3rd
        final double offset = maxScroll > viewportHeight ? maxScroll / 1.5 : maxScroll;
        _scrollController.animateTo(
          offset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _displayBotMessage(String message) async {
    List<String> words = message.split(' ');
    String displayedMessage = '';

    // Start the speaking task and typing animation
    _speak(message);

    for(String word in words){
      await Future.delayed(const Duration(milliseconds: 200));
      displayedMessage += '$word ';
      setState(() {
        messages[messages.length - 1]['text'] = displayedMessage;
        _scrollToBottom();
      });
    }

    await Future.delayed(const Duration(seconds: 1));

    // Once the message is fully displayed, show the options for the current node
    setState(() {
      messages[messages.length - 1]['text'] = message;
      showOptions = true;
      _scrollToBottom();
    });
  }

  // Load the bot flow data
  void _loadBotFlow() async {
    try {
      String startMessage = '';
      if(isServerLink) {
        botFlow = await BotParser.loadBotFlowFromServer(widget.jsonFileName);
      }
      else {
        botFlow = await BotParser.loadBotFlowFromAssets(widget.jsonFileName);
      }
      if (botFlow != null && botFlow!.containsKey(currentNodeKey)) {
        botType = botFlow?[currentNodeKey]!.type ?? '';
        botImage = botFlow?[currentNodeKey]!.image?[0] ?? ''; // there will only be one image in the list
        botName = botFlow?[currentNodeKey]!.description ?? '';
        currentNodeKey = botFlow?[currentNodeKey]!.nextNode ?? '';
        startMessage = botFlow?[currentNodeKey]!.botMessage ?? '';

        setState(() {
          messages.add({
            'type': 'bot',
            'text': '',
            'timestamp' : DateTime.now()
          });
          _speak(startMessage);
        });

        _displayBotMessage(startMessage);   // Displaying the start message
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
          title: Text(botType)  // Bot Type
      ),
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
                backgroundColor: Colors.blue.shade900,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50.0),
                    border: Border.all(
                      color: Colors.blue.shade900,
                      width: 2.0,
                    ),
                  ),
                ),
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
            return MessageBubble(
              text: message['text'] ?? '',
              isBot: isBot,
              botImage: botImage,
              timestamp: message['timestamp'] ?? DateTime.now(),
            );
          }).toList(),
          if(currentNode.image != null) _showImage(currentNode),
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
    String userReply = '';
    if(selectedOptions.isNotEmpty) {
      if(selectedOptions.length == 1) {
        userReply = selectedOptions[0];
      }
      else {
        userReply = "${selectedOptions.sublist(0 , selectedOptions.length - 1).join(', ')} "
            "and ${selectedOptions.last}";
      }
    }

    setState(() {
      showOptions = false;
      if(userReply != '') {
        messages.add({
          'type': 'user',
          'text': userReply,
          'timestamp': DateTime.now()
        });
      }
      _scrollToBottom();

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

    int len = 0;
    if ((optionAudio != null && optionAudio != '')) {
      len = optionAudio.length;
      _speak(optionAudio);
    }

    setState(() {
      messages.add({
        'type': 'bot',
        'text': '',
        'timestamp': DateTime.now()
      });
    });

    await Future.delayed(Duration(milliseconds: len == 0 ? 1500 : len * 100));

    // Navigate to the next node
    if (nextNodeKey != null) {
      currentNodeKey = nextNodeKey;
      final currentNode = botFlow![currentNodeKey];

      if (currentNode != null) {
        String botMessage = currentNode.botMessage ?? '';
        await _displayBotMessage(botMessage);
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

  // For Nodes which have common images in that the images will appear before all the options
  // Like for radio node 'is this an image of cat or a dog': image with option 'cat' and 'dog'
  Widget _showImage(BotNode node) {
    if(!showOptions) {
      return const SizedBox.shrink();
    }
    // List<String> images = node.image!;
    return CarouselSliderWidget(imageUrls: node.image! , layoverData: node.layoverData ?? []);
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
      case 'labelWithNext':
        return _buildLabelNodeWithNext(node);
      case 'radioTypeWithAttachments':
        return _buildRadioNodeWithAttachments(node);
      case 'radioTypeWithTextOnly':
        return _buildRadioNodeWithTextOnly(node);
      case 'checkbox':
        return _buildCheckbox(node);
      case 'checkboxInRowView':
        return _buildCheckboxRowView(node);
      case 'checkboxInGridView':
        return _buildCheckboxGridView(node);
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
    if(node.nextNode != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _onOptionSelected(node.nextNode, node.triggerTTs); // Automatically call _onOptionSelected
      });
    }

    return const SizedBox.shrink(); // No UI needed for label node
  }

  // label node with next button
  Widget _buildLabelNodeWithNext(BotNode node) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        if (node.nextNode != null)
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                onPressed: () => _onOptionSelected(node.nextNode, node.triggerTTs),
                child: const Text(
                    'Next', style: TextStyle(color: Colors.white)
                ),
              ),
            ),
          ),
      ],
    );
  }


  // Build radio node of Type1(single choice)
  Widget _buildRadioNodeWithAttachments(BotNode node) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: node.options!.map((option) {
          final isSelected = selectedOptions.contains(option.value);

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0), // Add vertical space between options
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Show images above the button if they exist
                if (option.images != null && option.images!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: CarouselSliderWidget(
                      imageUrls: option.images!,
                      layoverData: option.layoverData ?? [],
                    ),
                  ),

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
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18.0),
                          border: Border.all(
                            color: Colors.blue.shade900,
                            width: 2.0,
                          ),
                        ),
                        child: Text(
                          option.label ?? 'No Label',
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.blue.shade900, // Matches theme
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
  Widget _buildRadioNodeWithTextOnly(BotNode node) {
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
                    horizontal: 14.0,
                    vertical: 8.0), // Padding inside the button
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18.0), // Rounded corners
                  border: Border.all(
                    color: Colors.blue.shade900, // Border color changes on selection
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
                  style:  TextStyle(fontSize: 16.0, color: Colors.blue.shade900
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }


// Build checkbox node (multiple choice) card contains the attachments along with it
  Widget _buildCheckbox(BotNode node) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          // Build each checkbox option as a card
          ...node.options!.map((option) {
            return _buildCheckboxOptions(option);
          }).toList(),
          // Display "Next" button if there's a next node available
          if (node.nextNode != null)
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () => _onOptionSelected(node.nextNode, node.triggerTTs),
                  child: const Text(
                    'Next', style: TextStyle(color: Colors.white)
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCheckboxOptions(Option option) {
    return StatefulBuilder(
      builder: (context, setState) {
        final isSelected = selectedOptions.contains(option.value);

        return Padding(
          padding: const EdgeInsets.only(bottom: 0),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
                side: BorderSide(
                  color: isSelected ? Colors.blue.shade900 : Colors.blue.shade50,
                  width: 3,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Colors.blue.shade50, Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(       // Checkbox Icon with Label and Description
                            Icons.check_circle,
                            size: 30,
                            color: isSelected
                                ? Colors.blue.shade900
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
                                    color: Colors.black87,
                                    fontSize: 16,
                                  ),
                                ),
                                if (option.description != null &&
                                    option.description!.isNotEmpty)
                                  const SizedBox(height: 4),
                                if (option.description != null &&
                                    option.description!.isNotEmpty)
                                  Text(
                                    option.description!,
                                    style: const TextStyle(
                                      color: Colors.black54,
                                      fontSize: 14,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // Multimedia Section
                      if ((option.images != null && option.images!.isNotEmpty) ||
                          option.audioClip != null ||
                          option.video != null)
                        const SizedBox(height: 12),
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
          ),
        );
      },
    );
  }


  // Build checkbox node (multiple choice) card in row view with view more options to see all multimedia
  Widget _buildCheckboxRowView(BotNode node) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          // Build each checkbox option as a card
          ...node.options!.map((option) {
            return _buildCheckboxRowViewOption(option);
          }).toList(),
          // Display "Next" button if there's a next node available
          if (node.nextNode != null)
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                    onPressed: () => _onOptionSelected(node.nextNode, node.triggerTTs),
                    child:  const Text('Next' , style: TextStyle(color: Colors.white))
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCheckboxRowViewOption(Option option) {
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
                borderRadius: BorderRadius.circular(16.0),
                side: BorderSide(
                  color: isSelected ? Colors.blue.shade900 : Colors.blue.shade50,
                  width: 3,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade50, Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16.0)
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
                            Icons.check_circle,
                            size: 30,
                            color: isSelected
                                ? Colors.blue.shade900
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
                                    color: Colors.black87,
                                    fontSize: 16,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      if ((option.images != null && option.images!.isNotEmpty) ||
                          option.audioClip != null ||
                          option.video != null)
                        const SizedBox(height: 12),
                      // Multimedia Section
                      if ((option.images != null && option.images!.isNotEmpty) ||
                          option.audioClip != null ||
                          option.video != null)
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => MultimediaPopupPage(option: option),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: const Text(
                              'View More >',
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }


  // Build checkbox node (multiple choice) card in grid view with view more options to see all multimedia
  Widget _buildCheckboxGridView(BotNode node) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
            height: (node.options!.length / 2).ceil() * 180,
            child: _buildCheckboxGrid(node.options!)
        ),
        // Display "Next" button if there's a next node available
        if (node.nextNode != null)
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                onPressed: () => _onOptionSelected(node.nextNode, node.triggerTTs),
                child: const Text('Next', style: TextStyle(color: Colors.white)),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCheckboxGrid(List<Option> options) {
    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Adjust for 2 columns
        crossAxisSpacing: 6,
        mainAxisSpacing: 2,
        childAspectRatio: 1, // Adjust card height
      ),
      itemCount: options.length,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return _buildCheckboxGridOption(options[index]);
      },
    );
  }

  Widget _buildCheckboxGridOption(Option option) {
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
                side: BorderSide(
                  color: isSelected ? Colors.blue.shade900 : Colors.blue.shade50,
                  width: 4,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Colors.blue.shade50, Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16.0)
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Align(
                        alignment: Alignment.topCenter,
                        child: Text(
                          option.label ?? 'No Label',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      if ((option.images != null && option.images!.isNotEmpty) ||
                          option.audioClip != null ||
                          option.video != null)
                      const SizedBox(height: 12),
                      // Multimedia Section
                      if ((option.images != null && option.images!.isNotEmpty) ||
                          option.audioClip != null ||
                          option.video != null)
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                            builder: (context) => MultimediaPopupPage(option: option),
                            ),
                          );
                        },
                          child: Container(
                            alignment: Alignment.bottomCenter,
                            color: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child:  const Text(
                              'View More >',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
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
                        ? selectedOptions.add("File uploaded Successfully")
                        : selectedOptions.add("No Files Uploaded");
                    String tts = anyFileCaptured == true ? 'Files uploaded successfully'
                        : 'No files uploaded';
                    _onOptionSelected(node.nextNode, tts);
                  },
                  child: const Text('Next' ,style: TextStyle(color: Colors.white))
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Build the required Options for Multimedia Node
  Widget _buildMultimediaOption(Option option) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Card(
          elevation: 8, // Increased elevation for better shadow
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0), // Increased border radius
          ),
          child: Container(
            decoration: BoxDecoration(
              // color: Colors.blue.shade50,
              gradient: LinearGradient(
                colors: [Colors.blue.shade50, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0), // Increased padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (option.recordVideo != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          option.recordVideo!,
                          style: const TextStyle(
                            fontSize: 16,
                            // fontWeight: FontWeight.bold,
                            color: Colors.black
                          ),
                        ),
                        const SizedBox(height: 8), // Added spacing
                        Center(
                            child: VideoCaptureWidget(capturedVideo: capturedVideo)
                        ),
                      ],
                    ),
                  if (option.clickPhoto != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          option.clickPhoto!,
                          style: const TextStyle(
                            fontSize: 16,
                            // fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8), // Added spacing
                        Center(
                            child: ImageCaptureWidget(capturedImages: capturedVideo)
                        ),
                      ],
                    ),
                  if (option.recordAudio != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          option.recordAudio!,
                          style: const TextStyle(
                            fontSize: 16,
                            // fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8), // Added spacing
                        Center(
                            child: AudioCaptureWidget(capturedAudio: capturedVideo)
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
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
    if(capturedAudio.isNotEmpty) {
      anyFileCaptured = true;
    }
  }
}
