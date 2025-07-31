import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram/posts/repository/post_repository.dart';
import 'package:instagram/utils/utils.dart';

class CreatePost extends ConsumerStatefulWidget {
  const CreatePost({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CreatePostState();
}

class _CreatePostState extends ConsumerState<CreatePost> {
  List<PlatformFile> selectedFiles = [];
  TextEditingController captionController = TextEditingController();
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
  String? reelPath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: pickFiles,
            child: const Text("Pick Images/Videos"),
          ),

          ElevatedButton(
            onPressed: () async {
              reelPath = await pickVideoFromGallery(context);

              reelUrl = await uploadVideoToCloudinary(reelPath);
              setState(() {});
            },
            child: const Text("Post Reel"),
          ),
          TextField(controller: captionController),
          Expanded(
            child: ListView.builder(
              itemCount: selectedFiles.length,
              itemBuilder: (context, index) {
                final file = selectedFiles[index];
                return ListTile(
                  title: Text(file.name),
                  subtitle: Text(file.extension ?? ''),
                );
              },
            ),
          ),
        ],
      ),
      bottomSheet: TextButton(
        onPressed: () async {
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
        },
        child: Text("Post"),
      ),
    );
  }
}
