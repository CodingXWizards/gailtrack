import 'package:flutter/material.dart';
import 'package:gailtrack/components/my_button.dart';
import 'package:gailtrack/components/my_textfield.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  void signUserIn() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
          child: Column(children: [
        const SizedBox(height: 75),
        const Text('Welcome Back To GailTrack',
            style: TextStyle(color: Colors.white, fontSize: 30, height: 5.0)),
        MyTextfield(
          controller: usernameController,
          hintText: 'Username',
          obscureText: false,
        ),
        const SizedBox(height: 25),
        MyTextfield(
          controller: passwordController,
          hintText: 'Password',
          obscureText: true,
        ),
        const SizedBox(height: 25),
        const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Forgot Password?',
                  style: TextStyle(color: Colors.white),
                )
              ],
            )),
        const SizedBox(height: 25),
        MyButton(
          onTap: signUserIn,
        ),
      ])),
    );
  }
}
