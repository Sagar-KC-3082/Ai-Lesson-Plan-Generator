import 'package:flutter/material.dart';

import '../enums/custom_enums.dart';
import '../widgets/custom_toast_widget.dart';

/// @author: Sagar K.C.
/// @email: sagar.kc@fonepay.com
/// @created_at: 11/22/2023, Wednesday

extension ContextExtension on BuildContext {
  void showToast({
    required String message,
    ToastType toastType = ToastType.error,
    int? maxLines,
    int? duration,
  }) async {
    OverlayEntry? overlayEntry;

    overlayEntry = null;

    final overlayState = Overlay.of(this);

    overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          left: 24,
          right: 24,
          child: CustomToastWidget(
            message: message,
            toastType: toastType,
            maxLines: 10,
            duration: duration,
            callback: () {
              overlayEntry = _removedOverlayEntry(overlayEntry);
            },
            onDismissed: () {
              overlayEntry = _removedOverlayEntry(overlayEntry);
            },
          ),
        );
      },
    );

    overlayState.insert(overlayEntry!);
  }

  OverlayEntry? _removedOverlayEntry(OverlayEntry? overlayEntry) {
    overlayEntry?.remove();
    overlayEntry = null;
    return overlayEntry;
  }
}
