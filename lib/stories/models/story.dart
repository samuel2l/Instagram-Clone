import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class StoryDataPosition {
  final double dx;
  final double dy;
  StoryDataPosition({required this.dx, required this.dy});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'dx': dx, 'dy': dy};
  }

  factory StoryDataPosition.fromMap(Map<String, dynamic> map) {
    return StoryDataPosition(dx: map['dx'] as double, dy: map['dy'] as double);
  }

  String toJson() => json.encode(toMap());

  factory StoryDataPosition.fromJson(String source) =>
      StoryDataPosition.fromMap(json.decode(source) as Map<String, dynamic>);
}

class StoryData {
  final double rotation;
  final String value;
  final String type;
  final StoryDataPosition position;

  final double scale;
  StoryData({
    required this.rotation,
    required this.value,
    required this.type,
    required this.position,
    required this.scale,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'rotation': rotation,
      'value': value,
      'type': type,
      'position': position.toMap(),
      'scale': scale,
    };
  }

  factory StoryData.fromMap(Map<String, dynamic> map) {
    return StoryData(
      rotation: map['rotation'] as double,
      value: map['value'] as String,
      type: map['type'] as String,
      position: StoryDataPosition.fromMap(
        map['position'] as Map<String, dynamic>,
      ),
      scale: map['scale'] as double,
    );
  }

  String toJson() => json.encode(toMap());

  factory StoryData.fromJson(String source) =>
      StoryData.fromMap(json.decode(source) as Map<String, dynamic>);
}

class Story {
  final String storyId;
  final List<StoryData> storyData;

  final String timestamp;
  final String mediaUrl;
  final List<String> watchers;
  Story({
    required this.storyId,
    required this.storyData,
    required this.timestamp,
    required this.mediaUrl,
    required this.watchers,
  });


  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'storyId': storyId,
      'storyData': storyData.map((x) => x.toMap()).toList(),
      'timestamp': timestamp,
      'mediaUrl': mediaUrl,
      'watchers': watchers,
    };
  }

  factory Story.fromMap(Map<String, dynamic> map) {
    return Story(
      storyId: map['storyId'] as String,
      storyData: List<StoryData>.from((map['storyData'] as List<int>).map<StoryData>((x) => StoryData.fromMap(x as Map<String,dynamic>),),),
      timestamp: (map['timestamp'] as Timestamp).toDate().toIso8601String(),
      mediaUrl: map['mediaUrl'] as String,
      watchers: List<String>.from((map['watchers'] as List<String>),
    ));
  }

  String toJson() => json.encode(toMap());

  factory Story.fromJson(String source) => Story.fromMap(json.decode(source) as Map<String, dynamic>);

}
