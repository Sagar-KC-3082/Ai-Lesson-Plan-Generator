import 'package:ai_lesson_plan_generator/core/base_class/base_state.dart';
import 'package:ai_lesson_plan_generator/core/utils/context_extension.dart';
import 'package:ai_lesson_plan_generator/core/widgets/custom_inkwell.dart';
import 'package:ai_lesson_plan_generator/core/widgets/custom_loading_widget.dart';
import 'package:ai_lesson_plan_generator/features/home/controller/homescreen_controller.dart';
import 'package:ai_lesson_plan_generator/features/home/model/lesson_list_response.dart';
import 'package:ai_lesson_plan_generator/features/home/presentation/lesson_list_screen.dart';
import 'package:ai_lesson_plan_generator/features/home/presentation/preview_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../core/constants/color_constants.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_textfield.dart';
import 'downloaded_topic_list_screen.dart';

final fetchLessonController =
    StateNotifierProvider.autoDispose((ref) => HomeScreenController(ref));

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final TextEditingController _topicNameController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _topicNameController = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    _topicNameController.dispose();
    super.dispose();
  }

  void _fetchCachedLessons() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(downloadedLessonsController.notifier).getCachedLessonList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final fetchLessonApiState = ref.watch(fetchLessonController);

    ref.listen(fetchLessonController, (prev, next) {
      if (next is SuccessState<LessonListResponse>) {
        ref.read(lessonListProvider.notifier).state = next.data;
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => LessonListScreen(
                  topicName: _topicNameController.text,
                )));
        _fetchCachedLessons();
      } else if (next is FailureState) {
        context.showToast(message: next.failureResponse.errorMessage);
      }
    });

    return Scaffold(
      backgroundColor: ColorConstant.scaffoldColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: ColorConstant.primaryColor,
        title: Text(
          'AI Lesson Plan Maker',
          style: TextStyle(
              color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                controller: _topicNameController,
                labelText: 'Topic Name',
                hintText: 'e.g., Mathematics',
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) {
                  _fetchLessonListLogic(context);
                },
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter valid Topic name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              if (fetchLessonApiState is LoadingState)
                CustomLoadingWidget()
              else
                const SizedBox(),
              CustomButton(
                label: 'Generate',
                isLoading: fetchLessonApiState is LoadingState,
                onPressed: () async {
                  await _fetchLessonListLogic(context);
                },
              ),
              DownloadedTopicListScreen()
            ],
          ),
        ),
      ),
/*      floatingActionButton: CustomInkWell(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => DownloadedTopicListScreen()));
        },
        child: Container(
          height: 60,
          width: 60,
          decoration: BoxDecoration(
              color: ColorConstant.primaryColor, shape: BoxShape.circle),
          child: Icon(
            Icons.download,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),*/
    );
  }

  Future<void> _fetchLessonListLogic(BuildContext context) async {
    FocusScope.of(context).requestFocus(FocusNode());
    if (_formKey.currentState?.validate() ?? false) {
      await Future.delayed(const Duration(milliseconds: 150));
      await ref
          .read(fetchLessonController.notifier)
          .fetchLessonList(_topicNameController.text.trim());
    }
  }
}
