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

Future<String> uploadImageToCloudinary(path) async {
  try {
    final cloudinary = CloudinaryPublic(
      dotenv.env["CLOUDINARY_KEY2"]!,
      dotenv.env["CLOUDINARY_KEY1"]!,
    );

    CloudinaryResponse cloudinaryResponse = await cloudinary.uploadFile(
      CloudinaryFile.fromFile(
        path,
        resourceType: CloudinaryResourceType.Image,
        folder: FirebaseAuth.instance.currentUser!.email,
      ),
    );
    return cloudinaryResponse.secureUrl;
  } catch (e) {

    return "";
  }
}

Future<String> uploadVideoToCloudinary(path) async {
  try {
    final cloudinary = CloudinaryPublic(
      dotenv.env["CLOUDINARY_KEY2"]!,
      dotenv.env["CLOUDINARY_KEY1"]!,
    );

    CloudinaryResponse cloudinaryResponse = await cloudinary.uploadFile(
      CloudinaryFile.fromFile(
        path,
        resourceType: CloudinaryResourceType.Video,
        folder: FirebaseAuth.instance.currentUser!.email,
      ),
    );

    return cloudinaryResponse.secureUrl;
  } catch (e) {

    return "";
  }
}

Future<GiphyGif?> pickGIF(BuildContext context) async {
  try {
    GiphyGif? gif = await GiphyGet.getGif(
      context: context,
      apiKey: dotenv.env["GIPHY_KEY"]!,
      lang: GiphyLanguage.english,
      tabColor: Colors.teal,
      randomID: "123",
      debounceTimeInMilliseconds: 350,
    );
    return gif;
  } catch (e) {
    showSnackBar(context: context, content: e.toString());
  }
  return null;
}
