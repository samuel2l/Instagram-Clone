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
      // margin: EdgeInsets.only(
      //   right: isSender ? 3 : 0,
      //   bottom: 2,
      //   left: !isSender ? 3 : 0,
      // ),
      height: 150,
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.3,
      ),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: CachedNetworkImageProvider(content),
          fit: BoxFit.cover,
        ),
        // color:
        //     isSender
        //         ? Colors.deepPurpleAccent
        //         : const Color.fromARGB(255, 59, 59, 59),
        // borderRadius: BorderRadius.only(
        //   topLeft: Radius.circular(30),
        //   topRight: Radius.circular(30),
        //   bottomLeft: Radius.circular(30),
        //   bottomRight: Radius.circular(10),
        // ),
      ),
    );
  }
}
