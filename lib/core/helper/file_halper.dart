import 'dart:io';

enum UploadedFileType { image, pdf }

class PickedFileData {
  final File file;
  final UploadedFileType type;
  final String name;

  PickedFileData({
    required this.file,
    required this.type,
    required this.name,
  });
}

class FileHelper {
  static UploadedFileType getFileType(File file) {
    final extension = file.path.split('.').last.toLowerCase();
    if (['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].contains(extension)) {
      return UploadedFileType.image;
    } else if (extension == 'pdf') {
      return UploadedFileType.pdf;
    }
    return UploadedFileType.image;
  }

  static String getExtension(File file) {
    return file.path.split('.').last.toLowerCase();
  }
}