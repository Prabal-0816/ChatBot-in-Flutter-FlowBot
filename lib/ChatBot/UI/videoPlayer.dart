import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  VideoPlayerWidget({required this.videoUrl});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? _videoController;
  YoutubePlayerController? _youtubeController;
  bool isYoutubeVideo = false;

  @override
  void initState() {
    super.initState();

    // Check if the video is a youtube Video
    if(_isYoutubeLink(widget.videoUrl)) {
      isYoutubeVideo = true;
      _initializeYoutubePlayer();
    }
    else {
      _initializeVideoPlayer();
    }
  }

  // Initialize video player for Youtube links
  void _initializeVideoPlayer() {
    _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        setState(() {});
        // Pause the video by default after it has been initialized
        _videoController?.pause();
      }).catchError((error) {
        // Handle initialization error
        setState(() {
          _videoController = null;
        });
      });

    // Optionally add listeners for other events (like status change)
    _videoController?.addListener(() {
      setState(() {});
    });
  }

  void _initializeYoutubePlayer() {
    final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);
    if(videoId != null) {
      _youtubeController = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
        ),
      );
    }
    else {
      // Handles invalid youtube urls
      setState(() {
        isYoutubeVideo = false;   // Fallback to network video player
      });
    }
  }

  // Method to detect if a link is a Youtube video
  bool _isYoutubeLink(String url) {
    return url.contains("youtube.com") || url.contains("youtu.be");
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _youtubeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isYoutubeVideo ? _buildYoutubePlayer() : _buildNetworkVideoPlayer();
  }

  // Widget to build the Youtube Player
  Widget _buildYoutubePlayer() {
    if (_youtubeController == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 10),
            Text('Loading YouTube video...'),
          ],
        ),
      );
    }

    return YoutubePlayer(
      controller: _youtubeController!,
      actionsPadding: const EdgeInsets.all(8.0),
      showVideoProgressIndicator: true,
    );
  }

  // Widget to build the Video Player
  Widget _buildNetworkVideoPlayer() {
    if(_videoController == null || !_videoController!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator(),);
    }

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        AspectRatio(
          aspectRatio: _videoController!.value.aspectRatio,
          child: VideoPlayer(_videoController!),
        ),

        // Play Pause Button
        Positioned.fill(
          child: Center(
            child: IconButton(
              icon: Icon(
                _videoController!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white.withOpacity(0.8),  // Adjust the color as needed
                size: 50.0,  // Adjust the size as needed
              ),
              onPressed: () {
                setState(() {
                  _videoController!.value.isPlaying
                      ? _videoController!.pause()
                      : _videoController!.play();
                });
              },
            ),
          ),
        ),

        // Progress Indicator
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Row(
            children: [
              Expanded(
                child: VideoProgressIndicator(
                  _videoController!,
                  allowScrubbing: true,
                  colors: const VideoProgressColors(
                    playedColor: Colors.blueAccent,
                    bufferedColor: Colors.grey,
                    backgroundColor: Colors.black12,
                  ),
                ),
              ),
              Text(
                '${_videoController!.value.position.toString().split('.').first} / '
                    '${_videoController!.value.duration.toString().split('.').first}',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }
}