import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

/// 6-digit separate OTP input field widget with auto-focus advance and backspace support.
class OtpInputField extends StatefulWidget {
  final ValueChanged<String> onCompleted;
  final ValueChanged<String>? onChanged;

  const OtpInputField({
    super.key,
    required this.onCompleted,
    this.onChanged,
  });

  @override
  State<OtpInputField> createState() => _OtpInputFieldState();
}

class _OtpInputFieldState extends State<OtpInputField> {
  final int _length = 6;
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers =
        List.generate(_length, (index) => TextEditingController());
    _focusNodes = List.generate(_length, (index) => FocusNode());
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _currentOtp => _controllers.map((c) => c.text).join();

  void _onDigitChanged(int index, String value) {
    if (value.isNotEmpty) {
      // If user pasted multi-character code
      if (value.length > 1) {
        final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
        for (int i = 0; i < _length && i < digits.length; i++) {
          _controllers[i].text = digits[i];
        }
        final finalOtp = _currentOtp;
        widget.onChanged?.call(finalOtp);
        if (finalOtp.length == _length) {
          widget.onCompleted(finalOtp);
          _focusNodes.last.unfocus();
        }
        return;
      }

      // Move focus to next box
      if (index < _length - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    }

    final finalOtp = _currentOtp;
    widget.onChanged?.call(finalOtp);
    if (finalOtp.length == _length) {
      widget.onCompleted(finalOtp);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final boxSize = ((totalWidth - ((_length - 1) * 8)) / _length)
            .clamp(40.0, 52.0);

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(_length, (index) {
            final isFilled = _controllers[index].text.isNotEmpty;

            return SizedBox(
              width: boxSize,
              height: boxSize * 1.15,
              child: KeyboardListener(
                focusNode: FocusNode(),
                onKeyEvent: (event) {
                  if (event is KeyDownEvent &&
                      event.logicalKey == LogicalKeyboardKey.backspace &&
                      _controllers[index].text.isEmpty &&
                      index > 0) {
                    _focusNodes[index - 1].requestFocus();
                  }
                },
                child: TextField(
                  controller: _controllers[index],
                  focusNode: _focusNodes[index],
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 1,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: InputDecoration(
                    counterText: '',
                    filled: true,
                    fillColor: isFilled
                        ? AppColors.lightGreen
                        : AppColors.surface,
                    contentPadding: EdgeInsets.zero,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: isFilled
                            ? AppColors.freshGreen
                            : AppColors.border,
                        width: isFilled ? 1.5 : 1.2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 2.0,
                      ),
                    ),
                  ),
                  onChanged: (value) => _onDigitChanged(index, value),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
