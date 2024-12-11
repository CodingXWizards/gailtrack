import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gailtrack/state/attendance/model.dart';
import 'package:http/http.dart' as http;

// ignore: non_constant_identifier_names
String API_URL = dotenv.env['API_URL'] ?? "http://192.168.1.14:5001/";

Future<List<Working>> fetchWorking() async {
  String? uuidFirebase = FirebaseAuth.instance.currentUser?.uid;

  if (uuidFirebase == null) throw Exception("User not logged In");

  final url = Uri.parse("$API_URL/checkin");

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

    final workingList = jsonDecode(response.body)['data'];

    final List<Working> workings = workingList
        .map<Working>((working) => Working.fromJson(working))
        .toList();
    return workings;
  } catch (e) {
    throw Exception(e);
  }
}
