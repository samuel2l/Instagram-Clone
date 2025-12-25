import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagram/auth/models/app_user_model.dart';
import 'package:instagram/chat/models/message.dart';
import 'package:instagram/chat/widgets/video_message.dart';
import 'package:instagram/utils/constants.dart';

class ReplyWidget extends StatelessWidget {
  final bool isSender;
  final bool isMyReplyMessage;
  final Message currMessage;
  final  Map<String, AppUserModel> participantData;
  final AppUserModel? user;
  final bool isGroup ;
  const ReplyWidget({super.key, required this.isSender, required this.isMyReplyMessage, required this.currMessage, required this.participantData, this.user, required this.isGroup});

  @override
  Widget build(BuildContext context) {
    return  Container(
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
            isMyReplyMessage
                ? Colors.deepPurpleAccent
                : const Color.fromARGB(255, 59, 59, 59),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
          bottomLeft: Radius.circular(10),
        ),
      ),
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          user!=null?
          Text(
            isMyReplyMessage
                ? "Me"
                : isGroup
                ? participantData[currMessage.senderId]!.profile.name
                : user!.profile.name,
          ):SizedBox.shrink(),
          currMessage.replyType == image || currMessage.replyType == GIF
              ? SizedBox(
                height: 70,
                width: 70,
                child: CachedNetworkImage(imageUrl: currMessage.reply),
              )
              : currMessage.replyType == video
              ? SizedBox(
                height: 70,
                width: 70,
                child: VideoMessage(
                  url: currMessage.reply,
                  isSender: currMessage.repliedTo == "Me" ? true : false,
                ),
              )
              : Text(currMessage.reply),
        ],
      ),
    );
  }
}
