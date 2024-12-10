import 'package:gailtrack/state/attendance/model.dart';
import 'package:intl/intl.dart';
import 'package:local_auth/local_auth.dart';

Future<bool> checkBiometric() async {
  final LocalAuthentication localAuth = LocalAuthentication();

  final bool canAuthenticateWithBiometrics = await localAuth.canCheckBiometrics;
  final bool canAuthenticate =
      canAuthenticateWithBiometrics && await localAuth.isDeviceSupported();

  return canAuthenticate;
}

Future<bool> authenticateWithBiometrics() async {
  final LocalAuthentication localAuth = LocalAuthentication();

  bool authenticated = await localAuth.authenticate(
      localizedReason: 'Use your fingerprint to authenticate',
      options: const AuthenticationOptions(
        biometricOnly: true,
      ));
  return authenticated;
}

String getWorkingTimeForToday(List<Working> workingList) {
  final today = DateTime.now();
  final dateFormatter = DateFormat('yyyy-MM-dd');
  final todayFormatted = dateFormatter.format(today);

  List<Working> todayWorkings = workingList.where((working) {
    final workingDateFormatted = dateFormatter.format(working.date);
    return workingDateFormatted == todayFormatted;
  }).toList();

  Duration totalDuration = todayWorkings.fold(
    Duration.zero,
    (total, working) => total + working.workingDuration,
  );

  List<String> workingTime = [];

  int hours = totalDuration.inHours;
  int minutes = totalDuration.inMinutes.remainder(60);

  if (hours > 0) workingTime.add("$hours Hours");
  if (minutes > 0) workingTime.add("$minutes Minutes");

  return workingTime.isEmpty ? "No work today" : workingTime.join(" ");
}
