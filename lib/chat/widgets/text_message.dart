import 'package:flutter/material.dart';
import 'package:instagram/chat/models/message.dart';

class TextMessage extends StatelessWidget {
  final Message currMessage;
  final bool isSender;

  const TextMessage({
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

      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.76,
      ),
      decoration: BoxDecoration(
        color:
            isSender
                ? Colors.deepPurpleAccent
                : const Color.fromARGB(255, 59, 59, 59),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
          bottomLeft: Radius.circular(10),
        ),
      ),
      padding: EdgeInsets.all(10),
      child: Text(
        currMessage.content,
        style: TextStyle(fontSize: 20, color: Colors.white),
      ),
    );
  }
}
