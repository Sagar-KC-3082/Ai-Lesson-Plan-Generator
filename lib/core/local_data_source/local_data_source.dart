import 'package:hive_flutter/hive_flutter.dart';

class LocalDataSource {
  late Box lessonListBox;

  static final LocalDataSource _instance = LocalDataSource._internal();
  factory LocalDataSource() => _instance;
  LocalDataSource._internal();

  Future<void> init() async {
    await Hive.initFlutter();
    lessonListBox = await Hive.openBox('lessonListBox');
  }

  /// Save full LessonListResponse (including cascading details)
  Future<void> saveLessonList(String topicName, Map<String, dynamic> data) async {
    await lessonListBox.put(topicName, data);
  }

  /// Get full LessonListResponse for a topic
  Map<String, dynamic>? getLessonList(String topicName) {
    return lessonListBox.get(topicName)?.cast<String, dynamic>();
  }

  /// Update a single lesson’s details inside the cached list
  Future<void> updateLessonDetails(String topicName, int lessonNumber, Map<String, dynamic> details) async {
    final cached = getLessonList(topicName);
    if (cached == null) return;

    final lessons = (cached['message'] as List<dynamic>?);
    if (lessons == null) return;

    final updatedLessons = lessons.map((lesson) {
      if ((lesson['Lesson'] as int?) == lessonNumber) {
        return {
          ...lesson,
          'Details': details,
        };
      }
      return lesson;
    }).toList();

    final updatedData = {
      ...cached,
      'message': updatedLessons,
    };

    await saveLessonList(topicName, updatedData);
  }

  /// Delete cached list for a topic
  Future<void> deleteLessonList(String topicName) async {
    await lessonListBox.delete(topicName);
  }

  /// Clear everything (if needed)
  Future<void> clearAll() async {
    await lessonListBox.clear();
  }
}
