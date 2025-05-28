import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram/auth/repository/auth_repository.dart';

class Login extends ConsumerStatefulWidget {
  const Login({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LoginState();
}

class _LoginState extends ConsumerState<Login> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
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
                    .login(
                      emailController.text.trim(),
                      passwordController.text.trim(),
                      context,
                    );
              }
            },
            child: Text("login"),
          ),
        ],
      ),
    );
  }
}
