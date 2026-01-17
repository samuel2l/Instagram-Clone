import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram/auth/repository/auth_repository.dart';
import 'package:instagram/stories/repository/story_repository.dart';
import 'package:instagram/stories/screens/post_story.dart';
import 'package:instagram/stories/screens/view_story.dart';
import 'package:instagram/stories/widgets/story_bars.dart';
import 'package:instagram/stories/models/user_stories.dart' as UserStoriesModel;

class UserStories extends ConsumerStatefulWidget {
  const UserStories({super.key, required this.userStories});
  final UserStoriesModel.UserStories userStories;

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
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      for (int index = 0; index < widget.userStories.stories.length; index++) {
        final currStory = widget.userStories.stories[index];
        List<EditableItem> storyData = [];

        final storyDataFromFirebase = currStory.storyData;

        for (var storyComponent in storyDataFromFirebase) {
          final editable = EditableItem();
          editable.position = Offset(
            storyComponent.position.dx,
            storyComponent.position.dy,
          );
          editable.rotation = storyComponent.rotation;
          editable.scale = storyComponent.scale;

          if (storyComponent.type == "image") {
            editable.type = ItemType.image;
          } else if (storyComponent.type == "text") {
            editable.type = ItemType.text;
          }

          editable.value = storyComponent.value;
          storyData.add(editable);
        }
        userStoriesCast.add(storyData);
      }
      setState(() {});

      percentageCoveredList = List.filled(widget.userStories.stories.length, 0);
      _startWatching();
    });
  }

  void _startWatching() {
    final currentUserId = ref.watch(userProvider).value?.firebaseUID ?? "";

    final currStory = widget.userStories.stories[currentStoryIndex];

    ref
        .read(storyRepositoryProvider)
        .addStoryViewer(
          ownerId: widget.userStories.userId,
          storyId: currStory.storyId,
          viewerId: currentUserId,
        );

    storyTimer?.cancel();

    storyTimer = Timer.periodic(const Duration(milliseconds: 700), (timer) {
      if (!mounted) return;

      setState(() {
        if (!isHolding) {
          if (percentageCoveredList[currentStoryIndex] + 0.01 < 1) {
            percentageCoveredList[currentStoryIndex] += 0.01;
          } else {
            percentageCoveredList[currentStoryIndex] = 1;
            timer.cancel();

            if (currentStoryIndex < widget.userStories.stories.length - 1) {
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
    return userStoriesCast.isNotEmpty
        ? GestureDetector(
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
              if (currentStoryIndex < widget.userStories.stories.length - 1) {
                percentageCoveredList[currentStoryIndex] = 1;
                percentageCoveredList[currentStoryIndex + 1] = 0;
                currentStoryIndex += 1;
                _startWatching();
              } else {
                percentageCoveredList[currentStoryIndex] = 1;
                Navigator.pop(context);
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
                  mediaUrl:
                      widget.userStories.stories[currentStoryIndex].mediaUrl,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 40,
                    horizontal: 20,
                  ),
                  child: StoryBars(
                    storiesLength: widget.userStories.stories.length,
                    percentageCoveredList: percentageCoveredList,
                  ),
                ),
              ],
            ),
          ),
        )
        : Center(child: CircularProgressIndicator());
  }
}
