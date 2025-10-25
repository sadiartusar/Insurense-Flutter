import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:general_insurance_management_system/service/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HttpService {

  static const String baseUrl = 'http://localhost:8085/api/usercovernotes';

  Future<void> sendCoverNote(Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/save-for-user');

    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('authToken');


    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        // 2️⃣ Authorization Header এ টোকেন যোগ করা
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Data successfully sent to Spring Boot backend.");
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      // টোকেন ভুল বা মেয়াদোত্তীর্ণ হলে
      throw Exception('Authentication Failed. Check token validity and permissions.');
    } else {
      print("Failed to save data. Status: ${response.statusCode}");
      throw Exception('Failed to save cover note data. Status: ${response.statusCode} - ${response.body}');
    }
  }

  Future<List<Map<String, dynamic>>> fetchUserCoverNotes() async {
    // সুরক্ষিত পদ্ধতিতে, আমরা URL এ ইমেইল পাঠাবো না। Spring Boot টোকেন থেকে ইমেইল নেবে।
    final url = Uri.parse('$baseUrl/my');

    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('authToken');
    if (token == null) {
      throw Exception('User is not authenticated.');
    }

    final response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token', // JWT Token
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.cast<Map<String, dynamic>>();
    } else {
      print("Failed to load data. Status: ${response.statusCode}");
      throw Exception('Failed to load user cover notes. Status: ${response.statusCode}');
    }
  }

}