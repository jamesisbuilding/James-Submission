import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_analysis_service/image_analysis_service.dart';
import 'package:shimmer/shimmer.dart';

class CachedImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BorderRadiusGeometry? borderRadius;
  final BoxFit? fit;
  const CachedImage(
      {super.key,
      required this.url,
      this.fit,
      this.width,
      this.height,
      this.borderRadius});

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty || !isNetworkURL(url)) {
      return errorWidget(width, height, borderRadius, context);
    }
    return CachedNetworkImage(
      imageUrl: url,
      imageBuilder: (context, imageProvider) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          image: DecorationImage(
            image: imageProvider,
            fit: fit,
          ),
        ),
      ),
      placeholder: (context, url) => ShimmerImage(
        width: width,
        height: height,
        borderRadius: borderRadius,
        centerWidget:  Icon(
          Icons.image,
          color: Theme.of(context).primaryColor
        ),
      ),
      errorWidget: (context, url, error) =>
          errorWidget(width, height, borderRadius,context),
    );
  }

  Widget errorWidget(
    double? width,
    double? height,
    BorderRadiusGeometry? borderRadius,
    BuildContext context, 
  ) =>
      Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          color: Theme.of(context).primaryColor
        ),
        alignment: Alignment.center,
        child:  Icon(
          Icons.image_not_supported_outlined,
          color: Theme.of(context).primaryColor
        ),
      );
}

class ShimmerImage extends StatelessWidget {
  const ShimmerImage({
    super.key,
    required this.width,
    required this.height,
    required this.borderRadius,
    this.centerWidget,
  });

  final double? width;
  final double? height;
  final BorderRadiusGeometry? borderRadius;
  final Widget? centerWidget;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color.fromARGB(255, 237, 237, 237),
      highlightColor: const Color.fromARGB(255, 255, 255, 255),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          color: Colors.white
        ),
        child: Center(child: centerWidget),
      ),
    );
  }
}
