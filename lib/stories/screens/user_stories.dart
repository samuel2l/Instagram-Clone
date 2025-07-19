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

  void _startWatching() {
    Timer.periodic(Duration(milliseconds: 700), (timer) {
      setState(() {
        if (percentageCoveredList[currentStoryIndex] + 0.01 < 1) {
          percentageCoveredList[currentStoryIndex] += 0.01;
        } else {
          percentageCoveredList[currentStoryIndex] = 1;
          timer.cancel();
          if (currentStoryIndex < widget.userStories.length - 1) {
            currentStoryIndex++;
            _startWatching();
          } else {
            // Navigator.pop(context);
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    print("the stories ${widget.userStories}");
    for (int index = 0; index < widget.userStories.length; index++) {
      final currStory = widget.userStories[index];
      List<EditableItem> storyData = [];

      final storyDataFromFirebase = currStory["storyData"] as List;
      print(storyDataFromFirebase.length);

      for (
        int storyComponentIndex = 0;
        storyComponentIndex < storyDataFromFirebase.length;
        storyComponentIndex++
      ) {
        final editable = EditableItem();
        editable.position = Offset(
          storyDataFromFirebase[storyComponentIndex]["position"]["dx"],
          storyDataFromFirebase[storyComponentIndex]["position"]["dy"],
        );
        editable.rotation =
            storyDataFromFirebase[storyComponentIndex]["rotation"];
        editable.scale = storyDataFromFirebase[storyComponentIndex]["scale"];
        if (storyDataFromFirebase[storyComponentIndex]["type"] == "image") {
          editable.type = ItemType.image;
        } else if (storyDataFromFirebase[storyComponentIndex]["type"] ==
            "text") {
          editable.type = ItemType.text;
        }
        editable.value = storyDataFromFirebase[storyComponentIndex]["value"];

        storyData.add(editable);
      }
      userStoriesCast.add(storyData);
    }
    print("now watch story data??? $userStoriesCast");
    for (int i = 0; i < widget.userStories.length; i++) {
      percentageCoveredList.add(0);
    }
    _startWatching();
    return Scaffold(
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
            // child: ProgressBar(percentageCovered: 0.4,),
            child: StoryBars(
              storiesLength: widget.userStories.length,
              percentageCoveredList: percentageCoveredList,
            ),
          ),
        ],
      ),
    );
  }
}
