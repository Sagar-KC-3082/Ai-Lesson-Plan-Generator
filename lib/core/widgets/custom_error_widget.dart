import 'package:ai_lesson_plan_generator/core/constants/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'custom_inkwell.dart';

class CustomErrorWidget extends ConsumerWidget {
  const CustomErrorWidget({
    required this.onPressed,
    this.errorMessage,
    this.isAtCenter,
    this.upperMarginHeight,
    this.errorReason,
    super.key,
  });

  final String? errorMessage;
  final void Function() onPressed;
  final bool? isAtCenter;
  final double? upperMarginHeight;
  final String? errorReason;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomInkWell(
      onTap: onPressed,
      child: Column(
        mainAxisAlignment: isAtCenter == null
            ? MainAxisAlignment.center
            : MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: upperMarginHeight),
          Center(
            child: Text(
              errorReason ??
                  'We faced some issue while processing your request.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Colors.red,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(
            height: 4,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                errorMessage ?? 'Try Again ',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Icon(Icons.refresh)
            ],
          )
        ],
      ),
    );
  }
}
