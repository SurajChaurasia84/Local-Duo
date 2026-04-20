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
      // 1. Get bytes
      Uint8List originalBytes;
      if (kIsWeb || path.startsWith('http') || path.startsWith('blob')) {
        final response = await http.get(Uri.parse(path));
        originalBytes = response.bodyBytes;
      } else {
        originalBytes = await File(path).readAsBytes();
      }

      if (originalBytes.length <= targetSizeKb * 1024) {
        return originalBytes;
      }

      // 2. Decode image
      img.Image? decodedImage = img.decodeImage(originalBytes);
      if (decodedImage == null) {
        return originalBytes;
      }

      // 3. Initial Resize if too large (Max 1280px dimension)
      if (decodedImage.width > 1280 || decodedImage.height > 1280) {
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
        compressedBytes = Uint8List.fromList(img.encodeJpg(decodedImage, quality: quality));
        
        if (compressedBytes.length <= targetSizeKb * 1024) {
          break;
        }
        
        if (compressedBytes.length > targetSizeKb * 1024 * 3) {
          quality -= 20;
        } else {
          quality -= 10;
        }
      }

      return compressedBytes;
    } catch (e) {
      debugPrint('ImageService Error: $e');
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
