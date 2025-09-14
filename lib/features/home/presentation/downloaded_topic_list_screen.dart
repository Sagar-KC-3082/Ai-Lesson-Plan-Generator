import 'package:ai_lesson_plan_generator/features/home/presentation/widgets/downloaded_topic_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../core/base_class/base_state.dart';
import '../../../core/constants/color_constants.dart';
import '../controller/homescreen_controller.dart';
import '../model/lesson_list_response.dart';

final downloadedLessonsController =
    StateNotifierProvider<HomeScreenController, BaseState>(
  (ref) => HomeScreenController(ref),
);

class DownloadedTopicListScreen extends ConsumerStatefulWidget {
  const DownloadedTopicListScreen({super.key});

  @override
  ConsumerState<DownloadedTopicListScreen> createState() =>
      _DownloadedTopicListScreenState();
}

class _DownloadedTopicListScreenState
    extends ConsumerState<DownloadedTopicListScreen> {
  @override
  void initState() {
    super.initState();
    _fetchCachedLessons();
  }

  void _fetchCachedLessons() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(downloadedLessonsController.notifier)
          .getCachedLessonList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(downloadedLessonsController);

    return Scaffold(
      backgroundColor: ColorConstant.scaffoldColor,
      appBar: AppBar(
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: ColorConstant.primaryColor,
        title: Text(
          'Downloaded Topics',
          style: TextStyle(
              color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600),
        ),
      ),
      body: Builder(
        builder: (context) {
          if (state is LoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SuccessState<List<LessonListResponse>>) {
            final lessonsList = state.data;
            if (lessonsList.isEmpty) {
              return const Center(
                child: Text("No downloaded topics found"),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: lessonsList.length,
              itemBuilder: (context, index) {
                final topic = lessonsList[index];
                return DownloadedTopicWidget(
                  lesson: topic,
                  index: index,
                );
              },
            );
          }

          if (state is FailureState) {
            return Center(child: Text(state.failureResponse.errorMessage));
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
