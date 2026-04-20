import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:io' show File;

class ImageService {
  /// Compresses an image to be below the target size in KB.
  /// Works across Web, Android, and iOS.
  static Future<Uint8List> compressToTarget(String path, {int targetSizeKb = 100}) async {
    try {
      debugPrint('ImageService: Starting compression for $path');
      
      // 1. Get bytes
      Uint8List originalBytes;
      if (kIsWeb || path.startsWith('http') || path.startsWith('blob')) {
        final response = await http.get(Uri.parse(path));
        originalBytes = response.bodyBytes;
      } else {
        originalBytes = await File(path).readAsBytes();
      }

      debugPrint('ImageService: Original size: ${originalBytes.length / 1024} KB');

      if (originalBytes.length <= targetSizeKb * 1024) {
        debugPrint('ImageService: Already small enough, skipping compression.');
        return originalBytes;
      }

      // 2. Decode image
      img.Image? decodedImage = img.decodeImage(originalBytes);
      if (decodedImage == null) {
        debugPrint('ImageService: Error decoding image, returning original.');
        return originalBytes;
      }

      // 3. Initial Resize if too large (Max 1280px dimension)
      // This helps significantly before quality reduction
      if (decodedImage.width > 1280 || decodedImage.height > 1280) {
        debugPrint('ImageService: Resizing down from ${decodedImage.width}x${decodedImage.height}');
        decodedImage = img.copyResize(
          decodedImage,
          width: decodedImage.width > decodedImage.height ? 1280 : null,
          height: decodedImage.height >= decodedImage.width ? 1280 : null,
          interpolation: img.Interpolation.linear,
        );
      }

      // 4. Iterative compression
      int quality = 85;
      Uint8List compressedBytes = originalBytes;
      
      while (quality > 5) {
        debugPrint('ImageService: Trying quality $quality...');
        compressedBytes = Uint8List.fromList(img.encodeJpg(decodedImage, quality: quality));
        
        debugPrint('ImageService: Resulting size: ${compressedBytes.length / 1024} KB');
        
        if (compressedBytes.length <= targetSizeKb * 1024) {
          debugPrint('ImageService: Target size reached at quality $quality');
          break;
        }
        
        // Reduce quality more aggressively if we're way above target
        if (compressedBytes.length > targetSizeKb * 1024 * 3) {
          quality -= 20;
        } else {
          quality -= 10;
        }
      }

      return compressedBytes;
    } catch (e) {
      debugPrint('ImageService Error: $e');
      // Fallback: search for bytes again in case parsing failed partially
      try {
        if (kIsWeb || path.startsWith('http')) {
           final response = await http.get(Uri.parse(path));
           return response.bodyBytes;
        } else {
           return await File(path).readAsBytes();
        }
      } catch (_) {
        return Uint8List(0);
      }
    }
  }
}
