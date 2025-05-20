import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram/auth/repository/auth_repository.dart';

class Home extends ConsumerWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text("Home")),
      body: Center(
        child: ref
            .read(getUserProvider)
            .when(
              data: (user) {
                return Column(
                  children: [
                    
                    Text(user!.email),
                    Text(user!.firebaseUID)
                  ],
                );
              },
              error: (error, stackTrace) => Text(error.toString()),
              loading: () => Center(child: CircularProgressIndicator(),),
            ),
      ),
    );
  }
}
