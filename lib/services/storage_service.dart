// lib/services/storage_service.dart
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Sube un archivo a una ruta específica y retorna la URL de descarga
  Future<String> uploadFile(File file, String folder) async {
    try {
      final String fileName = path.basename(file.path);
      // Creamos un nombre único con timestamp para evitar colisiones
      final String uniqueName =
          '${DateTime.now().millisecondsSinceEpoch}_$fileName';
      final String destination = '$folder/$uniqueName';

      final Reference ref = _storage.ref(destination);
      final UploadTask task = ref.putFile(file);

      // Esperamos a que termine la subida
      final TaskSnapshot snapshot = await task;

      // Obtenemos la URL pública
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error en StorageService: $e');
      rethrow;
    }
  }

  /// Elimina un archivo si es necesario (ej. al borrar un documento)
  Future<void> deleteFile(String fileUrl) async {
    try {
      final Reference ref = _storage.refFromURL(fileUrl);
      await ref.delete();
    } catch (e) {
      // Si falla (ej. archivo no existe), solo logueamos
      print('Error al eliminar archivo: $e');
    }
  }
}
