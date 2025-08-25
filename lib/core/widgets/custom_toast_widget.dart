import 'package:flutter/material.dart';

import '../enums/custom_enums.dart';


class CustomToastWidget extends StatefulWidget {
  const CustomToastWidget({
    required this.message,
    required this.callback,
    this.maxLines,
    this.duration,
    this.borderWidth,
    this.onDismissed,
    this.showDurationInSec,
    this.animDurationInMillSec,
    this.toastType = ToastType.error,
    super.key,
  });

  final String message;
  final int? maxLines;
  final int? duration;
  final VoidCallback callback;
  final double? borderWidth;
  final int? showDurationInSec;
  final int? animDurationInMillSec;
  final VoidCallback? onDismissed;
  final ToastType toastType;

  @override
  State<CustomToastWidget> createState() => _CustomToastWidgetState();
}

class _CustomToastWidgetState extends State<CustomToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: widget.animDurationInMillSec ?? 300,
      ),
    );
    _playAnim();
    super.initState();
  }

  void _playAnim() async {
    await _controller.forward();
    await Future<void>.delayed(
      Duration(seconds: widget.showDurationInSec ?? 3),
    );
    await _controller.reverse(from: 1);
    widget.onDismissed?.call();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final double animValue =
              Curves.easeInOutSine.transform(_controller.value);

          return FractionalTranslation(
            translation: Offset(
              0,
              -(1 - animValue),
            ),
            child: child,
          );
        },
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Material(
            elevation: 0,
            borderRadius: BorderRadius.circular(8),
            color: widget.toastType == ToastType.success
                ? Colors.green
                : Colors.red,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Icon(
                    widget.toastType == ToastType.success
                        ? Icons.check_circle
                        : Icons.cancel,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: const TextStyle(color: Colors.white),
                      maxLines: widget.maxLines ?? 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
