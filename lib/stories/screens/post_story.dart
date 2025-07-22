//

import 'dart:io';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram/stories/repository/story_repository.dart';
import 'package:instagram/utils/utils.dart';

class StoryEditor extends ConsumerStatefulWidget {
  const StoryEditor({super.key, this.selectedImage});
  final File? selectedImage;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _StoryEditorState();
}

class _StoryEditorState extends ConsumerState<StoryEditor> {
  EditableItem? _activeItem;
  late Offset _initPos;
  late Offset _currentPos;
  late double _currentScale;
  late double _currentRotation;
  bool _inAction = false;

  List<EditableItem> storyData = [];
  bool isCaption = false;

  @override
  void initState() {
    super.initState();
    EditableItem firstItem = EditableItem();
    firstItem.currImage = widget.selectedImage;
    firstItem.type = ItemType.image;
    storyData.add(firstItem);
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,

        backgroundColor: Colors.black,
        actions: [
          IconButton(
            onPressed: () {
              isCaption = !isCaption;
              setState(() {});
            },
            icon: Icon(Icons.abc),
          ),
        ],
      ),
      body: GestureDetector(
        onScaleStart: (details) {
          if (_activeItem == null) return;

          _initPos = details.focalPoint;
          _currentPos = _activeItem!.position;
          _currentScale = _activeItem!.scale;
          _currentRotation = _activeItem!.rotation;
        },
        onScaleUpdate: (details) {
          if (_activeItem == null) return;

          final delta = details.focalPoint - _initPos;
          final left = (delta.dx / screen.width) + _currentPos.dx;
          final top = (delta.dy / screen.height) + _currentPos.dy;

          setState(() {
            _activeItem!.position = Offset(left, top);
            _activeItem!.rotation = details.rotation + _currentRotation;
            _activeItem!.scale = max(
              min(details.scale * _currentScale, 3),
              0.2,
            );
          });
        },
        child: Stack(
          children: [
            Container(color: Colors.black),
            ...storyData.map(_buildItemWidget),
            isCaption
                ? Center(
                  child: TextField(
                    onSubmitted: (value) {
                      setState(() {
                        isCaption = false;
                        EditableItem nextItem = EditableItem();
                        nextItem.value = value;
                        nextItem.type = ItemType.text;
                        storyData.add(nextItem);
                      });
                    },
                  ),
                )
                : SizedBox.shrink(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          String mediaUrl = await uploadImageToCloudinary(
            widget.selectedImage!.path,
          );
          if (mediaUrl.isNotEmpty) {
            final status = await ref
                .read(storyRepositoryProvider)
                .uploadStory(
                  FirebaseAuth.instance.currentUser!.uid,
                  mediaUrl: mediaUrl,
                  storyData: storyData,
                  context: context,
                );
            if (status) {
              showSnackBar(
                context: context,
                content: "story uploaded successfully",
              );
              Navigator.pop(context);
            }
          }
        },
      ),
    );
  }

  Widget _buildItemWidget(EditableItem e) {
    final screen = MediaQuery.of(context).size;

    Widget widget;
    switch (e.type) {
      case ItemType.text:
        widget = Text(e.value!, style: const TextStyle(color: Colors.white));
        break;
      case ItemType.image:
        widget = Image.file(e.currImage!);
        // widget = Image.network(e.value!);
        break;
    }

    return Positioned(
      top: e.position.dy * screen.height,
      left: e.position.dx * screen.width,
      child: Transform.scale(
        scale: e.scale,
        child: Transform.rotate(
          angle: e.rotation,
          child: Listener(
            onPointerDown: (details) {
              if (_inAction) return;
              _inAction = true;
              _activeItem = e;
              _initPos = details.position;
              _currentPos = e.position;
              _currentScale = e.scale;
              _currentRotation = e.rotation;
            },
            onPointerUp: (details) {
              _inAction = false;
            },
            child: widget,
          ),
        ),
      ),
    );
  }
}

enum ItemType { image, text }

class EditableItem {
  Offset position = const Offset(0.1, 0.1);
  double scale = 1.0;
  double rotation = 0.0;
  late ItemType type;
  String? value;
  File? currImage;

  Map<String, dynamic> toMap() {
    return {
      'position': {'dx': position.dx, 'dy': position.dy},
      'scale': scale,
      'rotation': rotation,
      'type': type.name,
      'value': value,
    };
  }
}
