import 'dart:convert';
import 'package:general_insurance_management_system/model/firebill_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BillService {
  final String baseUrl = 'http://10.0.2.2:8085/api/firebill';

  // Fetch all bills with Spring Security token
  Future<List<FirebillModel>> fetchAllFireBills() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('authToken'); // token from login

    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': token != null ? 'Bearer $token' : '',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((b) {
        // Safety for nested policy
        if (b['policy'] == null) b['policy'] = {};
        return FirebillModel.fromJson(b);
      }).toList();
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized! Token may be invalid or expired.');
    } else {
      throw Exception('Failed to fetch bills: ${response.statusCode}');
    }
  }

  // Delete a bill (secured)
  Future<void> deleteBill(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('authToken');

    final response = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': token != null ? 'Bearer $token' : '',
      },
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete bill: ${response.body}');
    }
  }

  // Create a new bill (secured)
  Future<void> createFireBill(FirebillModel bill) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('authToken');

    final response = await http.post(
      Uri.parse('$baseUrl/add?policyId=${bill.policy.id}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': token != null ? 'Bearer $token' : '',
      },
      body: jsonEncode(bill.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create bill: ${response.body}');
    }
  }
}
