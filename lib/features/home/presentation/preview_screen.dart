import 'package:flutter/material.dart';
import '../model/lesson_response.dart';
import '../../../../core/utils/download_utils.dart';
import '../../../../core/widgets/custom_button.dart';

class PreviewScreen extends StatelessWidget {
  final LessonResponse lessonResponse;
  final String? subjectName; // Add subject name parameter

  const PreviewScreen({
    super.key, 
    required this.lessonResponse,
    this.subjectName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Lesson Plan")),
        body: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [

                     Text(
                       subjectName != null && (subjectName?.isNotEmpty ?? false)
                           ? 'Lesson Plan for $subjectName'
                           : (lessonResponse.theme ?? 'Lesson Plan'),
                       style: Theme
                           .of(context)
                           .textTheme
                           .headlineMedium
                           ?.copyWith(
                         fontWeight: FontWeight.bold,
                       ),
                     ),
                     const SizedBox(height: 12),

                    // Overview
                    if (lessonResponse.overview != null) ...[
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            lessonResponse.overview!,
                            style: Theme
                                .of(context)
                                .textTheme
                                .bodyLarge,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Days
                    Text(
                      "Day-to-Day Plan",
                      style: Theme
                          .of(context)
                          .textTheme
                          .titleLarge,
                    ),
                    const SizedBox(height: 12),

                    ...(lessonResponse.days ?? []).map((day) {
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ExpansionTile(
                          leading: const Icon(Icons.calendar_today),
                          title: Text(
                            "Day ${day.dayNumber ?? '-'}"
                                "${day.date != null ? " (${day.date})" : ""}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          children: [
                            if ((day.sessions ?? []).isEmpty)
                              const Padding(
                                padding: EdgeInsets.all(12),
                                child: Text("No sessions planned."),
                              )
                            else
                              ...day.sessions!.map((session) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    elevation: 1,
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment
                                            .start,
                                        children: [
                                          // Hour + Topic
                                          Text(
                                            "Hour ${session.hour ??
                                                '-'}: ${session.topic ?? ''}",
                                            style: Theme
                                                .of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 8),

                                          // Objectives
                                          if ((session.objectives ?? [])
                                              .isNotEmpty) ...[
                                            const Text(
                                              "Objectives:",
                                              style:
                                              TextStyle(
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            const SizedBox(height: 4),
                                            ...session.objectives!.map(
                                                  (obj) =>
                                                  Row(
                                                    children: [
                                                      const Icon(
                                                          Icons.arrow_right,
                                                          size: 18),
                                                      Expanded(
                                                          child: Text(obj)),
                                                    ],
                                                  ),
                                            ),
                                            const SizedBox(height: 8),
                                          ],

                                          // Activities
                                          if ((session.activities ?? [])
                                              .isNotEmpty) ...[
                                            const Text(
                                              "Activities:",
                                              style:
                                              TextStyle(
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            const SizedBox(height: 4),
                                            ...session.activities!.map(
                                                  (act) =>
                                                  Row(
                                                    children: [
                                                      const Icon(Icons.task_alt,
                                                          size: 18),
                                                      Expanded(
                                                          child: Text(act)),
                                                    ],
                                                  ),
                                            ),
                                            const SizedBox(height: 8),
                                          ],

                                          // Materials
                                          if ((session.materials ?? [])
                                              .isNotEmpty) ...[
                                            const Text(
                                              "Materials:",
                                              style:
                                              TextStyle(
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            const SizedBox(height: 4),
                                            ...session.materials!.map(
                                                  (mat) =>
                                                  Row(
                                                    children: [
                                                      const Icon(Icons.school,
                                                          size: 18),
                                                      Expanded(
                                                          child: Text(mat)),
                                                    ],
                                                  ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }),
                          ],
                        ),
                      );
                    }),
                  ],
                ),

              ),
              // Save as PDF Button at bottom
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: CustomButton(
                                     onPressed: () async {
                     // Create unique filename with timestamp to avoid overwriting
                     final timestamp = DateTime.now().millisecondsSinceEpoch;
                     final cleanSubjectName = subjectName != null && (subjectName?.isNotEmpty?? false)
                         ? subjectName?.replaceAll(RegExp(r'[^a-zA-Z0-9\s]'), '').trim().replaceAll(' ', '_')
                         : 'Subject';
                     final fileName = 'Lesson_Plan_${cleanSubjectName}_$timestamp';

                     await DownloadUtils.generateAndSavePDF(
                       lessonResponse,
                       fileName: fileName,
                       context: context,
                       subjectName: subjectName,
                     );
                   },
                  label: 'Save as PDF',
                ),
              ),
            ]));
  }

}