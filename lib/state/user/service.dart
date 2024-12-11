import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'package:gailtrack/state/user/model.dart';

// ignore: non_constant_identifier_names
String API_URL = dotenv.env['API_URL'] ?? "http://192.168.1.14:5001/";

Future<User> fetchUser() async {
  const storage = FlutterSecureStorage();

  String? email = await storage.read(key: "email");

  if (email == null) throw Exception("User not logged In");

  final url = Uri.parse("$API_URL/getinfo");

  //* Setting Headers
  final headers = {
    'Content-Type': 'application/json',
  };

  final body = jsonEncode({"email": email});

  try {
    final response = await http.post(url, headers: headers, body: body);
    if (response.statusCode != 200) {
      throw Exception("Error occured with Status Code ${response.statusCode}");
    }

    return User.fromJson(jsonDecode(response.body)['emp']);
  } catch (e) {
    throw Exception(e);
  }
}
