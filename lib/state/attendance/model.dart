import 'package:intl/intl.dart';

class Working {
  int id;
  String checkIn;
  String? checkOut;
  DateTime date;
  Duration workingDuration;

  Working({
    required this.id,
    required this.checkIn,
    this.checkOut,
    required this.date,
    required this.workingDuration,
  });

  Working.noWork()
      : id = 0,
        checkIn = "00:00:00",
        checkOut = null, // Null since no work is done
        date = DateTime.now(),
        workingDuration = Duration.zero;

  factory Working.fromJson(Map<String, dynamic> json) {
    final checkInTime = json['checkin'] as String;
    final checkOutTime = json['checkout'] as String?;
    final checkInDateTime = DateTime.parse('${json['date']}T$checkInTime');
    final now = DateTime.now();

    Duration calculatedDuration = Duration.zero;
    if (checkOutTime != null && checkOutTime.isNotEmpty) {
      final checkOutDateTime = DateTime.parse('${json['date']}T$checkOutTime');
      calculatedDuration = checkOutDateTime.difference(checkInDateTime);
    } else {
      calculatedDuration = now.difference(checkInDateTime);
    }

    return Working(
      id: json['id'] as int,
      checkIn: checkInTime,
      checkOut: checkOutTime,
      date: DateTime.parse(json['date'] as String),
      workingDuration: json['workingduration'] != null
          ? _parseDuration(json['workingduration'])
          : calculatedDuration,
    );
  }

  static Duration _parseDuration(String duration) {
    try {
      final parts = duration.split(':').map(int.parse).toList();
      return Duration(
        hours: parts.isNotEmpty ? parts[0] : 0,
        minutes: parts.length > 1 ? parts[1] : 0,
        seconds: parts.length > 2 ? parts[2] : 0,
      );
    } catch (e) {
      print("Error parsing duration: $duration - $e");
      return Duration.zero; // Default to zero on error
    }
  }

  // Dynamically calculate current working duration if checkout is null
  Duration getCurrentWorkingDuration() {
    if (checkOut == null) {
      final checkInDateTime =
          DateTime.parse('${date.toIso8601String().split('T')[0]}T$checkIn');
      return DateTime.now().difference(checkInDateTime);
    }
    return workingDuration;
  }

  Duration getTotalWorkingDuration() {
    if (checkIn.isNotEmpty && checkOut != null && checkOut!.isNotEmpty) {
      final checkInTime =
          DateFormat.jm().parse(checkIn); // Assuming check-in time is a string.
      final checkOutTime = DateFormat.jm()
          .parse(checkOut!); // Assuming check-out time is a string.
      return checkOutTime.difference(checkInTime);
    }
    return Duration.zero;
  }
}
