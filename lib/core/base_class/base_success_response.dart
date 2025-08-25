class BaseSuccessResponse {
  final String? status;
  final String? message;
  final String? token;
  final String? fileUrl;

  BaseSuccessResponse({
    this.status,
    this.message,
    this.token,
    this.fileUrl,
  });

  factory BaseSuccessResponse.fromJson(Map<String, dynamic> json) {
    return BaseSuccessResponse(
      status: json['status'] as String?,
      message: json['message'] as String?,
      token: json['token'] as String?,
      fileUrl: json['fileUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'token': token,
      'fileUrl': fileUrl,
    };
  }
}
