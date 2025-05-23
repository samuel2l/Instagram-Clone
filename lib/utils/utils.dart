import 'package:cloudinary_public/cloudinary_public.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:giphy_get/giphy_get.dart';
import 'package:image_picker/image_picker.dart';

void showSnackBar({required BuildContext context, required String content}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(content)));
}

Future<String?> pickImageFromGallery(BuildContext context) async {
  try {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    return pickedImage?.path ?? "";
  } catch (e) {
    showSnackBar(context: context, content: e.toString());
  }
  return "";
}

Future<String?> pickVideoFromGallery(BuildContext context) async {
  try {
    final pickedVideo = await ImagePicker().pickVideo(
      source: ImageSource.gallery,
    );
    return pickedVideo?.path ?? "";
  } catch (e) {
    showSnackBar(context: context, content: e.toString());
  }
  return "";
}

Future<String> uploadToCloudinary(path) async {
  final cloudinary = CloudinaryPublic(
    dotenv.env["CLOUDINARY_KEY1"]!,
    dotenv.env["CLOUDINARY_KEY2"]!,
  );

  CloudinaryResponse cloudinaryResponse = await cloudinary.uploadFile(
    CloudinaryFile.fromFile(
      path,
      resourceType: CloudinaryResourceType.Video,
      folder: FirebaseAuth.instance.currentUser!.email,
    ),
  );
  return cloudinaryResponse.secureUrl;
}

Future<GiphyGif?> pickGIF(BuildContext context) async {
  try {
    GiphyGif? gif = await GiphyGet.getGif(
      context: context, //Required
      apiKey: dotenv.env["GIPHY_KEY"]!, //Required.
      lang: GiphyLanguage.english, //Optional - Language for query.
      tabColor: Colors.teal, // Optional- default accent color.
      randomID: "123",
      debounceTimeInMilliseconds:
          350, // Optional- time to pause between search keystrokes
    );
      return gif;

  } catch (e) {
    showSnackBar(context: context, content: e.toString());
  }
  return null;
}
