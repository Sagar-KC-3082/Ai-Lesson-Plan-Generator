import 'package:ai_lesson_plan_generator/features/home/model/lesson_response.dart';
import 'package:ai_lesson_plan_generator/features/home/repository/homescreen_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/base_class/base_state.dart';
import '../model/lesson_request.dart';

class HomeScreenController extends StateNotifier<BaseState> {
  HomeScreenController(this._ref) : super(InitialState());

  final Ref<dynamic> _ref;

  HomescreenRepository get _homeScreenRepo =>
      _ref.read(homeScreenRepositoryProvider);

  Future<void> fetchLessonResponse({
    required LessonRequest lessonRequest,
  }) async {
    state = LoadingState();
    final response = await _homeScreenRepo.fetchLessonResponse(
      lessonRequest: lessonRequest,
    );
    state = response.fold(
      (success) => SuccessState<LessonResponse>(data: success),
      (failure) => FailureState(failureResponse: failure),
    );
  }
}
