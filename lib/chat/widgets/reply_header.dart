// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ReplyHeader extends StatefulWidget {
  const ReplyHeader({super.key, required this.messageToReply});
  final Map<String, dynamic> messageToReply;

  @override
  State<ReplyHeader> createState() => _ReplyHeaderState();
}

class _ReplyHeaderState extends State<ReplyHeader> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.lightGreenAccent,
      width: double.infinity,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.messageToReply["senderId"] ==
                        FirebaseAuth.instance.currentUser?.uid
                    ? "Me"
                    : widget.messageToReply["senderId"],
              ),
              IconButton(onPressed: () {}, icon: Icon(Icons.close)),
            ], 
          ),
          Text(widget.messageToReply["text "])
        ],
      ),
    );
  }
}
