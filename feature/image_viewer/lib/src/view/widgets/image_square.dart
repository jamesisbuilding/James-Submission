import 'dart:io';

import 'package:delayed_display/delayed_display.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:image_analysis_service/image_analysis_service.dart';
import 'package:image_viewer/src/view/widgets/cached_network_image.dart';

class ImageSquare extends StatefulWidget {
  const ImageSquare({
    super.key,
    required this.image,
    this.isLoading = false,
    this.errorMessage,
    required this.selected,
    this.onTap,
    required this.disabled,
    required this.expanded,
  });

  final ImageModel image;
  final Function(bool)? onTap;
  final bool isLoading;
  final String? errorMessage;
  final bool selected;
  final bool disabled;
  final bool expanded;

  @override
  State<ImageSquare> createState() => _ImageSquareState();
}

class _ImageSquareState extends State<ImageSquare> with AnimatedPressMixin {
  @override
  void onPressComplete() {
    widget.onTap?.call(!widget.disabled);
    setState(() {});
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.selected != widget.selected) {
      setState(() {});
    }
  }

  Widget _buildImageContent(BuildContext context) {
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
            if (widget.image.localPath.isNotEmpty)
              // Fallback for local file path
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(widget.image.localPath),
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
            if (widget.image.url.isNotEmpty && isNetworkURL(widget.image.url))
              CachedImage(
                url: widget.image.url,
                fit: BoxFit.cover,
                borderRadius: BorderRadius.circular(12),
              ),

            if (widget.isLoading)
              const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            if (widget.errorMessage != null && !widget.isLoading)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    widget.errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: AnimatedOpacity(
        opacity: !widget.selected && widget.disabled ? 0 : 1,
        duration: const Duration(milliseconds: 250),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),

          height: widget.expanded ? 700 : 350,
          child: SingleChildScrollView(
            physics: widget.expanded ? null : NeverScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: .center,
              children: [
                buildPressable(
                  child: DelayedDisplay(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: _buildImageContent(context),
                      ),
                    ),
                  ),
                ),

                if (widget.expanded) ...[
                  DelayedDisplay(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12,
                      ),
                      child: Text(
                        '"${widget.image.title}"',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: .center,
                    children: List.generate(widget.image.colorPalette.length, (
                      index,
                    ) {
                      return DelayedDisplay(
                        delay: Duration(milliseconds: 100 * index),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Container(
                            height: 12,
                            width: 12,
                            decoration: BoxDecoration(
                              color: widget.image.colorPalette[index],
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),

                  DelayedDisplay(
                    delay: const Duration(milliseconds: 600),
                    slidingBeginOffset: Offset(0, 0.05),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12,
                      ),
                      child: Text(
                        widget.image.description,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
