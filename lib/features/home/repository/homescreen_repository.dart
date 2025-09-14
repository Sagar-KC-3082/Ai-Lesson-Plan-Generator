import 'dart:developer';
import 'package:ai_lesson_plan_generator/core/base_class/failure_response.dart';
import 'package:ai_lesson_plan_generator/features/home/model/lesson_details_response.dart';
import 'package:ai_lesson_plan_generator/features/home/model/lesson_list_response.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../presentation/lesson_list_screen.dart';

final homeScreenRepositoryProvider = Provider<HomescreenRepository>((ref) {
  return HomescreenRepository(ref);
});

class HomescreenRepository {
  final Ref _ref;

  HomescreenRepository(this._ref);

  /// Opens Hive box
  Future<Box> get lessonListBox async => await Hive.openBox('lessonListBox');

  /// Converts dynamic maps/lists to Map<String, dynamic> / List recursively
  dynamic _convertDynamicMap(dynamic value) {
    if (value is Map) {
      return value.map<String, dynamic>(
        (k, v) => MapEntry(k.toString(), _convertDynamicMap(v)),
      );
    } else if (value is List) {
      return value.map((e) => _convertDynamicMap(e)).toList();
    } else {
      return value;
    }
  }

  /// Fetch lesson list for a topic from API or cache
  Future<Either<LessonListResponse, FailureResponse>> fetchLessonList(
      String topicName) async {
    try {
      final box = await Hive.openBox('lessonListBox');
      final cachedData = box.get(topicName.trim().toLowerCase());
      if (cachedData != null) {
        final safeMap = _convertDynamicMap(cachedData) as Map<String, dynamic>;
        return Left(LessonListResponse.fromJson(safeMap));
      }

      final apiClient = Dio();
      final response = await apiClient.post(
        "https://agent.technologychannel.org/webhook/create-course-topic",
        data: {"topic": topicName.trim()},
        options: Options(headers: {
          'Content-Type': 'application/json',
          'X-API-Key':
              "2y\$10\$WXbDae2EDkEWGcnxzSvoY.aFRqCNdDq6WKq.q8wv8DFdioGPpiALu",
        }),
      );

      final lessonListResponse =
          LessonListResponse.fromJson(response.data).copyWith(
        topicName: topicName,
        cachedAt: DateTime.now().millisecondsSinceEpoch,
      );

      await box.put(topicName.trim().toLowerCase(), Map<String, dynamic>.from(lessonListResponse.toJson()));

      return Left(lessonListResponse);
    } catch (e) {
      return Right(FailureResponse.getErrorMessage(e));
    }
  }

  Future<Either<LessonDetailsResponse, FailureResponse>> fetchLessonDetails({
    required Lesson lessonRequest,
    required String topicName,
  }) async {
    try {
      final box = await Hive.openBox('lessonListBox');
      final apiClient = Dio();

      final response = await apiClient.post(
        "https://agent.technologychannel.org/webhook/skill-ai-content",
        data: {
          "topic": lessonRequest.lesson,
          "subtopic": lessonRequest.topic,
          "description": lessonRequest.description,
        },
        options: Options(headers: {
          'X-API-Key':
          "2y\$10\$WXbDae2EDkEWGcnxzSvoY.aFRqCNdDq6WKq.q8wv8DFdioGPpiALu",
        }),
      );

      final lessonDetailsResponse = LessonDetailsResponse.fromJson(response.data);

      // ✅ Read the existing provider first
      final lessonListResponse = _ref.read(lessonListProvider);

      // Merge details into the existing lesson
      final updatedLessons = lessonListResponse.message?.map((lesson) {
        if (lesson.lesson == lessonRequest.lesson) {
          return lesson.copyWith(details: lessonDetailsResponse);
        }
        return lesson;
      }).toList();

      // Updated list response with cachedAt (preserve topic-level cachedAt)
      final updatedListResponse = lessonListResponse.copyWith(
        message: updatedLessons,
        cachedAt: lessonListResponse.cachedAt ?? DateTime.now().millisecondsSinceEpoch,
      );

      // ✅ Update provider
      _ref.read(lessonListProvider.notifier).state = updatedListResponse;

      // ✅ Persist to Hive
      await box.put(topicName.trim().toLowerCase(), updatedListResponse.toJson());

      return Left(lessonDetailsResponse);
    } catch (e) {
      return Right(FailureResponse.getErrorMessage(e));
    }
  }


  /// Get all cached lesson lists (topics), latest stored first
  Future<List<LessonListResponse>> getAllCachedLessonLists() async {
    try {
      final box = await Hive.openBox('lessonListBox');
      List<LessonListResponse> result = [];

      for (var cachedData in box.values) {
        final safeMap = _convertDynamicMap(cachedData) as Map<String, dynamic>;
        result.add(LessonListResponse.fromJson(safeMap));
      }

      // ✅ Sort by cachedAt (latest first)
      result.sort((a, b) => (b.cachedAt ?? 0).compareTo(a.cachedAt ?? 0));

      return result;
    } catch (e) {
      print("Error fetching all cached lessons: $e");
      return [];
    }
  }

  /// Get cached lesson list for a specific topic
  Future<LessonListResponse?> getCachedLessonListForTopic(
      String topicName) async {
    try {
      final box = await Hive.openBox('lessonListBox');
      final cachedData = box.get(topicName.trim().toLowerCase());
      if (cachedData != null) {
        final safeMap = _convertDynamicMap(cachedData) as Map<String, dynamic>;
        return LessonListResponse.fromJson(safeMap);
      }
      return null;
    } catch (e) {
      print("Error fetching cached lesson for topic $topicName: $e");
      return null;
    }
  }
}
