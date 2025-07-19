import 'package:flutter/material.dart';
import 'package:instagram/stories/screens/post_story.dart';

class ViewStory extends StatefulWidget {
  const ViewStory({super.key, required this.storyData, this.mediaUrl});
  final List<EditableItem> storyData;
  final String? mediaUrl;

  @override
  State<ViewStory> createState() => _ViewStoryState();
}

class _ViewStoryState extends State<ViewStory> {
  Widget _buildItemWidget(EditableItem e) {
    final screen = MediaQuery.of(context).size;

    Widget displayWidget;
    switch (e.type) {
      case ItemType.text:
        displayWidget = Text(
          e.value!,
          style: const TextStyle(color: Colors.white),
        );
        break;
      case ItemType.image:
        // widget = Image.file(e.currImage!);
        if (widget.mediaUrl != null) {
          displayWidget = Image.network(widget.mediaUrl!);
        } else {
          displayWidget = Text("No image available");
        }
        break;
    }

    return Positioned(
      top: e.position.dy * screen.height,
      left: e.position.dx * screen.width,
      child: Transform.scale(
        scale: e.scale,
        child: Transform.rotate(angle: e.rotation, child: displayWidget),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: Colors.black),
        ...widget.storyData.map(_buildItemWidget),
      ],
    );
  }
}
