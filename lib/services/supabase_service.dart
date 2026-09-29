import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';

class SupabaseService {
  static SupabaseClient get client =>
      Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      publishableKey: SupabaseConfig.publishableKey,
    );
  }

  // ============================================================
  // UPLOAD HOSPITAL DOCUMENT
  // ============================================================

  static Future<String> uploadHospitalDocument({
    required String elderId,
    required String fileName,
    required Uint8List bytes,
    required String contentType,
  }) async {
    final safeFileName =
        _sanitizeFileName(fileName);

    final timestamp =
        DateTime.now().millisecondsSinceEpoch;

    final filePath =
        '$elderId/${timestamp}_$safeFileName';

    await client.storage
        .from('hospital-documents')
        .uploadBinary(
          filePath,
          bytes,
          fileOptions: FileOptions(
            contentType: contentType,
            upsert: false,
          ),
        );

    return filePath;
  }

  // ============================================================
  // GET DOCUMENT URL
  // ============================================================

  static String getHospitalDocumentUrl(
    String filePath,
  ) {
    return client.storage
        .from('hospital-documents')
        .getPublicUrl(filePath);
  }

  // ============================================================
  // DELETE DOCUMENT
  // ============================================================

  static Future<void> deleteHospitalDocument(
    String filePath,
  ) async {
    if (filePath.trim().isEmpty) {
      return;
    }

    await client.storage
        .from('hospital-documents')
        .remove([filePath]);
  }

  // ============================================================
  // FILE NAME SANITIZER
  // ============================================================

  static String _sanitizeFileName(
    String fileName,
  ) {
    return fileName.replaceAll(
      RegExp(r'[^a-zA-Z0-9._-]'),
      '_',
    );
  }
}