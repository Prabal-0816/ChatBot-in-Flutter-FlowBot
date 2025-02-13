import 'dart:io';
import 'package:flow_bot_json_driven_chat_bot/ChatBot/UI/videoPlayer.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

class VideoCaptureWidget extends StatefulWidget {
  final String label;
  late final List<File> capturedVideo;

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
    setState(() {
      widget.capturedVideo.removeAt(0);
      _videoFile = null;
      _videoController?.dispose();
      _videoController = null;
    });
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
          IconButton(
            icon: const Icon(Icons.videocam , size: 40),
            onPressed: _recordVideo,
          )
        else
          Column(
            children: [
              // Display video thumbnail or player
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: VideoPlayerWidget(videoUrl: _videoFile!.path ),
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
