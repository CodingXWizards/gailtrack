import 'package:gailtrack/websocket/manager.dart';

class TaskWebSocketService {
  final _connection = WebSocketManager().connection;

  List<dynamic> tasks = [];

  void connect() {
    _connection.onMessage = _handleIncomingData;
  }

  void _handleIncomingData(dynamic data) {
    if (data['type'] == 'task_list') {
      tasks = data['tasks'];
      print("Tasks updated: $tasks");
    }
  }

  void sendTaskAction(dynamic action) {
    _connection.send({'type': 'task_action', 'data': action});
  }
}
