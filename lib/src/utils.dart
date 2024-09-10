import 'dart:io';

import 'package:file_picker/file_picker.dart';

Future<File?> pickFile() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles();
  File? file;
  if (result != null) {
    file = File(result.files.single.path!);
  } else {
    return null;
  }
  return file;
}
