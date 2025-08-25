import 'dart:convert'; // for jsonDecode
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';

import '../../../core/base_class/failure_response.dart';
import '../model/lesson_request.dart';
import '../model/lesson_response.dart';

final homeScreenRepositoryProvider = Provider<HomescreenRepository>((ref) {
  return HomescreenRepository(ref);
});

class HomescreenRepository {
  final Ref _ref;
  HomescreenRepository(this._ref);

  Future<Either<LessonResponse, FailureResponse>> fetchLessonResponse({
    required LessonRequest lessonRequest,
  }) async {
    try {
      final apiClient = Dio();
      final response = await apiClient.post(
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent",
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "X-goog-api-key": "AIzaSyDQmV0QHLaUbDt2y_8y2c2KQjtZ1zug5Eo",
          },
        ),
        data: {
          "contents": [
            {
              "parts": [
                {
                  "text": """
Generate a day-to-day lesson plan for the subject: ${lessonRequest.subjectName}.  

Constraints:
- Duration: ${lessonRequest.days} days
- Hours per day: ${lessonRequest.hours}
- Additional teacher input: ${lessonRequest.additionalInfo ?? "None"}

IMPORTANT: Return ONLY the raw JSON without any markdown formatting, code blocks, or additional text.

JSON structure:
{
  "theme": "string",
  "overview": "string",
  "days": [
    {
      "dayNumber": 1,
      "sessions": [
        {
          "hour": 1,
          "topic": "string",
          "objectives": ["string","string"],
          "activities": ["string","string"],
          "materials": ["string","string"]
        }
      ]
    }
  ]
}
"""

                }
              ]
            }
          ]
        },
      );
      String rawText =
          response.data["candidates"][0]["content"]["parts"][0]["text"];
      // Strip ```json or ``` code fences with more robust regex
      rawText = rawText
          .replaceAll(RegExp(r'^```(?:json)?\s*', multiLine: true), '') // Remove opening ```json or ``` at start
          .replaceAll(RegExp(r'```\s*$', multiLine: true), '') // Remove closing ``` at end
          .trim();
      LessonResponse data;
      try {
        final Map<String, dynamic> jsonData = jsonDecode(rawText);
        data = LessonResponse.fromJson(jsonData);
      } catch (e) {
        try {
          final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(rawText);
          if (jsonMatch != null) {
            final extractedJson = jsonMatch.group(0);
            final Map<String, dynamic> jsonData = jsonDecode(extractedJson!);
            // Validate that the JSON has the expected structure
            if (jsonData.containsKey('days') && jsonData['days'] is List) {
              data = LessonResponse.fromJson(jsonData);
            } else {
              throw Exception('Extracted JSON does not contain valid lesson plan structure');
            }
          } else {
            throw Exception('No JSON pattern found in response');
          }
        } catch (extractError) {
          data = LessonResponse.fromRawText(rawText);
        }
      }

      return Left(data);
    } catch (e) {
      if (e is DioException) {
        // Check if server responded with an error body
        final statusCode = e.response?.statusCode;
        final responseData = e.response?.data;

        log("DioException caught!");
        log("Status code: $statusCode");
        log("Error data: $responseData");

        // If Gemini returns JSON like { "error": { "message": "...", "status": "UNAVAILABLE" } }
        final apiMessage =
            (responseData is Map && responseData["error"] != null)
                ? responseData["error"]["message"]
                : e.message;
        log("Error message : $apiMessage");
        return Right(FailureResponse(apiMessage));
      }
      return Right(FailureResponse.getErrorMessage(e));
    }
  }
}
