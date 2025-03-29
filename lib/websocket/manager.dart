import 'package:gailtrack/websocket/connection.dart';

class WebSocketManager {
  static final WebSocketManager _instance = WebSocketManager._internal();

  late final WebSocketConnection _connection;

  factory WebSocketManager() => _instance;

  WebSocketManager._internal();

  void init() {
    _connection = WebSocketConnection();
    _connection.onMessage = _handleMessage;
    _connection.onDisconnect = _handleDisconnect;
    // _connection.connect();
  }

  WebSocketConnection get connection => _connection;

  void _handleMessage(dynamic data) {
    print("WebSocketManager received: $data");
    // Broadcast data to listeners (services)
  }

  void _handleDisconnect() {
    print("WebSocketManager disconnected.");
    // Handle global disconnect scenarios
  }
}
