class Task {
  int id;
  String task;
  String uuidFirebase;
  String description;
  bool completed;
  DateTime deadline;

  Task(
      {required this.id,
      required this.task,
      required this.uuidFirebase,
      required this.description,
      required this.completed,
      required this.deadline});

  Task.noWork()
      : id = 0,
        task = "",
        uuidFirebase = "",
        description = "",
        completed = false,
        deadline = DateTime.timestamp();

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as int,
      task: json['task'] as String,
      uuidFirebase: json['uuid_firebase'] as String,
      description: json['description'] as String,
      completed: json['completed'] as bool,
      deadline: DateTime.parse(json['deadline'] as String),
    );
  }
}
