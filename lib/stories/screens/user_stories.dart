import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram/stories/screens/post_story.dart';
import 'package:instagram/stories/screens/view_story.dart';
import 'package:instagram/stories/widgets/progress_bar.dart';

class UserStories extends ConsumerStatefulWidget {
  const UserStories({super.key, required this.userStories});
  final List userStories;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _UserStoriesState();
}

class _UserStoriesState extends ConsumerState<UserStories> {
  int currentStoryIndex = 0;
  List<List<EditableItem>> userStoriesCast = [];
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
    return Scaffold(
      appBar: AppBar(),
      body:
      // ListView.builder(
      //   itemCount: widget.userStories.length,
      //   itemBuilder: (context, index) {
      //     final currStory = widget.userStories[index];
      //     print("the curr story??? $currStory");
      //     if (currStory["storyData"][0]["type"] == "image") {
      //       return GestureDetector(
      //         onTap: () {
      //           Navigator.of(context).push(
      //             MaterialPageRoute(
      //               builder: (context) {
      //                 return ViewStory(
      //                   storyData: userStoriesCast[index],
      //                   mediaUrl: currStory["mediaUrl"],
      //                 );
      //               },
      //             ),
      //           );
      //         },
      //         child: SizedBox(
      //           height: 40,
      //           child: Image.network(currStory["mediaUrl"]),
      //         ),
      //       );
      //     } else {
      //       return SizedBox(
      //         height: 40,
      //         child: Text(currStory["storyData"][0]["value"]),
      //       );
      //     }
      //   },
      // ),
      Stack(
        children: [
          ViewStory(
            storyData: userStoriesCast[currentStoryIndex],
            mediaUrl: widget.userStories[currentStoryIndex]["mediaUrl"],
          ),
          ProgressBar()
        ],
      ),
    );
  }
}
