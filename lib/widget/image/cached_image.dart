import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CachedImage extends StatelessWidget {
  final String? imageUrl;
  final bool? isRound;
  final double? radius;
  final double? height;
  final double? width;
  bool? isVideo = false;
  final BoxFit? fit;

  final String noImageAvailable =
      "assets/images/no_image.png";

  final String noThumbnailAvailable =
      "https://firebasestorage.googleapis.com/v0/b/ocwa-app.appspot.com/o/default.png?alt=media&token=c7feffc9-ec84-47a7-8f30-733b3d7dc583";

  CachedImage(this.imageUrl,
      {this.isRound = false,
      this.radius = 0,
      this.height,
      this.width,
      this.fit = BoxFit.cover,
      this.isVideo});

  @override
  Widget build(BuildContext context) {
    try {
      return SizedBox(
        height: isRound != null ? radius : height,
        width: isRound != null ? radius : width,
        child: ClipRRect(
            borderRadius: BorderRadius.circular(isRound != null ? 50 : radius!),
            child: CachedNetworkImage(
              imageUrl: imageUrl!,
              fit: fit,
              placeholder: (context, url) =>
                  const Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => Image.asset(
                noImageAvailable,
                height: 25,
                width: 25,
                fit: BoxFit.cover,
              ),
            )),
      );
    } catch (e) {
      return Image.asset(
        noImageAvailable,
        height: 25,
        width: 25,
        fit: BoxFit.cover,
      );
    }
  }
}
