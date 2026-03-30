import 'package:flutter/services.dart';

class SingleAtEmailInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = newValue.text;

    final allowedRegExp = RegExp(r'^[a-zA-Z0-9@._]*$');
    if (!allowedRegExp.hasMatch(newText)) {
      return oldValue;
    }

    int atCount = '@'.allMatches(newText).length;
    if (atCount > 1) {
      return oldValue;
    }

    // Allow only one '.com'
    int dotComCount = '.com'.allMatches(newText.toLowerCase()).length;
    if (dotComCount > 1) {
      return oldValue;
    }

    return newValue;
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
    );
  }
}

// ─── Text formatters ──────────────────────────────────────────────────────────

/// Formats Aadhaar as XXXX XXXX XXXX
class AadhaarInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue old, TextEditingValue next) {
    final digits = next.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i == 4 || i == 8) buffer.write(' ');
      buffer.write(digits[i]);
    }
    final str = buffer.toString();
    return next.copyWith(
      text: str,
      selection: TextSelection.collapsed(offset: str.length),
    );
  }
}
