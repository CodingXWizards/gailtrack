import 'package:flutter/material.dart';
import 'package:gailtrack/components/my_button.dart';
import 'package:gailtrack/components/my_textfield.dart';

class Login extends StatelessWidget {
  Login({super.key});
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  void signUserIn(BuildContext context) {
    Navigator.popAndPushNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            height: MediaQuery.sizeOf(context).height,
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Welcome Back To GailTrack',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displaySmall),
                const SizedBox(height: 40),
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
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Forgot Password?',
                      style: Theme.of(context).textTheme.labelMedium,
                    )
                  ],
                ),
                const SizedBox(height: 20),
                MyButton(
                  text: "Sign in",
                  bgColor: Theme.of(context).focusColor,
                  textColor: Theme.of(context).primaryColor,
                  onTap: () => signUserIn(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
