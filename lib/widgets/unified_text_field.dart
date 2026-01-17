import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:giphy_get/giphy_get.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:instagram/auth/models/app_user_model.dart';
import 'package:instagram/live%20stream/repository/livestream_repository.dart';
import 'package:instagram/utils/utils.dart';

class UnifiedTextField extends ConsumerStatefulWidget {
  final AppUserModel? user;
  final String hintText;
  final Function onSendMessage;
  final Function onSendGifOrSticker;
  final String? channelId;
  const UnifiedTextField({
    super.key,
    required this.user,
    required this.hintText,
    required this.onSendMessage,
    required this.onSendGifOrSticker,
    this.channelId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _UnifiedTextFieldState();
}

class _UnifiedTextFieldState extends ConsumerState<UnifiedTextField> {
  String? file;
  String? mediaFilePath;

  FocusNode focusNode = FocusNode();
  bool showEmojis = false;
  final TextEditingController messageController = TextEditingController();
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () {
                showEmojis = !showEmojis;
                if (showEmojis) {
                  focusNode.unfocus();
                } else {
                  focusNode.requestFocus();
                }
                setState(() {});
              },
              icon: Icon(Icons.emoji_emotions_outlined),
            ),
            Expanded(
              child: TextField(
                focusNode: focusNode,
                // inputFormatters: [EmojiSafeFormatter()],
                controller: messageController,
                decoration: InputDecoration(hintText: widget.hintText),
              ),
            ),

            IconButton(
              onPressed: () async {
                GiphyGif? gif = await pickGIF(context);
                if (gif != null) {
                  // await widget.onSendGifOrSticker(gif);
                  await ref
                      .read(liveStreamRepositoryProvider)
                      .sendStickerOrGif(
                        channelId: widget.channelId!,
                        email: FirebaseAuth.instance.currentUser?.email ?? "",
                        commentText: gif.images!.original!.url,
                      );

                  setState(() {});
                }
              },
              icon: Icon(Icons.gif),
            ),

            IconButton(
              icon: Icon(Icons.send),
              onPressed: () async {
                // await widget.onSendMessage();
                await ref
                    .read(liveStreamRepositoryProvider)
                    .addLivestreamComment(
                      channelId: widget.channelId!,
                      email: FirebaseAuth.instance.currentUser?.email ?? "",
                      commentText: messageController.text.trim(),
                    );
                messageController.clear();
              },
            ),
          ],
        ),
        showEmojis
            ? SizedBox(
              height: 250,
              child: EmojiPicker(
                onBackspacePressed: () {
                  final text = messageController.text;
                  final selection = messageController.selection;

                  if (selection.start <= 0) return;

                  final characters = text.characters;
                  int deleteOffset = selection.start;

                  int currentOffset = 0;
                  for (final char in characters) {
                    final nextOffset = currentOffset + char.length;
                    if (nextOffset >= deleteOffset) {
                      final newText = text.replaceRange(
                        currentOffset,
                        nextOffset,
                        '',
                      );
                      messageController.text = newText;
                      messageController.selection = TextSelection.collapsed(
                        offset: currentOffset,
                      );
                      return;
                    }
                    currentOffset = nextOffset;
                  }
                },
                onEmojiSelected: (category, emoji) {
                  final text = messageController.text;
                  final textSelection = messageController.selection;

                  // 🛡️ Prevent range error if selection is invalid
                  if (textSelection.start < 0 || textSelection.end < 0) {
                    messageController.text += emoji.emoji;
                    messageController.selection = TextSelection.collapsed(
                      offset: messageController.text.length,
                    );
                    return;
                  }

                  final newText = text.replaceRange(
                    textSelection.start,
                    textSelection.end,
                    emoji.emoji,
                  );
                  final emojiLength = emoji.emoji.length;

                  messageController.text = newText;
                  messageController.selection = textSelection.copyWith(
                    baseOffset: textSelection.start + emojiLength,
                    extentOffset: textSelection.start + emojiLength,
                  );
                },
              ),
            )
            : SizedBox.shrink(),
      ],
    );
  }
}
