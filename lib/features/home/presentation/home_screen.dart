import 'package:ai_lesson_plan_generator/core/base_class/base_state.dart';
import 'package:ai_lesson_plan_generator/core/utils/context_extension.dart';
import 'package:ai_lesson_plan_generator/features/home/controller/homescreen_controller.dart';
import 'package:ai_lesson_plan_generator/features/home/model/lesson_request.dart';
import 'package:ai_lesson_plan_generator/features/home/model/lesson_response.dart';
import 'package:ai_lesson_plan_generator/features/home/presentation/preview_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/color_constants.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_textfield.dart';

final fetchLessonController =
    StateNotifierProvider.autoDispose((ref) => HomeScreenController(ref));

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final TextEditingController _subjectNameController;
  late final TextEditingController _dateController;
  late final TextEditingController _timeController;
  late final TextEditingController _additionalInfoController;

  final _formKey = GlobalKey<FormState>(); // Form key for validation

  @override
  void initState() {
    _subjectNameController = TextEditingController();
    _dateController = TextEditingController();
    _timeController = TextEditingController();
    _additionalInfoController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _subjectNameController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _additionalInfoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fetchLessonApiState = ref.watch(fetchLessonController);

    ref.listen(fetchLessonController, (prev, next) {
              if (next is SuccessState<LessonResponse>) {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => PreviewScreen(
                    lessonResponse: next.data,
                    subjectName: _subjectNameController.text.trim(),
                  )));
        } else if (next is FailureState) {
        context.showToast(message: next.failureResponse.errorMessage);
      }
    });

    return Scaffold(
      backgroundColor: ColorConstant.scaffoldColor,
      appBar: AppBar(
        title: const Text('AI Lesson Plan Maker'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey, // Wrap inputs in a Form
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                controller: _subjectNameController,
                labelText: 'Subject Name',
                hintText: 'e.g., Mathematics',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter subject name';
                  }
                  return null;
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _dateController,
                      labelText: 'Time (Days)',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter number of days';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      controller: _timeController,
                      labelText: 'Hours',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter hours';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              CustomTextField(
                controller: _additionalInfoController,
                labelText: 'Additional Information',
                maxLines: 5,
              ),
              const SizedBox(height: 12),
              CustomButton(
                label: 'Generate',
                isLoading: fetchLessonApiState is LoadingState,
                onPressed: () async {
                  FocusScope.of(context).unfocus();

                  if (_formKey.currentState?.validate() ?? false) {
                    await ref
                        .read(fetchLessonController.notifier)
                        .fetchLessonResponse(
                          lessonRequest: LessonRequest(
                            subjectName: _subjectNameController.text.trim(),
                            days: _dateController.text.trim(),
                            hours: _timeController.text.trim(),
                            additionalInfo:
                                _additionalInfoController.text.trim(),
                          ),
                        );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}


