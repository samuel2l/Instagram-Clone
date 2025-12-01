import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram/stories/repository/story_repository.dart';
import 'package:instagram/stories/screens/user_stories.dart';
import 'package:instagram/chat/screens/chats.dart';

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.add),
        title: Text(
          "Instagram",
          style: TextStyle(
            fontFamily: 'ImperialScript',
            fontWeight: FontWeight.bold,
            fontSize: 34
          ),
        ),
        actions: [
          Icon(Icons.send_outlined)
        ],
      ),
      body: Column(
        children: [
          FutureBuilder(
            future: ref.read(storyRepositoryProvider).getValidStories(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text("Unexpected error"));
              }

              final stories = snapshot.data ?? {};
              List users = stories.keys.toList();

              if (snapshot.connectionState == ConnectionState.done) {
                return Container(
                  height: 140,
                  width: double.infinity,
                  color: Colors.red,
                  child: ListView.builder(
                    itemCount: users.length,
                    scrollDirection: Axis.horizontal,

                    itemBuilder: (context, index) {
                      final currUser = users[index];

                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) {
                                return UserStories(
                                  userStories: stories[currUser],
                                );
                              },
                            ),
                          );
                        },
                        child: Container(
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                            color: Colors.green,

                            shape: BoxShape.circle,
                          ),
                          child: Center(child: Text(currUser)),
                        ),
                      );
                    },
                  ),
                );
              }
              return Text("unexpected error");
            },
          ),
        ],
      ),
    );
  }
}
