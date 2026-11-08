import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../motion/app_motion.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';

/// White rounded input used on every registration step.
///
/// The border animates between idle, focused and error states; the error
/// message itself is rendered by [FieldErrorText] under the field so it can
/// carry actions (e.g. "Register instead").
class AppTextField extends StatefulWidget {
  const AppTextField({
    required this.controller,
    required this.hint,
    this.hasError = false,
    this.prefixText,
    this.keyboardType,
    this.inputFormatters,
    this.autofillHints,
    this.textInputAction,
    this.onChanged,
    this.onFocusLost,
    this.onSubmitted,
    this.autofocus = false,
    this.fieldKey,
    super.key,
  });

  final TextEditingController controller;
  final String hint;
  final bool hasError;
  final String? prefixText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Iterable<String>? autofillHints;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFocusLost;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;

  /// Key for the inner [TextField] (used by widget tests).
  final Key? fieldKey;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocus);
  }

  void _handleFocus() {
    setState(() {});
    if (!_focusNode.hasFocus) widget.onFocusLost?.call();
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_handleFocus)
      ..dispose();
    super.dispose();
  }

  Color _borderColor(BuildContext context) {
    if (widget.hasError) return context.colors.danger;
    return _focusNode.hasFocus
        ? context.colors.primary
        : context.colors.surface;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AnimatedContainer(
      duration: context.motion(AppDurations.fast),
      curve: AppCurves.standard,
      constraints: const BoxConstraints(minHeight: AppSizes.inputHeight),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: _borderColor(context), width: 1.5),
      ),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          if (widget.prefixText != null) ...[
            Text(
              widget.prefixText!,
              style: context.text.bodyLarge?.copyWith(color: colors.textHint),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          Expanded(child: _buildField(context)),
        ],
      ),
    );
  }

  Widget _buildField(BuildContext context) => TextField(
    key: widget.fieldKey,
    controller: widget.controller,
    focusNode: _focusNode,
    autofocus: widget.autofocus,
    keyboardType: widget.keyboardType,
    inputFormatters: widget.inputFormatters,
    autofillHints: widget.autofillHints,
    textInputAction: widget.textInputAction,
    onChanged: widget.onChanged,
    onSubmitted: widget.onSubmitted,
    style: context.text.bodyLarge,
    decoration: InputDecoration(
      hintText: widget.hint,
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      filled: false,
      isCollapsed: true,
    ),
  );
}
