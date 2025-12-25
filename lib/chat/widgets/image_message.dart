import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagram/chat/models/message.dart';

class ImageMessage extends StatelessWidget {
  final Message currMessage;
  final bool isSender;
  const ImageMessage({
    super.key,
    required this.currMessage,
    required this.isSender,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        right: isSender ? 3 : 0,
        bottom: 2,
        left: !isSender ? 3 : 0,
      ),

      height: 350,
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.55,
      ),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: CachedNetworkImageProvider(currMessage.content),
          fit: BoxFit.cover,
        ),
        color:
            isSender
                ? Colors.deepPurpleAccent
                : const Color.fromARGB(255, 59, 59, 59),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(10),
        ),
      ),

    );
  }
}
