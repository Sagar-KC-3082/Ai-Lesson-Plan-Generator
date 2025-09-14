import 'package:ai_lesson_plan_generator/core/constants/color_constants.dart';
import 'package:ai_lesson_plan_generator/core/utils/context_extension.dart';
import 'package:ai_lesson_plan_generator/core/widgets/custom_inkwell.dart';
import 'package:ai_lesson_plan_generator/features/home/model/lesson_list_response.dart';
import 'package:ai_lesson_plan_generator/features/home/presentation/lesson_details_screen.dart';
import 'package:flutter/material.dart';

class LessonWidget extends StatelessWidget {
  final Lesson lesson;
  final String topicName;
  final int index;
  final bool isFromDownloadedFlow;

  const LessonWidget({
    super.key,
    required this.topicName,
    required this.lesson,
    required this.index,
    this.isFromDownloadedFlow = false,
  });

  static const List<String> images = [
    "assets/images/chapter1.png",
    "assets/images/chapter6.png",
    "assets/images/chapter2.png",
    "assets/images/chapter4.png",
    "assets/images/chapter7.png",
  ];

  @override
  Widget build(BuildContext context) {
    final bgColor = ColorConstant.colors[index];
    final imagePath = images[index % images.length];

    return CustomInkWell(
      onTap: () {
        if (!lesson.isLocked || index == 0) {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => LessonDetailsScreen(
                    lesson: lesson,
                    topicName: topicName,
                    currentIndex: index,
                    isFromDownloadedFlow: isFromDownloadedFlow,
                  )));
        } else {
          context.showToast(
              message:
                  'This chapter is locked. Complete the currently unlocked chapter first.');
        }
      },
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              spreadRadius: 1.5,
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: lesson.isLocked && index != 0
                  ? Stack(
                      children: [
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16)),
                            child: Image.asset(
                              imagePath,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: ClipRRect(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  topRight: Radius.circular(16)),
                              child: Container(
                                color: Colors.black.withOpacity(0.5),
                                child: Center(
                                  child: Icon(
                                    Icons.lock,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                              )),
                        ),
                      ],
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16)),
                      child: Image.asset(
                        imagePath,
                        width: MediaQuery.sizeOf(context).width,
                        fit: BoxFit.cover,
                      ),
                    ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Center(
                child: Text(
                  lesson.topic ?? "Untitled",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                lesson.description ?? "No description available",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
