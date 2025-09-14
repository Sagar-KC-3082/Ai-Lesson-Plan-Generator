import 'dart:convert';
import 'lesson_details_response.dart';

class LessonListResponse {
  String? topicName;
  List<Lesson>? message;
  String? finishReason;
  int? cachedAt; // ✅ new field for sorting

  LessonListResponse({
    this.topicName,
    this.message,
    this.finishReason,
    this.cachedAt,
  });

  factory LessonListResponse.fromJson(Map<String, dynamic> json) {
    List<Lesson>? lessons;

    if (json['message'] != null) {
      final message = json['message'];

      if (message is Map<String, dynamic> && message['content'] != null) {
        final contentStr = message['content'] as String;

        try {
          final decoded = jsonDecode(contentStr) as List<dynamic>;
          lessons = decoded
              .map((e) => Lesson.fromJson(e as Map<String, dynamic>))
              .toList();
        } catch (e) {
          lessons = [];
        }
      } else if (message is List) {
        lessons = message
            .map((e) => Lesson.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    }

    return LessonListResponse(
      message: lessons,
      finishReason: json['finish_reason'] as String?,
      topicName: json['topicName'] as String?,
      cachedAt: json['cachedAt'] as int?, // ✅ parse date
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message?.map((e) => e.toJson()).toList(),
      'finish_reason': finishReason,
      'topicName': topicName,
      'cachedAt': cachedAt, // ✅ include date
    };
  }

  LessonListResponse copyWith({
    List<Lesson>? message,
    String? finishReason,
    String? topicName,
    int? cachedAt,
  }) {
    return LessonListResponse(
      message: message ?? this.message,
      finishReason: finishReason ?? this.finishReason,
      topicName: topicName ?? this.topicName,
      cachedAt: cachedAt ?? this.cachedAt,
    );
  }
}

class Lesson {
  int? lesson;
  String? topic;
  String? description;
  bool isLocked;
  LessonDetailsResponse? details;

  Lesson({
    this.lesson,
    this.topic,
    this.description,
    this.isLocked = true,
    this.details,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      lesson: json['Lesson'] as int?,
      topic: json['Topic'] as String?,
      description: json['Description'] as String?,
      isLocked: json['IsLocked'] ?? true,
      details: json['Details'] != null
          ? LessonDetailsResponse.fromJson(json['Details'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Lesson': lesson,
      'Topic': topic,
      'Description': description,
      'IsLocked': isLocked,
      'Details': details?.toJson(),
    };
  }

  Lesson copyWith({
    int? lesson,
    String? topic,
    String? description,
    bool? isLocked,
    LessonDetailsResponse? details,
  }) {
    return Lesson(
      lesson: lesson ?? this.lesson,
      topic: topic ?? this.topic,
      description: description ?? this.description,
      isLocked: isLocked ?? this.isLocked,
      details: details ?? this.details,
    );
  }
}
