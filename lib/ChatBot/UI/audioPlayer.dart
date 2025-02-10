import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String audioUrl;

  const AudioPlayerWidget({required this.audioUrl, Key? key}) : super(key: key);

  @override
  _AudioPlayerWidgetState createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  bool isPaused = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        isPlaying = false;
        isPaused = false; // Reset state when audio completes
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _toggleAudio() async {
    if (isPlaying) {
      await _audioPlayer.pause();
      setState(() {
        isPaused = true;
        isPlaying = false;
      });
    } else if (isPaused) {
      await _audioPlayer.resume();
      setState(() {
        isPaused = false;
        isPlaying = true;
      });
    } else {
      await _audioPlayer.play(UrlSource(widget.audioUrl));
      setState(() {
        isPlaying = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Check out the below Audio to verify the same issue you are facing"),
        SizedBox(height: 10,),
        Row(
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(side: BorderSide(width: 2.0 , color: Colors.black54) ),
                elevation: 8, // Add shadow for a more appealing effect
                padding: const EdgeInsets.all(10), // Ensure consistent padding
              ),
              onPressed: _toggleAudio,
              child: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                size: 30,
                color: Colors.black54, // Icon color
              ),
            ),
            const SizedBox(width: 10), // Add spacing between button and waveform
            // Waveform Animation
            if (isPlaying)
              Expanded(
                child: WaveWidget(
                  config: CustomConfig(
                    gradients: [
                      [Colors.blue, Colors.lightBlueAccent],
                      [Colors.lightBlueAccent, Colors.blueAccent],
                    ],
                    durations: [35000, 19440],
                    heightPercentages: [0.2, 0.3],
                    blur: const MaskFilter.blur(BlurStyle.solid, 10),
                    gradientBegin: Alignment.bottomLeft,
                    gradientEnd: Alignment.topRight,
                  ),
                  waveAmplitude: 0,
                  size: const Size(double.infinity, 50),
                ),
              ),
          ],
        ),
      ],
    );
  }
}