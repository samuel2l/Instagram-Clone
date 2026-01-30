import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram/auth/models/app_user_model.dart';
import 'package:instagram/profile/repository/profile_repository.dart';
import 'package:instagram/utils/utils.dart';

class UpdateProfilePage extends ConsumerStatefulWidget {
  final AppUserModel user;

  const UpdateProfilePage({super.key, required this.user});

  @override
  ConsumerState<UpdateProfilePage> createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends ConsumerState<UpdateProfilePage> {
  late TextEditingController nameController;
  late TextEditingController usernameController;
  late TextEditingController bioController;
  late TextEditingController dpController;
  String imgUrl = '';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.user.profile.name);
    usernameController = TextEditingController(
      text: widget.user.profile.username,
    );
    bioController = TextEditingController(text: widget.user.profile.bio);
    dpController = TextEditingController(text: widget.user.profile.dp);
    imgUrl = widget.user.profile.dp;
  }

  @override
  void dispose() {
    nameController.dispose();
    usernameController.dispose();
    bioController.dispose();
    dpController.dispose();
    super.dispose();
  }

  Future<void> updateProfile() async {
    setState(() => isLoading = true);

    await ref
        .read(profileRepositoryProvider)
        .updateUserProfile(
          uid: widget.user.firebaseUID,
          name: nameController.text.trim(),
          username: usernameController.text.trim().toLowerCase(),
          bio: bioController.text.trim(),
          dp: dpController.text.trim(),
          context: context,
        );

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed:
                isLoading
                    ? null
                    : () async {
                      if(imgUrl.isNotEmpty && !imgUrl.startsWith("https")){
                      final url = await uploadImageToCloudinary(imgUrl);
                      dpController.text = url;

                      }
                     await updateProfile();
                    },
            child:
                isLoading
                    ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Text(
                      "Save",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Picture
            Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage:
                      !imgUrl.startsWith("https")
                          ? Image.file(File(imgUrl)).image
                          : CachedNetworkImageProvider(widget.user.profile.dp),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(shape: BoxShape.circle),
                    child: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.black),
                      onPressed: () async {
                        imgUrl = await pickImageFromGallery(context) ?? "";
                        setState(() {});
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            const SizedBox(height: 24),

            _buildTextField(controller: nameController, label: "Name"),

            _buildTextField(controller: usernameController, label: "Username"),

            _buildTextField(
              controller: bioController,
              label: "Bio",
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
