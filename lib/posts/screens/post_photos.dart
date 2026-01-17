import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:instagram/posts/repository/post_repository.dart';
import 'package:instagram/utils/utils.dart';

class PostPhotos extends ConsumerStatefulWidget {
  const PostPhotos({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PostPhotosState();
}

class _PostPhotosState extends ConsumerState<PostPhotos> {
  List<PlatformFile> selectedFiles = [];
  TextEditingController captionController = TextEditingController();
  bool showEmojis = false;
  bool isProcessing = false;
  bool isReelProcessing = false;
  Future<void> pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.media,
    );

    if (result != null) {
      setState(() {
        selectedFiles = result.files;
      });
    } else {
      // User canceled the picker
    }
  }

  String? reelUrl;
  FocusNode focusNode = FocusNode();

  String? reelPath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                Text("eiiiii"),
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
                    controller: captionController,
                    decoration: InputDecoration(hintText: "add a caption..."),
                  ),
                ),
              ],
            ),
            showEmojis
                ? SizedBox(
                  height: 250,
                  child: EmojiPicker(
                    onBackspacePressed: () {
                      final text = captionController.text;
                      final selection = captionController.selection;

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
                          captionController.text = newText;
                          captionController.selection = TextSelection.collapsed(
                            offset: currentOffset,
                          );
                          return;
                        }
                        currentOffset = nextOffset;
                      }
                    },
                    onEmojiSelected: (category, emoji) {
                      final text = captionController.text;
                      final textSelection = captionController.selection;

                      // 🛡️ Prevent range error if selection is invalid
                      if (textSelection.start < 0 || textSelection.end < 0) {
                        captionController.text += emoji.emoji;
                        captionController.selection = TextSelection.collapsed(
                          offset: captionController.text.length,
                        );
                        return;
                      }

                      final newText = text.replaceRange(
                        textSelection.start,
                        textSelection.end,
                        emoji.emoji,
                      );
                      final emojiLength = emoji.emoji.length;

                      captionController.text = newText;
                      captionController.selection = textSelection.copyWith(
                        baseOffset: textSelection.start + emojiLength,
                        extentOffset: textSelection.start + emojiLength,
                      );
                    },
                  ),
                )
                : SizedBox.shrink(),

            TextButton(
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                fixedSize: Size(MediaQuery.sizeOf(context).width, 60),

                backgroundColor: const Color.fromARGB(255, 1, 86, 242),
                foregroundColor: Colors.white,
              ),

              onPressed: pickFiles,
              child: Text("pick photos", style: TextStyle(fontSize: 20)),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: selectedFiles.length,
                itemBuilder: (context, index) {
                  final file = selectedFiles[index];
                  return ListTile(
                    title: Text(file.name),
                    subtitle: Text(file.extension ?? ''),
                    trailing: IconButton(
                      onPressed: () {
                        selectedFiles.remove(selectedFiles[index]);
                        setState(() {});
                      },
                      icon: Icon(Icons.delete),
                    ),
                  );
                },
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                fixedSize: Size(MediaQuery.sizeOf(context).width, 60),

                backgroundColor: const Color.fromARGB(255, 1, 86, 242),
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                isReelProcessing = true;
                setState(() {});
                reelPath = await pickVideoFromGallery(context);
                reelUrl = await uploadVideoToCloudinary(reelPath);
                setState(() {});

                if (reelPath!.isNotEmpty && reelUrl!.isNotEmpty) {
                  await ref
                      .read(postRepositoryProvider)
                      .createPost(
                        caption: captionController.text.trim(),
                        imageUrls: [reelUrl!],
                        context: context,
                        postType: "reel",
                      );
                }
                isReelProcessing = false;
                setState(() {});
                captionController.clear();
              },
              child:
                  !isReelProcessing
                      ? Text("Create Reel", style: TextStyle(fontSize: 20))
                      : Center(child: CircularProgressIndicator()),
            ),
            SizedBox(height: 20),

            TextButton(
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                fixedSize: Size(MediaQuery.sizeOf(context).width, 60),

                backgroundColor: const Color.fromARGB(255, 1, 86, 242),
                foregroundColor: Colors.white,
              ),

              onPressed: () async {
                isProcessing = true;
                setState(() {});

                if (captionController.text.isEmpty) {
                  showSnackBar(context: context, content: "add a caption");
                } else {
                  if (reelUrl != null) {
                    await ref
                        .read(postRepositoryProvider)
                        .createPost(
                          caption: captionController.text.trim(),
                          imageUrls: [reelUrl!],
                          context: context,
                          postType: "reel",
                        );
                  } else {
                    if (selectedFiles.isNotEmpty) {
                      String mediaPath = "";
                      List<String> mediaUrls = [];
                      for (int i = 0; i < selectedFiles.length; i++) {
                        if (selectedFiles[i].extension != "jpeg" &&
                            selectedFiles[i].extension != "png" &&
                            selectedFiles[i].extension != "jpg") {
                          mediaPath = await uploadVideoToCloudinary(
                            selectedFiles[i].path,
                          );
                        } else {
                          mediaPath = await uploadImageToCloudinary(
                            selectedFiles[i].path,
                          );
                        }
                        mediaUrls.add(mediaPath);
                      }
                      ref
                          .read(postRepositoryProvider)
                          .createPost(
                            caption: captionController.text.trim(),
                            imageUrls: mediaUrls,
                            context: context,
                          );
                    }
                  }
                }
                isProcessing = false;
                setState(() {});
                captionController.clear();
                Navigator.pop(context);
              },
              child:
                  !isProcessing
                      ? Text("Post", style: TextStyle(fontSize: 20))
                      : Center(child: CircularProgressIndicator()),
            ),
          ],
        ),
      ),
    );
  }
}
