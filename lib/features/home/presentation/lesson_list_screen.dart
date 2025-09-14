import 'package:ai_lesson_plan_generator/core/constants/color_constants.dart';
import 'package:ai_lesson_plan_generator/features/home/model/lesson_list_response.dart';
import 'package:ai_lesson_plan_generator/features/home/presentation/widgets/lesson_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final lessonListProvider = StateProvider<LessonListResponse>((ref) {
  return LessonListResponse();
});

class LessonListScreen extends ConsumerWidget {
  const LessonListScreen({
    super.key,
    required this.topicName,
    this.isFromDownloadedFlow = false,
  });

  final String topicName;
  final bool isFromDownloadedFlow;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessonList = ref.watch(lessonListProvider);

    return Scaffold(
      backgroundColor: ColorConstant.scaffoldColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: ColorConstant.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Explore $topicName',
          style: TextStyle(
              color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600),
        ),
      ),
      body: (lessonList.message ?? []).isEmpty
          ? const Center(
              child: Text(
                "No lessons available",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: GridView.builder(
                itemCount: (lessonList.message ?? []).length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemBuilder: (context, index) {
                  final lesson = (lessonList.message ?? [])[index];
                  return LessonWidget(
                    lesson: lesson,
                    index: index,
                    topicName: topicName,
                    isFromDownloadedFlow: isFromDownloadedFlow,

                  );
                },
              ),
            ),
    );
  }
}
