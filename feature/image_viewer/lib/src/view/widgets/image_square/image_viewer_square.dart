import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_analysis_service/image_analysis_service.dart';
import 'package:image_viewer/src/view/widgets/cached_network_image.dart';

class ImageViewerSquare extends StatelessWidget {
  final String localPath;
  final String networkPath;
  const ImageViewerSquare({
    super.key,
    required this.localPath,
    required this.networkPath,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 10,
      borderRadius: BorderRadius.circular(8),
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).cardColor,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (localPath.isNotEmpty)
              // Fallback for local file path
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(localPath),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Theme.of(context).primaryColor,
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            if (networkPath.isNotEmpty && isNetworkURL(networkPath))
              CachedImage(
                url: networkPath,
                fit: BoxFit.cover,
                borderRadius: BorderRadius.circular(12),
              ),
          ],
        ),
      ),
    );
  }
}
