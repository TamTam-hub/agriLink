import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseStorageService {
  final SupabaseClient _client = Supabase.instance.client;
  final String bucketName = 'product-images'; // Create this bucket (public or with RLS policies)

  /// Uploads a product image file to Supabase Storage and returns the public URL.
  /// Uses the authenticated Supabase user ID for namespacing to satisfy row-level security policies.
  Future<String> uploadProductImage({required File file}) async {
    final result = await uploadProductImageWithResult(file: file);
    return result.publicUrl;
  }

  /// Uploads and returns both the public URL and the object path for easier deletion later.
  Future<UploadedImage> uploadProductImageWithResult({required File file}) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw const StorageException('Not authenticated with Supabase');
    }
    final ext = file.path.split('.').last.toLowerCase();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.$ext';
    final objectPath = 'products/${user.id}/$fileName';

    await _client.storage.from(bucketName).upload(objectPath, file);
    final publicUrl = _client.storage.from(bucketName).getPublicUrl(objectPath);
    return UploadedImage(publicUrl: publicUrl, objectPath: objectPath);
  }

  /// Deletes an object from Supabase Storage using its public URL.
  /// If the URL is not a Supabase public URL for this bucket, this is a no-op.
  Future<void> deleteProductImageByPublicUrl(String publicUrl) async {
    try {
      final uri = Uri.parse(publicUrl);
      final path = uri.path; // e.g. /storage/v1/object/public/product-images/products/<uid>/<file>

      // Look for both public and signed URLs
      const objectMarker = '/storage/v1/object/';
      final objIdx = path.indexOf(objectMarker);
      if (objIdx == -1) return; // Not a Supabase storage URL

      final afterObject = path.substring(objIdx + objectMarker.length); // "public/product-images/..." or "sign/product-images/..."
      final bucketMarker = '$bucketName/';
      final bucketIdx = afterObject.indexOf(bucketMarker);
      if (bucketIdx == -1) return; // Not our bucket

      final rawObjectPath = afterObject.substring(bucketIdx + bucketMarker.length); // products/<uid>/<file>
      final objectPath = Uri.decodeFull(rawObjectPath);

      if (objectPath.isEmpty) return;

      await _client.storage.from(bucketName).remove([objectPath]);
    } catch (e) {
      throw StorageException('Failed to delete image: $e');
    }
  }

  /// Deletes an object directly by its object path within the bucket.
  Future<void> deleteProductImageByPath(String objectPath) async {
    try {
      if (objectPath.isEmpty) return;
      await _client.storage.from(bucketName).remove([objectPath]);
    } catch (e) {
      throw StorageException('Failed to delete image by path: $e');
    }
  }
}

class UploadedImage {
  final String publicUrl;
  final String objectPath;
  UploadedImage({required this.publicUrl, required this.objectPath});
}

class StorageException implements Exception {
  final String message;
  const StorageException(this.message);
  @override
  String toString() => 'StorageException: $message';
}