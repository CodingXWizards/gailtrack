class Request {
  int id;
  String uuidFirebase;
  String label;
  String reason;
  DateTime startDate;
  DateTime endDate;

  Request(
      {required this.id,
      required this.uuidFirebase,
      required this.label,
      required this.reason,
      required this.startDate,
      required this.endDate});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid_firebase': uuidFirebase,
      'label': label,
      'reason': reason,
      'start_date': startDate.toIso8601String(), // Serialize DateTime
      'end_date': endDate.toIso8601String(),
    };
  }

  factory Request.fromJson(Map<String, dynamic> json) {
    return Request(
      id: json['id'] as int,
      uuidFirebase: json['uuid_firebase'] as String,
      label: json['label'] as String,
      reason: json['reason'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
    );
  }
}
