import 'dart:io';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart'; // ✅ [إضافة]
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:optialeader/core/helper/file_halper.dart';

class FilePickerField extends StatelessWidget {
  final String label;
  final PickedFileData? selectedFile;
  final ValueChanged<PickedFileData?> onFileSelected;
  final bool isRequired;
  final bool allowImage;
  final bool allowPdf;

  const FilePickerField({
    super.key,
    required this.label,
    this.selectedFile,
    required this.onFileSelected,
    this.isRequired = false,
    this.allowImage = true,
    this.allowPdf = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87),
            children: [
              if (isRequired)
                const TextSpan(text: ' *', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _showFilePickerOptions(context),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: selectedFile != null ? Colors.blue : Colors.grey.shade400,
                width: selectedFile != null ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
              color: selectedFile != null ? Colors.blue.shade50 : Colors.grey.shade50,
            ),
            child: selectedFile != null ? _buildSelectedFilePreview() : _buildEmptyState(),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        Icon(Icons.cloud_upload_outlined, size: 40, color: Colors.grey.shade500),
        const SizedBox(height: 8),
        // ✅ [تعديل]
        Text('file_picker.select_file'.tr(), style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
        const SizedBox(height: 4),
        Text(
          allowImage && allowPdf 
              ? 'file_picker.image_or_pdf'.tr() 
              : (allowImage ? 'file_picker.image_only'.tr() : 'file_picker.pdf_only'.tr()),
          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildSelectedFilePreview() {
    return Column(
      children: [
        if (selectedFile!.type == UploadedFileType.image)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(selectedFile!.file, height: 120, width: double.infinity, fit: BoxFit.cover),
          )
        else
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                Icon(Icons.picture_as_pdf, color: Colors.red.shade700, size: 36),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selectedFile!.name,
                    style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.w500),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                selectedFile!.name, 
                style: const TextStyle(fontSize: 12, color: Colors.grey), 
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 20, color: Colors.red),
              onPressed: () => onFileSelected(null),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ],
    );
  }

  void _showFilePickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              // ✅ [تعديل]
              Text('file_picker.choose_upload_method'.tr(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              if (allowImage) ...[
                ListTile(
                  leading: Icon(Icons.camera_alt, color: Colors.blue.shade700),
                  title: Text('file_picker.take_photo'.tr()), // ✅
                  onTap: () { Navigator.pop(context); _pickFromCamera(); },
                ),
                ListTile(
                  leading: Icon(Icons.photo_library, color: Colors.blue.shade700),
                  title: Text('file_picker.choose_from_gallery'.tr()), // ✅
                  onTap: () { Navigator.pop(context); _pickFromGallery(); },
                ),
              ],
              if (allowPdf)
                ListTile(
                  leading: Icon(Icons.picture_as_pdf, color: Colors.red.shade700),
                  title: Text('file_picker.choose_pdf'.tr()), // ✅
                  onTap: () { Navigator.pop(context); _pickPdf(); },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickFromCamera() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    if (xFile != null) {
      final file = File(xFile.path);
      onFileSelected(PickedFileData(file: file, type: UploadedFileType.image, name: xFile.name));
    }
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (xFile != null) {
      final file = File(xFile.path);
      onFileSelected(PickedFileData(file: file, type: UploadedFileType.image, name: xFile.name));
    }
  }

  Future<void> _pickPdf() async {
    final result = await FilePicker.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      onFileSelected(PickedFileData(file: file, type: UploadedFileType.pdf, name: result.files.single.name));
    }
  }
}