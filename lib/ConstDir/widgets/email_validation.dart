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
