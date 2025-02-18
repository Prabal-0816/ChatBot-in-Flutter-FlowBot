import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:record/record.dart'; // Use the record package
import 'package:path_provider/path_provider.dart';

import 'audioPlayer.dart'; // For temporary directory

class AudioCaptureWidget extends StatefulWidget {
  final List<File> capturedAudio; // List to store the captured audio files

  const AudioCaptureWidget({required this.capturedAudio, Key? key}) : super(key: key);

  @override
  _AudioCaptureWidgetState createState() => _AudioCaptureWidgetState();
}

class _AudioCaptureWidgetState extends State<AudioCaptureWidget> {
  File? _audiofile;
  bool _isRecording = false;
  bool _isRed = false;
  late Timer _timer;
  final AudioRecorder _audioRecorder = AudioRecorder(); // Instance of the recorder

  // Function to start recording audio
  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final directory = await getTemporaryDirectory();
        final path = '${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

        await _audioRecorder.start(const RecordConfig(), path: path);

        setState(() {
          _isRecording = true;
        });

        // blinking effect
        _timer = Timer.periodic(const Duration(milliseconds: 500), (timer){
          setState(() {
            _isRed = !_isRed;
          });
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please grant microphone permissions to record audio.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start recording: $e')),
      );
    }
  }

  // Function to stop recording audio
  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      if (path != null) {
        setState(() {
          widget.capturedAudio.add(File(path));
          _audiofile = File(path);
          _isRecording = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to stop recording: $e')),
      );
    }
  }

  // Function to delete an audio file
  void _deleteAudio() {
    setState(() {
      widget.capturedAudio.removeAt(0);
      _audiofile = null;
    });
  }

  @override
  void dispose() {
    _audioRecorder.dispose(); // Dispose the recorder
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if(_audiofile == null)
          ElevatedButton(
              onPressed: !_isRecording ? _startRecording : _stopRecording,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade50, // Light blue background
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50), // Rounded corners
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12), // Add padding
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                      _isRecording ? Icons.stop : Icons.mic,
                    size: 30,
                    color: _isRecording && _isRed ? Colors.red : Colors.blue.shade900
                  ),
                  const SizedBox(width: 8), // Spacing between icon and text
                  Text(
                    _isRecording ?
                    'Click To Pause' : 'Click To Record Audio',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue.shade900,
                    ),
                  ),
                ],
              )
          )
        else
          Column(
            children: [
              // Display video thumbnail or player
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: AudioPlayerWidget(audioUrl: _audiofile!.path ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Delete button
                  IconButton(
                    icon: const Icon(Icons.delete , size: 30),
                    onPressed: _deleteAudio,
                  ),
                ],
              ),
            ],
          )
      ],
    );
  }
}