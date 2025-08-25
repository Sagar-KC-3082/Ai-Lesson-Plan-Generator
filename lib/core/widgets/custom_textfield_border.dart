
import 'package:flutter/material.dart';

class CustomTextFieldBorder extends InputBorder {
  CustomTextFieldBorder({
    required this.borderSide,
    this.borderRadius = const BorderRadius.only(
      topRight: Radius.circular(4),
      topLeft: Radius.circular(4),
      bottomRight: Radius.circular(4),
      bottomLeft: Radius.circular(4),
    ),
    this.borderColor,
  });

  double? fapStart;
  double gapExtent = 0.0;
  double gapPercentage = 0.0;
  TextDirection? textDirection;
  Color? borderColor;
  BorderSide borderSide;

  final BorderRadius borderRadius;

  @override
  bool get isOutline => false;

  @override
  CustomTextFieldBorder copyWith(
      {BorderSide? borderSide, BorderRadius? borderRadius}) {
    return CustomTextFieldBorder(
      borderSide: borderSide ?? this.borderSide,
      borderRadius: borderRadius ?? this.borderRadius,
      borderColor: borderColor ?? Colors.grey,
    );
  }

  @override
  EdgeInsetsGeometry get dimensions {
    return EdgeInsets.only(bottom: borderSide.width);
  }

  @override
  CustomTextFieldBorder scale(double t) {
    return CustomTextFieldBorder(
      borderSide: borderSide.scale(t),
      borderColor: borderColor ?? Colors.grey,
    );
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..addRRect(borderRadius
          .resolve(textDirection)
          .toRRect(rect)
          .deflate(borderSide.width));
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return Path()..addRRect(borderRadius.resolve(textDirection).toRRect(rect));
  }

  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) {
    if (a is CustomTextFieldBorder) {
      return CustomTextFieldBorder(
        borderSide: BorderSide.lerp(a.borderSide, borderSide, t),
        borderRadius: BorderRadius.lerp(a.borderRadius, borderRadius, t)!,
        borderColor: borderColor ?? Colors.grey,
      );
    }
    return super.lerpFrom(a, t);
  }

  @override
  ShapeBorder? lerpTo(ShapeBorder? b, double t) {
    if (b is CustomTextFieldBorder) {
      return CustomTextFieldBorder(
        borderSide: BorderSide.lerp(borderSide, b.borderSide, t),
        borderRadius: BorderRadius.lerp(borderRadius, b.borderRadius, t)!,
        borderColor: borderColor ?? Colors.grey,
      );
    }
    return super.lerpTo(b, t);
  }

  /// Draw a horizontal line at the bottom of [rect].
  ///
  /// The [borderSide] defines the line's color and weight. The `textDirection`
  /// `gap` and `textDirection` parameters are ignored.
  @override
  void paint(
    Canvas canvas,
    Rect rect, {
    double? gapStart,
    double gapExtent = 0.0,
    double gapPercentage = 0.0,
    TextDirection? textDirection,
  }) {
    final Paint paint = borderSide.toPaint();
    final RRect outer = borderRadius.toRRect(rect);
    final RRect center = outer.deflate(borderSide.width / 2.0);
    paint.color = borderColor ?? Colors.grey;
    // final Path outlinePath = getOuterPath(rect);
    // canvas.drawPath(outlinePath, paint);
    canvas.drawRRect(center, paint);

    /*final Paint paint = borderSide.toPaint();
    paint.color=Colors.grey;
    final Path outlinePath = getOuterPath(rect);
    canvas.drawPath(outlinePath, paint);*/
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is InputBorder && other.borderSide == borderSide;
  }

  @override
  int get hashCode => borderSide.hashCode;
}

