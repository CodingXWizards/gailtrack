import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';

String WEBSOCKET_URL = dotenv.env['API_URL'] ?? "ws://localhost:5000/ws";

class WebSocketConnection {
  WebSocket? _socket;
  final String url = WEBSOCKET_URL;
  Function(dynamic)? onMessage;
  Function()? onDisconnect;
  final Duration reconnectInterval;

  WebSocketConnection({this.reconnectInterval = const Duration(seconds: 5)});

  Future<void> connect() async {
    try {
      _socket = await WebSocket.connect(url);
      _socket?.listen(
        (data) => onMessage?.call(jsonDecode(data)),
        onDone: _reconnect,
        onError: (error) {
          print("WebSocket error: $error");
          _reconnect();
        },
      );
      print("WebSocket connected to $url");
    } catch (e) {
      print("WebSocket connection failed: $e");
      _reconnect();
    }
  }

  void _reconnect() {
    onDisconnect?.call();
    Timer(reconnectInterval, connect);
  }

  void send(dynamic message) {
    if (_socket != null && _socket!.readyState == WebSocket.open) {
      _socket!.add(jsonEncode(message));
    } else {
      print("WebSocket not connected. Unable to send message.");
    }
  }

  void disconnect() {
    _socket?.close();
    _socket = null;
  }
}
