import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gailtrack/components/my_button.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  bool isBiometricsEnabled = false;
  final _storage = const FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Enable Biometrics",
                    style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(width: 12),
                Switch(
                  activeColor: Theme.of(context).colorScheme.secondary,
                  value: isBiometricsEnabled,
                  onChanged: (bool value) async {
                    setState(() => isBiometricsEnabled = value);
                    await _storage.write(
                        key: 'isBiometricsEnabled', value: value.toString());
                  },
                )
              ],
            ),
            const SizedBox(height: 20),
            MyButton(
                text: "Continue",
                bgColor: Theme.of(context).focusColor,
                textColor: Theme.of(context).primaryColor,
                onTap: () => Navigator.pushReplacementNamed(context, '/'))
          ],
        ),
      ),
    );
  }
}
