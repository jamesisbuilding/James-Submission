import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// Renders text using the design system's image title style (YesevaOne).
/// Use for titles in the expanded image view.
class ImageTitleText extends StatelessWidget {
  const ImageTitleText(
    this.data, {
    super.key,
    this.textAlign = TextAlign.center,
  });

  final String data;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      textAlign: textAlign,
      style: imageTitleTextStyle(context),
    );
  }
}
