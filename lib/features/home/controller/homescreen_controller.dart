import 'package:ai_lesson_plan_generator/features/home/model/lesson_details_response.dart';
import 'package:ai_lesson_plan_generator/features/home/model/lesson_list_response.dart';
import 'package:ai_lesson_plan_generator/features/home/presentation/downloaded_topic_list_screen.dart';
import 'package:ai_lesson_plan_generator/features/home/repository/homescreen_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../core/base_class/base_state.dart';
import '../presentation/lesson_list_screen.dart';
import 'package:collection/collection.dart'; // <-- needed for firstWhereOrNull

class HomeScreenController extends StateNotifier<BaseState> {
  HomeScreenController(this._ref) : super(InitialState());

  final Ref _ref;

  HomescreenRepository get _homeScreenRepo =>
      _ref.read(homeScreenRepositoryProvider);

  Future<void> fetchLessonList(
    String topicName,
  ) async {
    state = LoadingState();
    final response = await _homeScreenRepo.fetchLessonList(
      topicName,
    );
    state = response.fold(
      (success) => SuccessState<LessonListResponse>(data: success),
      (failure) => FailureState(failureResponse: failure),
    );
  }
/*
  Future<void> fetchLessonDetails({
    required Lesson lessonRequest,
    required String topicName,
  }) async {
    state = LoadingState();

    final response = await _homeScreenRepo.fetchLessonDetails(
      lessonRequest: lessonRequest,
      topicName: topicName,
    );

    response.fold(
      (lessonDetails) {
        final currentList = _ref.read(lessonListProvider.notifier).state;
        final updatedLessons = currentList.message?.map((lesson) {
          if (lesson.lesson == lessonRequest.lesson) {
            return lesson.copyWith(details: lessonDetails);
          }
          return lesson;
        }).toList();

        _ref.read(lessonListProvider.notifier).state =
            currentList.copyWith(message: updatedLessons);


        state = SuccessState<LessonDetailsResponse>(data: lessonDetails);
      },
      (failure) {
        state = FailureState(failureResponse: failure);
      },
    );
  }*/

  /// Returns the full LessonListResponse for a given topic from Hive cache
  Future<void> getCachedLessonList() async {
    state = LoadingState();
    final data = await _homeScreenRepo.getAllCachedLessonLists();
    state = SuccessState<List<LessonListResponse>>(data: data);
  }

  Future<void> markLessonCompleted({
    required String topicName,
    required int currentLessonIndex,
  }) async {
    try {
      final lessonListResponse = _ref.read(lessonListProvider);
      if (lessonListResponse.message == null) return;

      final lessons = List<Lesson>.from(lessonListResponse.message!);

      if (currentLessonIndex >= 0 && currentLessonIndex < lessons.length) {
        lessons[currentLessonIndex] =
            lessons[currentLessonIndex].copyWith(isLocked: false);

        if (currentLessonIndex + 1 < lessons.length) {
          lessons[currentLessonIndex + 1] =
              lessons[currentLessonIndex + 1].copyWith(isLocked: false);
        }
      }

      final updatedListResponse =
      lessonListResponse.copyWith(message: List<Lesson>.from(lessons));

      // ✅ Update provider
      _ref.read(lessonListProvider.notifier).state = updatedListResponse;

      // ✅ Persist exact provider state to Hive
      final box = await _homeScreenRepo.lessonListBox;
      await box.put(topicName.trim().toLowerCase(), updatedListResponse.toJson());

    } catch (e) {
      print("Error marking lesson completed: $e");
    }
  }




  Future<void> fetchAndCacheLessonDetails({
    required Lesson lessonRequest,
    required String topicName,
  }) async {
    state = LoadingState();

    // 1️⃣ Read from provider first (not Hive)
    final lessonList = _ref.read(lessonListProvider);

    // 2️⃣ Find the lesson in provider
    final cachedLesson = lessonList.message?.firstWhereOrNull(
          (l) => l.lesson == lessonRequest.lesson,
    );

    if (cachedLesson?.details != null) {
      // Already has details → set state to success
      state = SuccessState<LessonDetailsResponse>(data: cachedLesson!.details!);
      return;
    }

    // 3️⃣ Fetch details from API
    final result = await _homeScreenRepo.fetchLessonDetails(
      lessonRequest: lessonRequest,
      topicName: topicName,
    );

    result.fold((lessonDetailsResponse) async {
      // 4️⃣ Update provider
      final updatedLessons = lessonList.message?.map((lesson) {
        if (lesson.lesson == lessonRequest.lesson) {
          return lesson.copyWith(details: lessonDetailsResponse);
        }
        return lesson;
      }).toList();

      final updatedList = lessonList.copyWith(message: updatedLessons);
      _ref.read(lessonListProvider.notifier).state = updatedList;

      // 5️⃣ Update Hive
      final box = await _homeScreenRepo.lessonListBox;
      await box.put(topicName.trim().toLowerCase(), updatedList.toJson());

      /// This is to update the cached lesson in homescreen...
      _ref.read(downloadedLessonsController.notifier).getCachedLessonList();
      // 6️⃣ Set state to success so UI updates
      state = SuccessState<LessonDetailsResponse>(data: lessonDetailsResponse);
    }, (failure) {
      state = FailureState( failureResponse: failure);
      print("Error fetching lesson details: ${failure.errorMessage}");
    });
  }




}
