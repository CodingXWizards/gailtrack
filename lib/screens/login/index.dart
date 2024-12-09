import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gailtrack/components/my_button.dart';
import 'package:gailtrack/components/my_textfield.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  String error = "";

  Future<bool> signUserIn() async {
    setState(() => isLoading = true);
    try {
      final credentials = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: emailController.text.trim(),
              password: passwordController.text.trim());
      String? idToken = await credentials.user?.getIdToken();
      if (idToken == null) return false;

      await _storage.write(key: 'authToken', value: idToken);
      await _storage.write(key: 'email', value: emailController.text.trim());
      return true;
    } catch (e) {
      setState(() => error = e.toString());
      return false;
    } finally {
      setState(() => isLoading = true);
    }
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
                  controller: emailController,
                  hintText: 'Email',
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
                const SizedBox(height: 12),
                Text(
                  error,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
                const SizedBox(height: 12),
                MyButton(
                  width: double.infinity,
                  text: "Sign in",
                  isLoading: isLoading,
                  type: ButtonType.secondary,
                  onTap: () async {
                    bool isAuthenticated = await signUserIn();
                    if (mounted && isAuthenticated) {
                      // ignore: use_build_context_synchronously
                      Navigator.pushNamed(context, '/onboarding');
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
