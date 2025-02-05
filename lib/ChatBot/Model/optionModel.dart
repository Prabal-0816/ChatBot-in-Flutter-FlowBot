class ImageLayoverData {
  String? topLeft;
  String? topRight;
  String? bottomLeft;
  String? bottomRight;
  String? description;

  ImageLayoverData({
    this.topLeft,
    this.topRight,
    this.bottomLeft,
    this.bottomRight,
    this.description
  });

  // Create the object from JSON
  factory ImageLayoverData.fromJson(Map<String, dynamic> json) {
    return ImageLayoverData(
      topLeft: json['top_left'],
      topRight: json['top_right'],
      bottomLeft: json['bottom_left'],
      bottomRight: json['bottom_right'],
      description: json['description'],
    );
  }
}

class Option {
  final String? label;    // the option to be shown on UI
  final String? description;
  final String? value;
  final String? nextNode;   // nextNode name which will be triggered when the current option is selected
  final List<String>? images;   // images to be added with the option
  final List<ImageLayoverData>? imageLayoverData;   // images layover data
  final String? audioClip;    // the tts module speaks this string when this option is selected
  final String? video;

  // this is for multi media input capture
  final String? recordAudio;
  final String? recordVideo;
  final String? ocr;
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
    this.imageLayoverData,
    this.audioClip,
    this.video,
    this.recordAudio,
    this.recordVideo,
    this.clickPhoto,
    this.ocr,
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
        imageLayoverData: (json['imageLayoverData'] as List<dynamic>?)
            ?.map((e) => ImageLayoverData.fromJson(e))
            .toList(),
        audioClip: json['audioClip'] as String?,
        video: json['video'] as String?,
        recordVideo: json['record_video'] as String?,
        clickPhoto: json['click_photo'] as String?,
        recordAudio: json['record_audio'] as String?,
        ocr: json['OCR'] as String?,
        apiCall: (json['apiCall'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(),
        showApiMessage: json['apiShowMessage'] as String?,
        radioOptionTTs: json['radioOptionTTs'] as String?);
  }
}