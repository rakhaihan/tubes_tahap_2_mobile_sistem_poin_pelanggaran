// lib/services/file_upload_service.dart

import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

class FileUploadService {
  final FirebaseStorage storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  Future<String> uploadEvidence(File file) async {
    final filename = "${DateTime.now().millisecondsSinceEpoch}_${p.basename(file.path)}";

    final ref = storage.ref().child("evidence/$filename");

    final upload = await ref.putFile(file);
    final url = await upload.ref.getDownloadURL();

    return url;
  }

  Future<String?> pickAndUploadImage({ImageSource source = ImageSource.gallery}) async {
    final XFile? picked = await _picker.pickImage(source: source, imageQuality: 75);
    if (picked == null) return null;
    return uploadEvidence(File(picked.path));
  }

  Future<String?> pickAndUploadFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null || result.files.single.path == null) return null;
    return uploadEvidence(File(result.files.single.path!));
  }
}
