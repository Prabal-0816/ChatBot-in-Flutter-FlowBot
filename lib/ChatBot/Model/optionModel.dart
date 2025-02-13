// Contains the options that a node can contain

class Option {
  final String? label;    // the option to be shown on UI
  final String? description;  // option description with lighter shade and smaller text that label
  final String? value;      // will serve as the answer for the intent of the question
  final String? nextNode;   // Will be triggered when the any of the option is selected in case of Radio Node
  final List<String>? images;   // images to be shown along with the option
  final String? audioClip;    // contains the audio clip to be shown along with the option
  final String? video;        // contains the video link to be shown along with the option
  final String? recordVideo;  // this is for multimedia input to record video
  final String? clickPhoto;   // this is for multimedia input to capture images
  final String? recordAudio;  // this is for multimedia input to record audio
  final List<String>? apiCall;  // For apiCall which will store the response in the apiResponseList
  final String? showApiMessage; // ApiCall for fetching the response and showing the response to the user
  final String? radioOptionTTs; // Will be triggered when the option of the radio node is selected

  Option({
    this.label,
    this.description,
    this.value,
    this.nextNode,
    this.images,
    this.audioClip,
    this.video,
    this.recordVideo,
    this.clickPhoto,
    this.recordAudio,
    this.apiCall,
    this.showApiMessage,
    this.radioOptionTTs
  });

  // Factory method to parse from JSON
  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
        label: json['label'] as String?,
        description: json['description'] as String?,
        value: json['value'] as String?,
        nextNode: json['nextNode'] as String?,
        images: (json['images'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(),
        audioClip: json['audioClip'] as String?,
        video: json['video'] as String?,
        recordVideo: json['record_video'] as String?,
        clickPhoto: json['click_photo'] as String?,
        recordAudio: json['record_audio'] as String?,
        apiCall: (json['apiCall'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(),
        showApiMessage: json['apiShowMessage'] as String?,
        radioOptionTTs: json['radioOptionTTs'] as String?);
  }
}