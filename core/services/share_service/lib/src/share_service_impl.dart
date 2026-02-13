import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:share_plus/share_plus.dart';

import 'abstract_share_service.dart';

const _tagline = 'I sent this from Imgo!';
const _sharePositionOrigin = Rect.fromLTWH(0, 0, 1, 1);

/// SharePlus-based implementation of [AbstractShareService].
class ShareServiceImpl implements AbstractShareService {
  @override
  Future<void> shareImageWithDescription({
    required String description,
    String? title,
    String? imagePath,
    List<int>? imageBytes,
  }) async {
    final parts = <String>[];
    if (title != null && title.isNotEmpty) parts.add(title);
    if (description.isNotEmpty) parts.add(description);
    parts.add(_tagline);
    final text = parts.join('\n\n');

    XFile? file;
    if (imagePath != null &&
        imagePath.isNotEmpty &&
        await File(imagePath).exists()) {
      file = XFile(imagePath);
    } else if (imageBytes != null && imageBytes.isNotEmpty) {
      file = XFile.fromData(
        Uint8List.fromList(imageBytes),
        name: 'imgo_share.jpg',
        mimeType: 'image/jpeg',
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
