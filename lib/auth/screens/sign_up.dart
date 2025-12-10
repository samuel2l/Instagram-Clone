import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram/auth/repository/auth_repository.dart';
import 'package:instagram/auth/screens/login.dart';

class SignUp extends ConsumerStatefulWidget {
  const SignUp({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SignUpState();
}

class _SignUpState extends ConsumerState<SignUp> {
  TextEditingController emailController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sign up")),
      body: Column(
        children: [
          Form(
            key: formKey,
            child: Column(
              children: [
                TextFormField(controller: emailController),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                ref
                    .read(authRepositoryProvider)
                    .createUser(
                      emailController.text.trim(),
                      passwordController.text.trim(),

                      context,
                    );
              }
            },
            child: Text("Sign up"),
          ),
          Text("already have an account log in"),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return Login();
                  },
                ),
              );
            },
            child: Text("LOGIN"),
          ),
        ],
      ),
    );
  }
}
