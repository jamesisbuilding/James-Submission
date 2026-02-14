import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';

import 'abstract_share_service.dart';

const _tagline = 'I sent this from Imgo!';
const _sharePositionOrigin = Rect.fromLTWH(0, 0, 1, 1);

/// Builds share text from title, description, and tagline.
@visibleForTesting
String buildShareText({String? title, required String description}) {
  final parts = <String>[];
  if (title != null && title.isNotEmpty) parts.add(title);
  if (description.isNotEmpty) parts.add(description);
  parts.add(_tagline);
  return parts.join('\n\n');
}

/// SharePlus-based implementation of [AbstractShareService].
class ShareServiceImpl implements AbstractShareService {
  @override
  Future<void> shareImageWithDescription({
    required String description,
    String? title,
    String? imagePath,
    List<int>? imageBytes,
    String? imageMimeType,
  }) async {
    final text = buildShareText(title: title, description: description);

    XFile? file;
    if (imagePath != null &&
        imagePath.isNotEmpty &&
        await File(imagePath).exists()) {
      file = XFile(imagePath);
    } else if (imageBytes != null && imageBytes.isNotEmpty) {
      final mimeType = imageMimeType ?? 'image/jpeg';
      final ext = mimeType == 'image/png' ? 'png' : 'jpg';
      file = XFile.fromData(
        Uint8List.fromList(imageBytes),
        name: 'imgo_share.$ext',
        mimeType: mimeType,
      );
    }

    await SharePlus.instance.share(
      ShareParams(
        text: text,
        files: file != null ? [file] : null,
        sharePositionOrigin: _sharePositionOrigin,
      ),
    );
  }
}
