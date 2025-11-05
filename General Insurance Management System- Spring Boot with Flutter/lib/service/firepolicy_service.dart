import 'dart:convert';

import 'package:general_insurance_management_system/model/firepolicy_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FirePolicyService {
  final String baseUrl = 'http://localhost:8085/api/firepolicy';

  // Fetch all policies (can generalize for different policy types)
  Future<List<PolicyModel>> fetchPolicies({String policyType = ''}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken'); // 🔑 টোকেন নিন

      final response = await http.get(
        Uri.parse(baseUrl + policyType),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // ✅ Token পাঠালাম
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> policyJson = json.decode(response.body);
        return policyJson.map((json) => PolicyModel.fromJson(json)).toList();
      } else if (response.statusCode == 403) {
        throw Exception('Forbidden: You do not have permission.');
      } else {
        throw Exception('Failed to load policies: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }



  //  Create a new marine policy
  Future<PolicyModel> createFireBill(PolicyModel policy, String? token) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token'); // Adjust key based on your implementation

    final response = await http.post(
      Uri.parse("${baseUrl}save"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': token != null ? 'Bearer $token' : '', // Include token if available
      },
      body: json.encode(policy.toJson()),
    );

    if (response.statusCode == 201) {
      return PolicyModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create policy bill: ${response.statusCode} ${response.body}');
    }
  }

  /// Deletes a fire policy by ID.
  Future<bool> deleteFirePolicy(int id) async {
    final String apiUrl = '$baseUrl/$id';

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('authToken');
      final response = await http.delete(Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token != null ? 'Bearer $token' : '',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true; // Deletion successful
      } else {
        throw Exception('Failed to delete fire Policy: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Error deleting fire Policy: $e');
    }
  }

  /// Updates a marine policy by ID.
  Future<void> updateFirePolicy(int id, PolicyModel policy) async {
    final response = await http.put(
      Uri.parse('${baseUrl}update/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(policy.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to update fire  Policy: ${response.body}');
    }
  }

}