import 'package:ai_lesson_plan_generator/core/enums/custom_enums.dart';
import 'package:ai_lesson_plan_generator/core/widgets/custom_button.dart';
import 'package:ai_lesson_plan_generator/core/widgets/custom_error_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:markdown_widget/config/configs.dart';
import 'package:markdown_widget/widget/blocks/container/blockquote.dart';
import 'package:markdown_widget/widget/blocks/container/list.dart';
import 'package:markdown_widget/widget/blocks/leaf/code_block.dart';
import 'package:markdown_widget/widget/blocks/leaf/heading.dart';
import 'package:markdown_widget/widget/blocks/leaf/paragraph.dart';
import 'package:markdown_widget/widget/inlines/code.dart';
import 'package:markdown_widget/widget/inlines/img.dart';
import 'package:markdown_widget/widget/markdown.dart';

import '../../../core/base_class/base_state.dart';
import '../../../core/constants/color_constants.dart';
import '../../../core/utils/context_extension.dart';
import '../../../core/widgets/custom_loading_widget.dart';
import '../controller/homescreen_controller.dart';
import '../model/lesson_details_response.dart';
import '../model/lesson_list_response.dart';
import 'downloaded_topic_list_screen.dart';
import 'lesson_list_screen.dart';
import 'package:collection/collection.dart';

final fetchLessonDetailsController =
    StateNotifierProvider.autoDispose<HomeScreenController, BaseState>(
  (ref) => HomeScreenController(ref),
);

final markLessonCompletedProvider =
    StateNotifierProvider.autoDispose<HomeScreenController, BaseState>(
  (ref) => HomeScreenController(ref),
);

class LessonDetailsScreen extends ConsumerStatefulWidget {
  final Lesson lesson;
  final String topicName;
  final int currentIndex;
  final bool isFromDownloadedFlow;

  const LessonDetailsScreen({
    super.key,
    required this.lesson,
    required this.topicName,
    required this.currentIndex,
    this.isFromDownloadedFlow = false,
  });

  @override
  ConsumerState<LessonDetailsScreen> createState() =>
      _LessonDetailsScreenState();
}

class _LessonDetailsScreenState extends ConsumerState<LessonDetailsScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLessonDetails();
    });
  }

  void _loadLessonDetails() {
    final lessonList = ref.read(lessonListProvider).message;

    // Check if the lesson already has details
    final cachedLesson = lessonList?.firstWhereOrNull(
      (l) => l.lesson == widget.lesson.lesson,
    );

    if (cachedLesson?.details != null) {
      // Cached details exist → set state
      ref.read(fetchLessonDetailsController.notifier).state =
          SuccessState<LessonDetailsResponse>(data: cachedLesson!.details!);
    } else {
      // Not cached → call API and cache
      ref
          .read(fetchLessonDetailsController.notifier)
          .fetchAndCacheLessonDetails(
            lessonRequest: widget.lesson,
            topicName: widget.topicName,
          );
    }
  }

  void _retryFetch() {
    ref.read(fetchLessonDetailsController.notifier).fetchAndCacheLessonDetails(
          lessonRequest: widget.lesson,
          topicName: widget.topicName,
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(fetchLessonDetailsController);
    ref.listen(fetchLessonDetailsController, (prev, next) {
      if (next is FailureState) {
        context.showToast(message: next.failureResponse.errorMessage);
      }
    });

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: ColorConstant.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.lesson.topic ?? 'Lesson Details',
          style: const TextStyle(
              color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600),
        ),
      ),
      backgroundColor: ColorConstant.scaffoldColor,
      body: Builder(builder: (_) {
        if (state is LoadingState) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 60),
            child: CustomLoadingWidget(),
          );
        } else if (state is SuccessState<LessonDetailsResponse>) {
          return _buildDetails(state.data);
        } else if (state is FailureState) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 80),
              child: CustomErrorWidget(
                onPressed: _retryFetch,
              ),
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      }),
      bottomNavigationBar: state is SuccessState<LessonDetailsResponse>
          ? Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: CustomButton(
                onPressed: () async {
                  final lessonList = ref.read(lessonListProvider).message ?? [];
                  final currentIndex = widget.currentIndex;

                  // 1️⃣ Get current lesson and max unlocked index
                  int maxUnlockedIndex = lessonList
                      .lastIndexWhere((lesson) => lesson.isLocked == false);
                  if (maxUnlockedIndex == -1) {
                    maxUnlockedIndex = 0;
                  }
                  await ref
                      .read(markLessonCompletedProvider.notifier)
                      .markLessonCompleted(
                        topicName: widget.topicName,
                        currentLessonIndex: currentIndex,
                      );
                  print('hahah : $currentIndex -> $maxUnlockedIndex');
                  // 2️⃣ Show toast only if current lesson was the last unlocked
                  if (currentIndex == maxUnlockedIndex) {
                    if (currentIndex == lessonList.length - 1) {
                      // Last lesson overall
                      context.showToast(
                        message: "You’ve completed all lessons! 🎉",
                        toastType: ToastType.success,
                      );
                    } else {
                      // Next chapter unlocked
                      context.showToast(
                        message: "Next chapter unlocked! ✅",
                        toastType: ToastType.success,
                      );
                    }
                  }
                  print('Step 1 ');
                  WidgetsBinding.instance.addPostFrameCallback((_) async {
                    await ref
                        .read(downloadedLessonsController.notifier)
                        .getCachedLessonList();
                  });
                  Navigator.pop(context);
                },
                label: 'Mark as completed',
              ),
            )
          : const SizedBox(),
    );
  }

  Widget _buildDetails(LessonDetailsResponse details) {
    final content = details.message?.content ?? 'No content available';
    final myMarkdownConfig = MarkdownConfig(configs: [
      H1Config(
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
      H2Config(
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      H3Config(
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      H4Config(
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      H5Config(
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      H6Config(
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      PConfig(textStyle: const TextStyle(fontSize: 20, height: 1.4)),
      BlockquoteConfig(
        sideColor: Colors.blue.shade200,
        textColor: Colors.blueGrey.shade800,
        sideWith: 4.0,
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.symmetric(vertical: 8),
      ),
      ListConfig(
        marginLeft: 24,
        marginBottom: 6,
      ),
      CodeConfig(
        style: const TextStyle(
          fontSize: 16,
          fontFamily: 'monospace',
          backgroundColor: Color(0xfff0f0f0),
        ),
      ),
      PreConfig(
        textStyle: const TextStyle(fontSize: 16, fontFamily: 'monospace'),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      ImgConfig(
        builder: (url, attrs) {
          double? width = attrs['width'] != null
              ? double.tryParse(attrs['width']!)
              : double.infinity;
          double? height = attrs['height'] != null
              ? double.tryParse(attrs['height']!)
              : null;
          return Container(
            width: width,
            height: height,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Image.network(
              url,
              width: width,
              height: height,
              fit: BoxFit.contain,
              errorBuilder: (ctx, error, stacktrace) =>
                  const Icon(Icons.broken_image),
            ),
          );
        },
      ),
    ]);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: MarkdownWidget(
        data: content,
        config: myMarkdownConfig,
      ),
    );
  }
}
