import 'dart:io';
import 'package:flow_bot_json_driven_chat_bot/ChatBot/UI/videoPlayer.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

class VideoCaptureWidget extends StatefulWidget {
  final String label;
  final List<File> capturedVideo;

  VideoCaptureWidget({required this.label , required this.capturedVideo});

  @override
  _VideoCaptureWidgetState createState() => _VideoCaptureWidgetState();
}

class _VideoCaptureWidgetState extends State<VideoCaptureWidget> {
  File? _videoFile; // Holds the recorded video file
  VideoPlayerController? _videoController; // For controlling video playback

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  // Open camera and record video
  Future<void> _recordVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.camera);
    if (video != null) {
      setState(() {
        widget.capturedVideo.add(File(video.path));
        _videoFile = File(video.path);
      });
      _initializeVideoPlayer();
    }
  }

  // Initialize the video player controller for the recorded video
  Future<void> _initializeVideoPlayer() async {
    if (_videoFile == null) return;

    // Dispose the existing controller before creating a new one
    _videoController?.dispose();

    _videoController = VideoPlayerController.file(_videoFile!)
      ..addListener(() {
        setState(() {}); // Update the UI when video status changes
      })
      ..setLooping(false)
      ..initialize().then((_) {
        setState(() {}); // Update the UI when initialization is complete
      });
  }

  // Delete the recorded video
  void _deleteVideo() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Video'),
          content: const Text('Are you sure you want to delete this video?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  widget.capturedVideo.removeAt(0);
                  _videoFile = null;
                  _videoController?.dispose();
                  _videoController = null;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label),
        const SizedBox(height: 10),
        if (_videoFile == null)
        // Record Video Button
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.videocam , size: 40),
                onPressed: _recordVideo,
              ),
              const Text('No video recorded yet...')
            ],
          )
        else
          Column(
            children: [
              // Display video thumbnail or player
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: _videoController != null && _videoController!.value.isInitialized
                    ? VideoPlayerWidget(videoUrl: _videoFile!.path)
                    : Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(Icons.videocam_off, size: 48, color: Colors.grey),
                  ),
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Delete button
                  IconButton(
                    icon: const Icon(Icons.delete , size: 30),
                    onPressed: _deleteVideo,
                  ),
                ],
              ),
            ],
          ),
      ],
    );
  }
}
