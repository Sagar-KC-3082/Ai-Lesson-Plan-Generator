import 'package:flutter/material.dart';

/// @author: Sagar K.C.
/// @email: sagar.kc@fonepay.com
/// @created_at: 6/15/2024, Saturday

class CustomInkWell extends StatelessWidget {
  final Widget child;
  final void Function()? onTap;

  const CustomInkWell({required this.child, this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      overlayColor: MaterialStateProperty.all<Color>(Colors.transparent),
      child: child,
    );
  }
}
