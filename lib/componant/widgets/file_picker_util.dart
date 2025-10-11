import 'package:file_picker/file_picker.dart';
import 'package:sales_app/utils/log.dart';

class SimplePdfPicker {
  /// Pick a PDF file
  static Future<void> pickPdf({
    required Function(String filePath, String fileName) onFileSelected,
  }) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        String filePath = result.files.single.path!;
        String fileName = result.files.single.name;
        onFileSelected(filePath, fileName);
        logcat('FilePicker', 'Selected PDF: $fileName');
      } else {
        logcat('FilePicker', 'No PDF selected');
      }
    } catch (e) {
      logcat('FilePickerError', 'Failed to pick PDF: $e');
    }
  }
}
