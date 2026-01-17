import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram/live%20stream/screens/start_livestream.dart';
import 'package:instagram/posts/screens/post_photos.dart';

class CreatePost extends ConsumerStatefulWidget {
  const CreatePost({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CreatePostState();
}

class _CreatePostState extends ConsumerState<CreatePost> {
  String? reelUrl;
  List<PlatformFile> selectedFiles = [];

  String? reelPath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextButton(
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                fixedSize: Size(MediaQuery.sizeOf(context).width, 60),

                backgroundColor: const Color.fromARGB(255, 1, 86, 242),
                foregroundColor: Colors.white,
              ),

              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return PostPhotos();
                    },
                  ),
                );
              },
              child: const Text(
                "Post Photos/Reels",
                style: TextStyle(fontSize: 20),
              ),
            ),
            SizedBox(height: 10),

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
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return StartLivestreamScreen();
                    },
                  ),
                );
              },
              child: const Text(
                "Start Livestream",
                style: TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
