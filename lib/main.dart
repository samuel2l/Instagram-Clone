import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import "package:flutter_gen/gen_l10n/app_localizations.dart";
import "package:flutter_localizations/flutter_localizations.dart";
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram/auth/repository/auth_repository.dart';
import 'package:instagram/auth/screens/sign_up.dart';
import 'package:instagram/firebase_options.dart';
import 'package:instagram/home/screens/home.dart';
import 'package:instagram/recorddd.dart';

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

      locale: Locale("fr"),
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [Locale("en"), Locale("fr")],
      // home: DraggableCaption(caption: "my drag"),
      // home: Story(),

      home:
      ref
          .watch(getUserProvider)
          .when(
            data: (data) {

              return data == null ? const SignUp() : Home();
            },
            error: (error, stackTrace) => Center(child: Text(error.toString())),
            loading: () => Center(child: CircularProgressIndicator()),
          ),
    );
  }
}

class Story extends StatefulWidget {
  const Story({super.key});

  @override
  State<Story> createState() => _StoryState();
}

class _StoryState extends State<Story> {
  TextEditingController captionController = TextEditingController();
  List<String> captions = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("draggable story template")),
      body: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: Image.asset("assets/images/IMG_3846.JPG", fit: BoxFit.cover),
          ),
          // Icon(Icons.headphones, color: Colors.red),
          for(var caption in captions)
          Text(caption,style: TextStyle(fontSize: 20,color: Colors.white),),

          Form(
            child: TextFormField(
              controller: captionController,
              onFieldSubmitted: (value) {
                captions.add(value);
                captionController.text = "";
                setState(() {
                  
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}

class DraggableCaption extends StatefulWidget {
  final String caption;
  // final Function(Offset) onPositionChanged;

  const DraggableCaption({
    super.key,
    required this.caption,
    // required this.onPositionChanged,
  });

  @override
  _DraggableCaptionState createState() => _DraggableCaptionState();
}

class _DraggableCaptionState extends State<DraggableCaption> {
  Offset position = Offset(100, 100); // default starting point
  void updatePosition(Offset newPosition) {
    position = newPosition;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            position += details.delta;
            updatePosition(position);
          });
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          color: Colors.black54,
          child: Text(
            widget.caption,
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    );
  }
}
