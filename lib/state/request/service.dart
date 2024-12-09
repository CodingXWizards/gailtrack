import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gailtrack/state/request/model.dart';
import 'package:http/http.dart' as http;

// ignore: non_constant_identifier_names
String API_URL = dotenv.env['API_URL'] ?? "https://gailtrack-api.onrender.com";

Future<List<Request>> fetchRequests() async {
  String? uuidFirebase = FirebaseAuth.instance.currentUser?.uid;

  if (uuidFirebase == null) throw Exception("User not logged In");

  final url = Uri.parse("$API_URL/request/all");

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

    final decodeList = jsonDecode(response.body)['requests'];
    print(decodeList);
    final List<Request> requestList = decodeList
        .map<Request>((request) => Request.fromJson(request))
        .toList();
    return requestList;
  } catch (e) {
    throw Exception(e);
  }
}

Future<String> postRequest(Request req) async {
  final url = Uri.parse("$API_URL/request");

  //* Setting Headers
  final headers = {
    'Content-Type': 'application/json',
  };

  final body = jsonEncode(req.toJson());

  try {
    final response = await http.post(url, headers: headers, body: body);
    if (response.statusCode != 200) {
      throw Exception("Error occured with Status Code ${response.statusCode}");
    }

    return "Successfully sent the request";
  } catch (e) {
    throw Exception(e);
  }
}
