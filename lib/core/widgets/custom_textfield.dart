import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/color_constants.dart';
import 'custom_textfield_border.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField({
    required this.controller,
    this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.borderColor,
    this.fillColor,
    this.labelStyle,
    this.validator,
    this.onSaved,
    this.onChanged,
    this.autoValidateMode,
    this.focusNode,
    this.inputTextStyle,
    this.obscureText = false,
    this.onEditingComplete,
    this.maxLines,
    this.maxLength,
    this.onFieldSubmitted,
    this.textInputAction,
    this.keyboardType,
    this.focusedBorderSideColor,
    this.autoFocus = false,
    this.inputFormatters,
    this.focusedErrorBorder,
    this.errorBorder,
    this.focusBorder,
    this.prefixText,
    this.prefixTextStyle,
    this.isEnabled = true,
    this.cursorHeight,
    this.cursorColor,
    this.borderRadiusValue,
    this.borderRadius,
    this.hintStyle,
    this.hintText,
    this.showCursor,
    this.contentPadding,
    this.border,
    this.enabledBorder,
    this.autofillHints,
    this.textCapitalization,
    this.decoration,
    this.counterText,
    this.counterTextStyle,
    this.isDense,
    this.isReadOnly,
    this.onTap,
    super.key,
  });

  final InputDecoration? decoration;
  final String? labelText;
  final TextEditingController controller;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Color? borderColor;
  final Color? fillColor;
  final TextStyle? labelStyle;
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;
  final void Function(String?)? onChanged;
  final AutovalidateMode? autoValidateMode;
  final FocusNode? focusNode;
  final TextStyle? inputTextStyle;
  final bool obscureText;
  final VoidCallback? onEditingComplete;
  final int? maxLines;
  final int? maxLength;
  final void Function(String?)? onFieldSubmitted;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final Color? focusedBorderSideColor;
  final bool autoFocus;
  final List<TextInputFormatter>? inputFormatters;
  final InputBorder? focusedErrorBorder;
  final InputBorder? errorBorder;
  final InputBorder? focusBorder;
  final String? prefixText;
  final TextStyle? prefixTextStyle;
  final bool isEnabled;
  final double? cursorHeight;
  final Color? cursorColor;
  final double? borderRadiusValue;
  final double? borderRadius;
  final String? hintText;
  final TextStyle? hintStyle;
  final bool? showCursor;
  final EdgeInsetsGeometry? contentPadding;
  final InputBorder? border;
  final InputBorder? enabledBorder;
  final Iterable<String>? autofillHints;
  final TextCapitalization? textCapitalization;
  final String? counterText;
  final TextStyle? counterTextStyle;
  final bool? isDense;
  final bool? isReadOnly;
  final void Function()? onTap;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _isTextObscure = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        onTap: widget.onTap,
        autofillHints: widget.autofillHints,
        textCapitalization:
            widget.textCapitalization ?? TextCapitalization.sentences,
        showCursor: widget.showCursor,
        enabled: widget.isEnabled,
        inputFormatters: widget.inputFormatters,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction ?? TextInputAction.next,
        onSaved: widget.onSaved,
        onFieldSubmitted: widget.onFieldSubmitted,
        maxLength: widget.maxLength,
        onEditingComplete: widget.onEditingComplete,
        obscureText: widget.obscureText ? _isTextObscure : false,
        style: widget.inputTextStyle ?? Theme.of(context).textTheme.bodyMedium,
        focusNode: widget.focusNode,
        onChanged: widget.onChanged,
        validator: widget.validator,
        cursorHeight: widget.cursorHeight ?? 22,
        cursorRadius: const Radius.circular(10),
        controller: widget.controller,
        autofocus: widget.autoFocus,
        readOnly: widget.isReadOnly ?? false,
        decoration: widget.decoration ??
            InputDecoration(
              isDense: widget.isDense,
              contentPadding: widget.contentPadding,
              suffixIcon: (widget.obscureText)
                  ? InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () {
                        setState(() {
                          _isTextObscure = !_isTextObscure;
                        });
                      },
                      child: _isTextObscure
                          ? const Icon(
                              Icons.remove_red_eye,
                              color: Colors.red,
                            )
                          : const Icon(
                              Icons.visibility_off,
                              color: Colors.red,
                            ),
                    )
                  : widget.suffixIcon,
              prefixIcon: widget.prefixIcon,
              fillColor: widget.fillColor ?? ColorConstant.textFieldColor,
              filled: true,
              counterText: widget.counterText,
              counterStyle: widget.counterTextStyle ??
                  Theme.of(context).textTheme.bodySmall,
              errorBorder: widget.errorBorder ??
                  CustomTextFieldBorder(
                    borderRadius:
                        BorderRadius.circular(widget.borderRadius ?? 8),
                    borderSide: BorderSide(
                      color: widget.focusedBorderSideColor ??
                          ColorConstant.textFieldColor,
                    ),
                    borderColor: Colors.red,
                  ),
              enabledBorder: widget.enabledBorder ??
                  CustomTextFieldBorder(
                    borderRadius:
                        BorderRadius.circular(widget.borderRadius ?? 8),
                    borderSide: BorderSide(
                      color: widget.borderColor ?? ColorConstant.textFieldColor,
                    ),
                    borderColor: widget.borderColor ?? Colors.transparent,
                  ),
              errorStyle: const TextStyle(color: Colors.red, fontSize: 10),
              focusedBorder: widget.focusBorder ??
                  CustomTextFieldBorder(
                    borderRadius:
                        BorderRadius.circular(widget.borderRadius ?? 8),
                    borderSide: BorderSide(
                      color: widget.borderColor ?? ColorConstant.textFieldColor,
                    ),
                    borderColor: widget.borderColor ?? Colors.transparent,
                  ),
              focusedErrorBorder: widget.focusedErrorBorder ??
                  CustomTextFieldBorder(
                    borderRadius:
                        BorderRadius.circular(widget.borderRadius ?? 8),
                    borderSide: BorderSide(
                      color: widget.focusedBorderSideColor ??
                          ColorConstant.textFieldColor,
                    ),
                    borderColor: Colors.red,
                  ),
              disabledBorder: CustomTextFieldBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius ?? 8),
                borderSide: BorderSide(
                  color: widget.focusedBorderSideColor ??
                      ColorConstant.textFieldColor,
                ),
                borderColor: Colors.transparent,
              ),
              hintText: widget.hintText,
              hintStyle: widget.hintStyle ??
                  Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(color: const Color(0xFFa3a1a3)),
              labelText: widget.labelText,
              prefixText: widget.prefixText,
              prefixStyle: widget.prefixTextStyle ??
                  Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey,
                      ),
              labelStyle: widget.labelStyle ??
                  Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(color: Colors.grey),
            ),
        maxLines: widget.maxLines ?? 1,
        // onTap: onTapFunction,
      ),
    );
  }
}

