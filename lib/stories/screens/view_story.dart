import 'package:flutter/material.dart';
import 'package:instagram/stories/screens/post_story.dart';

class ViewStory extends StatefulWidget {
  const ViewStory({super.key, required this.storyData});
  final List<EditableItem> storyData;
  @override
  State<ViewStory> createState() => _ViewStoryState();
}

class _ViewStoryState extends State<ViewStory> {
  
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
          child: widget,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
                      Container(color: Colors.black),
            ...widget.storyData.map(_buildItemWidget),
        ],
      ),

    );
  }
}
