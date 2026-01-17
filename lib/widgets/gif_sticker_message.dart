import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class GifStickerMessage extends StatelessWidget {
  final String content;
  final String email;
  const GifStickerMessage({
    super.key,
    required this.email,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,

      decoration: BoxDecoration(
      color: Colors.red,
        image: DecorationImage(
          image: CachedNetworkImageProvider(content),
          fit: BoxFit.cover,
        ),
 
      ),
    );
  }
}
