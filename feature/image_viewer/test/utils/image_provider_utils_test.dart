import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_analysis_service/image_analysis_service.dart';
import 'package:image_viewer/src/utils/image_provider_utils.dart';

void main() {
  group('imageProviderForImage', () {
    test('returns null for null image', () {
      expect(imageProviderForImage(null), isNull);
    });

    test('returns CachedNetworkImageProvider for network URL', () {
      final image = ImageModel(
        uid: '1',
        title: 't',
        description: 'd',
        isFavourite: false,
        url: 'https://example.com/img.jpg',
        colorPalette: const [Color(0xFF000000)],
        localPath: '',
        pixelSignature: 'sig',
      );
      final provider = imageProviderForImage(image);
      expect(provider, isA<CachedNetworkImageProvider>());
      expect((provider! as CachedNetworkImageProvider).url, 'https://example.com/img.jpg');
    });

    test('returns FileImage when localPath is set and url is not network', () {
      final image = ImageModel(
        uid: '1',
        title: 't',
        description: 'd',
        isFavourite: false,
        url: '',
        colorPalette: const [Color(0xFF000000)],
        localPath: '/tmp/photo.jpg',
        pixelSignature: 'sig',
      );
      final provider = imageProviderForImage(image);
      expect(provider, isA<FileImage>());
    });

    test('returns MemoryImage when byteList is set and no network/localPath', () {
      final image = ImageModel(
        uid: '1',
        title: 't',
        description: 'd',
        isFavourite: false,
        url: '',
        colorPalette: const [Color(0xFF000000)],
        localPath: '',
        byteList: Uint8List.fromList([1, 2, 3]),
        pixelSignature: 'sig',
      );
      final provider = imageProviderForImage(image);
      expect(provider, isA<MemoryImage>());
    });

    test('returns null when url/localPath/byteList all empty', () {
      final image = ImageModel(
        uid: '1',
        title: 't',
        description: 'd',
        isFavourite: false,
        url: '',
        colorPalette: const [Color(0xFF000000)],
        localPath: '',
        pixelSignature: 'sig',
      );
      expect(imageProviderForImage(image), isNull);
    });

    test('returns null when byteList is null', () {
      final image = ImageModel(
        uid: '1',
        title: 't',
        description: 'd',
        isFavourite: false,
        url: '',
        colorPalette: const [Color(0xFF000000)],
        localPath: '',
        byteList: null,
        pixelSignature: 'sig',
      );
      expect(imageProviderForImage(image), isNull);
    });

    test('returns null when byteList is empty', () {
      final image = ImageModel(
        uid: '1',
        title: 't',
        description: 'd',
        isFavourite: false,
        url: '',
        colorPalette: const [Color(0xFF000000)],
        localPath: '',
        byteList: Uint8List(0),
        pixelSignature: 'sig',
      );
      expect(imageProviderForImage(image), isNull);
    });
  });
}
