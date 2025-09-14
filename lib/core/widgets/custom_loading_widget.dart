import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class CustomLoadingWidget extends StatelessWidget {
  final double size;
  final String? message;

  const CustomLoadingWidget({
    super.key,
    this.size = 250,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Lottie.asset(
            'assets/animations/loading_animation.json',
            width: size,
            height: size,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 12),
          Text(
            message ??
                'Your request is being processed. This might 20-25 seconds.',
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
