import 'package:flutter/material.dart';
import 'package:instagram/stories/widgets/progress_bar.dart';

class StoryBars extends StatelessWidget {
  const StoryBars({
    super.key,
    required this.storiesLength,
    required this.percentageCoveredList,
  });
  final int storiesLength;
  final List<double> percentageCoveredList;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          for (int i = 0; i < storiesLength; i++)
            Expanded(
              child: ProgressBar(percentageCovered: percentageCoveredList[i]),
            ),
        ],
      ),
    );
  }
}
