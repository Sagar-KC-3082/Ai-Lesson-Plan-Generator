class LessonDetailsResponse {
  int? index;
  LessonMessage? message;
  String? finishReason;

  LessonDetailsResponse({
    this.index,
    this.message,
    this.finishReason,
  });

  factory LessonDetailsResponse.fromJson(Map<String, dynamic> json) {
    return LessonDetailsResponse(
      index: json['index'] as int?,
      message: json['message'] != null
          ? LessonMessage.fromJson(json['message'] as Map<String, dynamic>)
          : null,
      finishReason: json['finish_reason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'index': index,
      'message': message?.toJson(),
      'finish_reason': finishReason,
    };
  }
}

class LessonMessage {
  String? role;
  String? content;
  dynamic refusal;

  LessonMessage({
    this.role,
    this.content,
    this.refusal,
  });

  factory LessonMessage.fromJson(Map<String, dynamic> json) {
    return LessonMessage(
      role: json['role'],
      content: json['content'],
      refusal: json['refusal'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'content': content,
      'refusal': refusal,
    };
  }
}
