
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

// ...

void main() async {
  await dotenv.load(fileName: "/Users/samuel/instagram/.env");
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
      home:
      // FirebaseAuth.instance.currentUser==null?SignUp():Home()
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
