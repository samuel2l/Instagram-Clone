import 'dart:io';

import 'package:flutter/material.dart';
import 'package:instagram/stories/screens/post_story.dart';
import 'package:instagram/utils/utils.dart';

class SelectStoryImage extends StatefulWidget {
  const SelectStoryImage({super.key});

  @override
  State<SelectStoryImage> createState() => _SelectStoryImageState();
}

class _SelectStoryImageState extends State<SelectStoryImage> {
  File? _imageFile;
  String? imgString;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: IconButton(
          onPressed: () async {
            imgString = await pickImageFromGallery(context) ;
            if(imgString!=null||imgString!.isEmpty){
            _imageFile=File(imgString!);

            }
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) {
                  return StoryEditor(selectedImage: _imageFile);
                },
              ),
            );
          },
          icon: Icon(Icons.camera),
        ),
      ),
    );
  }
}
