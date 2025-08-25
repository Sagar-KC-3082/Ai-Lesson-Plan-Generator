class LessonResponse {
  final String? theme;
  final String? overview;
  final List<LessonDay>? days;

  LessonResponse({
    this.theme,
    this.overview,
    this.days,
  });

  factory LessonResponse.fromJson(Map<String, dynamic> json) {
    return LessonResponse(
      theme: json["theme"] as String?,
      overview: json["overview"] as String?,
      days: (json["days"] as List<dynamic>?)
          ?.map((day) => LessonDay.fromJson(day))
          .toList() ??
          [],
    );
  }

  factory LessonResponse.fromRawText(String rawText) {
    return LessonResponse(
      theme: "Unstructured Lesson",
      overview: rawText,
      days: [],
    );
  }
}

class LessonDay {
  final int? dayNumber;
  final String? date;
  final List<LessonSession>? sessions;

  LessonDay({
    this.dayNumber,
    this.date,
    this.sessions,
  });

  factory LessonDay.fromJson(Map<String, dynamic> json) {
    return LessonDay(
      dayNumber: json["dayNumber"] as int?,
      date: json["date"] as String?,
      sessions: (json["sessions"] as List<dynamic>?)
          ?.map((s) => LessonSession.fromJson(s))
          .toList() ??
          [],
    );
  }
}

class LessonSession {
  final int? hour;
  final String? topic;
  final List<String>? objectives;
  final List<String>? activities;
  final List<String>? materials;

  LessonSession({
    this.hour,
    this.topic,
    this.objectives,
    this.activities,
    this.materials,
  });

  factory LessonSession.fromJson(Map<String, dynamic> json) {
    return LessonSession(
      hour: json["hour"] as int?,
      topic: json["topic"] as String?,
      objectives: (json["objectives"] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
      activities: (json["activities"] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
      materials: (json["materials"] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
    );
  }
}
