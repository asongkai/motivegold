// web_file_picker.dart
import 'dart:js_interop';
import 'package:web/web.dart' as web;

class WebFilePicker {
  static Future<String?> pickImage() async {
    final input = web.document.createElement('input') as web.HTMLInputElement;
    input.type = 'file';
    input.accept = 'image/*';
    input.multiple = false;

    // Create a completer-like pattern using a future
    String? result;
    bool completed = false;

    input.addEventListener('change', (web.Event event) {
      final files = input.files;
      if (files != null && files.length > 0) {
        final file = files.item(0);
        if (file != null) {
          final reader = web.FileReader();
          reader.addEventListener('load', (web.Event event) {
            final readerResult = reader.result;
            if (readerResult != null) {
              // Convert JSAny to String
              result = (readerResult as JSString).toDart;
              completed = true;
            }
          }.toJS);
          reader.readAsDataURL(file);
        }
      }
    }.toJS);

    input.click();

    // Wait for file selection to complete
    while (!completed) {
      await Future.delayed(const Duration(milliseconds: 50));
    }

    return result;
  }
}