import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/motion/app_motion.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/validators/otp_validator.dart';

/// Six OTP boxes backed by one invisible [TextField].
///
/// One field (instead of six) gives us, for free and per platform: paste of
/// the whole code, SMS autofill (`AutofillHints.oneTimeCode`), the numeric
/// keyboard, and backspace moving back. The boxes only *render* the text;
/// the highlighted box follows the caret, so input appears to auto-advance.
class OtpCodeInput extends StatefulWidget {
  const OtpCodeInput({
    required this.code,
    required this.onChanged,
    required this.shakeCount,
    this.enabled = true,
    this.hasError = false,
    super.key,
  });

  final String code;
  final ValueChanged<String> onChanged;

  /// Shakes once each time this increases.
  final int shakeCount;
  final bool enabled;
  final bool hasError;

  @override
  State<OtpCodeInput> createState() => _OtpCodeInputState();
}

class _OtpCodeInputState extends State<OtpCodeInput>
    with SingleTickerProviderStateMixin {
  late final _controller = TextEditingController(text: widget.code);
  final _focusNode = FocusNode();
  late final _shake = AnimationController(
    vsync: this,
    duration: AppDurations.otpShake,
  );

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void didUpdateWidget(OtpCodeInput old) {
    super.didUpdateWidget(old);
    if (widget.code != _controller.text) _controller.text = widget.code;
    if (widget.shakeCount > old.shakeCount && !context.reduceMotion) {
      _shake.forward(from: 0);
      HapticFeedback.mediumImpact();
    }
    if (widget.enabled && !old.enabled) _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _shake.dispose();
    super.dispose();
  }

  /// Damped sine: three swings that fade out.
  double _shakeOffset(double t) =>
      math.sin(t * math.pi * 2 * AppMotionValues.shakeCycles) *
      AppMotionValues.shakeOffset *
      (1 - t);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.enabled ? _focusNode.requestFocus : null,
      child: AnimatedBuilder(
        animation: _shake,
        builder: (context, child) => Transform.translate(
          offset: Offset(_shakeOffset(_shake.value), 0),
          child: child,
        ),
        child: Stack(
          children: [
            _boxes(context),
            Positioned.fill(child: _hiddenField()),
          ],
        ),
      ),
    );
  }

  Widget _boxes(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      for (var i = 0; i < OtpRules.length; i++)
        _OtpBox(
          digit: i < widget.code.length ? widget.code[i] : null,
          isActive:
              _focusNode.hasFocus &&
              widget.enabled &&
              i == widget.code.length.clamp(0, OtpRules.length - 1),
          hasError: widget.hasError,
        ),
    ],
  );

  /// Transparent, but focusable and on top for long-press paste.
  Widget _hiddenField() => Opacity(
    opacity: 0,
    child: TextField(
      key: const Key('otp.field'),
      controller: _controller,
      focusNode: _focusNode,
      enabled: widget.enabled,
      autofocus: true,
      keyboardType: TextInputType.number,
      autofillHints: const [AutofillHints.oneTimeCode],
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(OtpRules.length),
      ],
      showCursor: false,
      enableInteractiveSelection: true,
      onChanged: widget.onChanged,
      decoration: const InputDecoration(
        border: InputBorder.none,
        counterText: '',
      ),
    ),
  );
}

class _OtpBox extends StatelessWidget {
  const _OtpBox({
    required this.digit,
    required this.isActive,
    required this.hasError,
  });

  final String? digit;
  final bool isActive;
  final bool hasError;

  static const _width = AppSizes.otpBoxSize;
  static const _height = AppSizes.otpBoxSize + AppSpacing.xs;

  Color _border(BuildContext context) {
    if (hasError) return context.colors.danger;
    if (isActive) return context.colors.primary;
    return context.colors.surface;
  }

  @override
  Widget build(BuildContext context) {
    final duration = context.motion(AppDurations.fast);
    return Flexible(
      child: AnimatedContainer(
        duration: duration,
        curve: AppCurves.standard,
        constraints: const BoxConstraints(maxWidth: _width, minHeight: _height),
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: _border(context), width: 1.5),
        ),
        alignment: Alignment.center,
        child: AnimatedSwitcher(
          duration: duration,
          transitionBuilder: (child, animation) =>
              ScaleTransition(scale: animation, child: child),
          child: Text(
            digit ?? '',
            key: ValueKey(digit),
            style: context.text.titleLarge,
          ),
        ),
      ),
    );
  }
}
