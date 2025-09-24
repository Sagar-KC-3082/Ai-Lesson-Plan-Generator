import 'package:ai_lesson_plan_generator/core/widgets/custom_inkwell.dart';
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

/*
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe to route observer
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }
*/


  void _fetchCachedLessons() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(downloadedLessonsController.notifier).getCachedLessonList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(downloadedLessonsController);

    return Builder(
      builder: (context) {
        if (state is LoadingState) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is SuccessState<List<LessonListResponse>>) {
          final lessonsList = state.data;
          if (lessonsList.isEmpty) {
            return const SizedBox();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Divider(),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Saved Items',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: CustomInkWell(
                        onTap: _fetchCachedLessons,
                        child: Icon(
                          Icons.refresh,
                          color: Colors.black,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                itemCount: lessonsList.length,
                itemBuilder: (context, index) {
                  final topic = lessonsList[index];
                  return DownloadedTopicWidget(
                    lesson: topic,
                    index: index,
                  );
                },
              )
            ],
          );
        }

        if (state is FailureState) {
          return Center(child: Text(state.failureResponse.errorMessage));
        }

        return const SizedBox.shrink();
      },
    );
  }
}
