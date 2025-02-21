import 'package:flutter/material.dart';
import '../Model/optionModel.dart';
import 'CustomCarousel.dart';
import 'VideoPlayer.dart';
import 'audioPlayer.dart';

class MultimediaPopupPage extends StatelessWidget {
  final Option option;

  const MultimediaPopupPage({super.key, required this.option});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(option.label ?? 'Multimedia'),
        backgroundColor: Colors.blue.shade900,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Description
            if (option.description != null && option.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  option.description!,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ),

            // Images (Carousel)
            if (option.images != null && option.images!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: CarouselSliderWidget(imageUrls: option.images!),
              ),

            // Audio Player
            if (option.audioClip != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: AudioPlayerWidget(audioUrl: option.audioClip!),
              ),

            // Video Player
            if (option.video != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: VideoPlayerWidget(videoUrl: option.video!),
              ),
          ],
        ),
      ),
    );
  }
}