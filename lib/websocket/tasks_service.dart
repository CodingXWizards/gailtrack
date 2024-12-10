import 'package:gailtrack/state/tasks/model.dart';
import 'package:gailtrack/state/tasks/provider.dart';
import 'package:gailtrack/websocket/manager.dart';

class TaskWebSocketService {
  final _connection = WebSocketManager().connection;
  late TaskProvider _taskProvider;

  TaskWebSocketService();

  void setTaskProvider(TaskProvider taskProvider) {
    _taskProvider = taskProvider;
  }

  void connect() {
    _connection.onMessage = _handleIncomingData;
  }

  void _handleIncomingData(dynamic data) {
    if (data['type'] == 'task_list') {
      print("new Task incoming");
      List<Task> newTasks = (data['tasks'] as List)
          .map((task) => Task.fromJson(task as Map<String, dynamic>))
          .toList();

      _taskProvider.updateTasks(newTasks);
    } else if (data['type'] == 'newTask') {
      print("new Task incoming");
      // Add a single task dynamically.
      Task newTask = Task.fromJson(data['task'] as Map<String, dynamic>);
      _taskProvider.addTask(newTask);
    }
  }

  void sendTaskAction(dynamic action) {
    _connection.send({'type': 'task_action', 'data': action});
  }
}
