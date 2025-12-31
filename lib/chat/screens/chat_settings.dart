import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram/chat/repository/chat_repository.dart';

class ChatSettings extends ConsumerStatefulWidget {
  const ChatSettings({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatSettingsState();
}

class _ChatSettingsState extends ConsumerState<ChatSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body:  Center(
        child: Column(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: CachedNetworkImageProvider(ref.read(chatDataProvider)!.isGroup
                  ? ref
                      .read(chatDataProvider)
                      !
                      .dp
                  : ref
                      .read(messageRecipientProvider)!
                      .profile
                      .dp),
            ),
          ],
        ),
      ),
    );
  }
}
