import 'package:local_auth/local_auth.dart';

Future<bool> authenticateWithBiometrics() async {
  final LocalAuthentication localAuth = LocalAuthentication();

  bool authenticated = await localAuth.authenticate(
      localizedReason: 'Use your fingerprint to authenticate',
      options: const AuthenticationOptions(
        biometricOnly: true,
      ));
  return authenticated;
}
