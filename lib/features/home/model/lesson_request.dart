class LessonRequest {
  final String subjectName;
  final String days;
  final String hours;
  final String additionalInfo;

  LessonRequest({
    required this.subjectName,
    required this.days,
    required this.hours,
    required this.additionalInfo,
  });

  factory LessonRequest.fromJson(Map<String, dynamic> json) {
    return LessonRequest(
      subjectName: json['subjectName'] as String? ?? '',
      days: json['days'] as String? ?? '',
      hours: json['hours'] as String? ?? '',
      additionalInfo: json['additionalInfo'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subjectName': subjectName,
      'days': days,
      'hours': hours,
      'additionalInfo': additionalInfo,
    };
  }

  LessonRequest copyWith({
    String? subjectName,
    String? days,
    String? hours,
    String? additionalInfo,
  }) {
    return LessonRequest(
      subjectName: subjectName ?? this.subjectName,
      days: days ?? this.days,
      hours: hours ?? this.hours,
      additionalInfo: additionalInfo ?? this.additionalInfo,
    );
  }

  @override
  String toString() {
    return 'LessonRequest(subjectName: $subjectName, days: $days, hours: $hours, additionalInfo: $additionalInfo)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LessonRequest &&
        other.subjectName == subjectName &&
        other.days == days &&
        other.hours == hours &&
        other.additionalInfo == additionalInfo;
  }

  @override
  int get hashCode {
    return subjectName.hashCode ^
        days.hashCode ^
        hours.hashCode ^
        additionalInfo.hashCode;
  }
}
