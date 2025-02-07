import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoWidget extends StatefulWidget {
  final String videoUrl;

  VideoWidget({required this.videoUrl});

  @override
  _VideoWidgetState createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
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
    _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl),
        videoPlayerOptions: VideoPlayerOptions(
          // webOptions:
        ))
      ..initialize().then((_) {
        setState(() {});

        // Pause the video by default after it has been initialized
        _videoController?.pause();
      });

    // Optionally add listeners for other events (like status change)
    _videoController?.addListener(() {
      setState(() {
      });
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
    return SizedBox(
      height: 200,
      child: isYoutubeVideo
          ? _buildYoutubePlayer() : _buildNetworkVideoPlayer(),
    );
  }

  // Widget to build the Youtube Player
  Widget _buildYoutubePlayer() {
    if(_youtubeController == null) {
      return const Center(child: CircularProgressIndicator());
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
          aspectRatio: 2.0,//_videoController!.value.aspectRatio,
          child: VideoPlayer(_videoController!),
        ),

        Positioned(
          bottom: 52,
          child: IconButton(
            icon: Icon(
              _videoController!.value.isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,  // Adjust the color as needed
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
        VideoProgressIndicator(
          _videoController!,
          allowScrubbing: true,
          colors: const VideoProgressColors(
            playedColor: Colors.blueAccent,
            bufferedColor: Colors.grey,
            backgroundColor: Colors.black12,
          ),
        ),
      ],
    );
  }
}