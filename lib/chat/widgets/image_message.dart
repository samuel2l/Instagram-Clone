import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagram/chat/models/message.dart';

class ImageMessage extends StatelessWidget {
  final Message currMessage;
  final bool isSender;
  const ImageMessage({super.key, required this.currMessage, required this.isSender});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5),
      color:
          isSender
              ? Colors.deepPurpleAccent
              : const Color.fromARGB(255, 59, 59, 59),
      height: 350,

      child: CachedNetworkImage(
        imageUrl: currMessage.content,
        placeholder:
            (context, url) => Center(child: CircularProgressIndicator()),
        errorWidget: (context, url, error) => Icon(Icons.error),
      ),
    );
  }
}
