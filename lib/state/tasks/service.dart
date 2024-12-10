import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gailtrack/state/tasks/model.dart';
import 'package:http/http.dart' as http;

// ignore: non_constant_identifier_names
String API_URL = dotenv.env['API_URL'] ?? "https://gailtrack-api.onrender.com";

Future<List<Task>> fetchTasks() async {
  String? uuidFirebase = FirebaseAuth.instance.currentUser?.uid;

  if (uuidFirebase == null) throw Exception("User not logged In");

  final url = Uri.parse("$API_URL/get-tasks");

  //* Setting Headers
  final headers = {
    'Content-Type': 'application/json',
  };

  final body = jsonEncode({"uuid_firebase": uuidFirebase});

  try {
    final response = await http.post(url, headers: headers, body: body);
    if (response.statusCode != 200) {
      throw Exception("Error occured with Status Code ${response.statusCode}");
    }

    final decodedList = jsonDecode(response.body);

    final List<Task> taskList =
        decodedList.map<Task>((task) => Task.fromJson(task)).toList();
    return taskList;
  } catch (e) {
    throw Exception(e);
  }
}
