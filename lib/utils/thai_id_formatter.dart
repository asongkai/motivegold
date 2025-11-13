import 'package:flutter/services.dart';

/// Text input formatter for Thai ID card numbers
/// Formats 13 digits as: X-XXXX-XXXXX-XX-X
class ThaiIdCardFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Remove all non-digit characters
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    
    // Limit to 13 digits
    if (digitsOnly.length > 13) {
      digitsOnly = digitsOnly.substring(0, 13);
    }
    
    // Format the digits
    String formatted = '';
    int cursorPosition = newValue.selection.end;
    int addedDashes = 0;
    
    for (int i = 0; i < digitsOnly.length; i++) {
      if (i == 1 || i == 5 || i == 10 || i == 12) {
        formatted += '-';
        if (i < cursorPosition) {
          addedDashes++;
        }
      }
      formatted += digitsOnly[i];
    }
    
    // Calculate new cursor position accounting for added dashes
    int newCursorPosition = cursorPosition + addedDashes;
    
    // Ensure cursor position is within bounds
    if (newCursorPosition > formatted.length) {
      newCursorPosition = formatted.length;
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: newCursorPosition),
    );
  }
}
