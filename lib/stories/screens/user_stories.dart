import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram/stories/screens/post_story.dart';
import 'package:instagram/stories/screens/view_story.dart';
import 'package:instagram/stories/widgets/progress_bar.dart';
import 'package:instagram/stories/widgets/story_bars.dart';

class UserStories extends ConsumerStatefulWidget {
  const UserStories({super.key, required this.userStories});
  final List userStories;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _UserStoriesState();
}

class _UserStoriesState extends ConsumerState<UserStories> {
  int currentStoryIndex = 0;
  List<double> percentageCoveredList = [];
  List<List<EditableItem>> userStoriesCast = [];
  bool isHolding = false;
  Timer? storyTimer;

  @override
  void initState() {
    super.initState();

    // Initialize userStoriesCast and percentageCoveredList
    for (int index = 0; index < widget.userStories.length; index++) {
      final currStory = widget.userStories[index];
      List<EditableItem> storyData = [];

      final storyDataFromFirebase = currStory["storyData"] as List;

      for (var storyComponent in storyDataFromFirebase) {
        final editable = EditableItem();
        editable.position = Offset(
          storyComponent["position"]["dx"],
          storyComponent["position"]["dy"],
        );
        editable.rotation = storyComponent["rotation"];
        editable.scale = storyComponent["scale"];

        if (storyComponent["type"] == "image") {
          editable.type = ItemType.image;
        } else if (storyComponent["type"] == "text") {
          editable.type = ItemType.text;
        }

        editable.value = storyComponent["value"];
        storyData.add(editable);
      }
      userStoriesCast.add(storyData);
    }

    percentageCoveredList = List.filled(widget.userStories.length, 0);
    _startWatching();
  }

  void _startWatching() {
    storyTimer?.cancel(); // Cancel any existing timer

    storyTimer = Timer.periodic(Duration(milliseconds: 700), (timer) {
      if (!mounted) return;

      setState(() {
        if (!isHolding) {
          if (percentageCoveredList[currentStoryIndex] + 0.01 < 1) {
            percentageCoveredList[currentStoryIndex] += 0.01;
          } else {
            percentageCoveredList[currentStoryIndex] = 1;
            timer.cancel();
            if (currentStoryIndex < widget.userStories.length - 1) {
              currentStoryIndex++;
              _startWatching();
            } else {
              Navigator.pop(context);
            }
          }
        }
      });
    });
  }

  @override
  void dispose() {
    storyTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        isHolding = true;

        final width = MediaQuery.of(context).size.width;
        final dx = details.globalPosition.dx;

        if (dx < width / 2) {
          if (currentStoryIndex > 0) {
            percentageCoveredList[currentStoryIndex] = 0;
            percentageCoveredList[currentStoryIndex - 1] = 0;
            currentStoryIndex -= 1;
            _startWatching();
          }
        } else {
          if (currentStoryIndex < widget.userStories.length - 1) {
            percentageCoveredList[currentStoryIndex] = 1;
            percentageCoveredList[currentStoryIndex + 1] = 0;
            currentStoryIndex += 1;
            _startWatching();
          } else {
            percentageCoveredList[currentStoryIndex] = 1;
            Navigator.pop(context); // Pop if tapping forward on last story
          }
        }
        setState(() {});
      },
      onTapUp: (_) {
        isHolding = false;
      },
      onTapCancel: () {
        isHolding = false;
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(backgroundColor: Colors.transparent),
        body: Stack(
          children: [
            ViewStory(
              storyData: userStoriesCast[currentStoryIndex],
              mediaUrl: widget.userStories[currentStoryIndex]["mediaUrl"],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              child: StoryBars(
                storiesLength: widget.userStories.length,
                percentageCoveredList: percentageCoveredList,
              ),
            ),
          ],
        ),
      ),
    );
  }
}