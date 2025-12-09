import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:giphy_get/l10n.dart';
import 'package:instagram/auth/repository/auth_repository.dart';
import 'package:instagram/auth/screens/sign_up.dart';
import 'package:instagram/firebase_options.dart';

import "package:flutter_dotenv/flutter_dotenv.dart";
import 'package:instagram/home/screens/home.dart';
import 'package:instagram/posts/screens/create_post.dart';

String? appId = dotenv.env["AGORA_APP_ID"];
String? token = dotenv.env["AGORA_TEMP_TOKEN"];
String channel = "testtt";

void main() async {
  await dotenv.load();
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,

      locale: Locale("fr"),
      localizationsDelegates: [
        // AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [Locale("en"), Locale("fr")],

      home: ref
          .watch(getUserProvider)
          .when(
            data: (data) {

              return data == null ? const SignUp() : Home();
            },
            error: (error, stackTrace) {
 
              return Center(child: Text(error.toString()  ));
            },
            loading: () => Center(child: CircularProgressIndicator()),
          ),

      // home: CreatePost(),
    );
  }
}
