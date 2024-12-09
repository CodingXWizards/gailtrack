class Working {
  int id;
  String checkIn;
  String checkOut;
  DateTime date;
  Duration workingDuration;

  Working({
    required this.id,
    required this.checkIn,
    required this.checkOut,
    required this.date,
    required this.workingDuration,
  });

  Working.noWork()
      : id = 0,
        checkIn = "00:00:00",
        checkOut = "00:00:00",
        date = DateTime.now(),
        workingDuration = Duration.zero;

  factory Working.fromJson(Map<String, dynamic> json) {
    return Working(
      id: json['id'] as int,
      checkIn: json['checkin'] as String,
      checkOut: json['checkout'] as String,
      date: DateTime.parse(json['date'] as String),
      workingDuration: _parseDuration(json['workingduration'] as String),
    );
  }

  static Duration _parseDuration(String duration) {
    final parts = duration.split(':').map(int.parse).toList();
    return Duration(hours: parts[0], minutes: parts[1], seconds: parts[2]);
  }
}
