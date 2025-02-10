// Contains the options that a node can contain

class Option {
  final String? label;    // the option to be shown on UI
  final String? description;
  final String? value;
  final String? nextNode;   // Will be triggered when the current option is selected in case of Radio Node
  final List<String>? images;   // images to be added with the option
  final String? audioClip;    // the tts module speaks this string when this option is selected
  final String? video;

  // this is for multi media input capture
  final String? recordVideo;
  final String? clickPhoto;

  // Just for apiCall which will store the response in the apiResponseList
  final List<String>? apiCall;

  //ApiCall for fetching the response and showing the response to the user
  final String? showApiMessage;
  final String? radioOptionTTs;

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
        apiCall: (json['apiCall'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(),
        showApiMessage: json['apiShowMessage'] as String?,
        radioOptionTTs: json['radioOptionTTs'] as String?);
  }
}