import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

/// Computes SHA256 hash in isolate. Returns hash string or null if duplicate.
/// Input: (bytes, existingHashes)
({String? hash, bool isDuplicate}) hashAndCheckDuplicate(
  (Uint8List bytes, List<String> existingHashes) input,
) {
  final (bytes, existingHashes) = input;
  final hash = sha256.convert(bytes).toString();
  final isDuplicate =
      existingHashes.any((h) => h == hash);
  return (hash: isDuplicate ? null : hash, isDuplicate: isDuplicate);
}

/// Fetches image bytes from URL in isolate. Pure Dart, no Flutter.
Future<Uint8List?> fetchImageBytesInIsolate(String url) async {
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    }
  } catch (_) {}
  return null;
}
