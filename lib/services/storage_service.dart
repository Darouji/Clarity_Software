// lib/services/storage_service.dart
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart'
    as path; // Ahora funciona gracias al pubspec.yaml
import 'package:flutter/foundation.dart'; // Para debugPrint

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadFile(File file, String folder) async {
    try {
      final String fileName = path.basename(file.path);
      final String uniqueName =
          '${DateTime.now().millisecondsSinceEpoch}_$fileName';
      final String destination = '$folder/$uniqueName';

      final Reference ref = _storage.ref(destination);
      final UploadTask task = ref.putFile(file);
      final TaskSnapshot snapshot = await task;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      debugPrint('Error en StorageService: $e');
      rethrow;
    }
  }

  Future<void> deleteFile(String fileUrl) async {
    try {
      final Reference ref = _storage.refFromURL(fileUrl);
      await ref.delete();
    } catch (e) {
      debugPrint('Error al eliminar archivo: $e');
    }
  }
}
