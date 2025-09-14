import 'package:ai_lesson_plan_generator/features/home/presentation/lesson_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../../core/widgets/custom_inkwell.dart';
import '../../model/lesson_list_response.dart';
import '../lesson_details_screen.dart';

class DownloadedTopicWidget extends ConsumerWidget {
  final LessonListResponse lesson;
  final int index;

  const DownloadedTopicWidget({
    super.key,
    required this.lesson,
    required this.index,
  });

  static const List<String> images = [
    "assets/images/chapter6.png",
    "assets/images/chapter7.png",
    "assets/images/chapter2.png",
    "assets/images/chapter4.png",
    "assets/images/chapter5.png",
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bgColor = ColorConstant.colors[index % ColorConstant.colors.length];
    final imagePath = images[index % images.length];

    return CustomInkWell(
      onTap: () {
        // Open first lesson
        if (lesson.message != null && lesson.message!.isNotEmpty) {
          final firstLesson = lesson.message!.first;
          ref.read(lessonListProvider.notifier).state = lesson;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => LessonListScreen(
                topicName: lesson.topicName ?? '-',
                isFromDownloadedFlow: true,
              ),
            ),
          );
        }
      },
      child: Container(
        width: 160, // Compact width
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.asset(
                imagePath,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                lesson.topicName ?? '',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
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
