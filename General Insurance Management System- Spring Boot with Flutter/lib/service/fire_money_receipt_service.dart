
import 'package:general_insurance_management_system/model/firemoneyreceipt_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class MoneyReceiptService {
  final String baseUrl = 'http://localhost:8085/api/firemoneyreciept';

  Future<List<FireMoneyReceiptModel>> fetchMoneyReceipts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');
      final response = await http.get(Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // ✅ Token পাঠালাম
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> policyJson = json.decode(response.body);
        return policyJson
            .map((json) => FireMoneyReceiptModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load Fire Bills');
      }
    }
    catch(e){
      throw Exception('Network error: $e');
    }
  }

  // Create a new fire receipt
  Future<void> createMoneyReceipt(
      FireMoneyReceiptModel receipt,
      int billId,
      ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken'); // ✅ same key everywhere

    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    // ✅ URL এ billId পাঠাও query parameter হিসেবে
    final url = Uri.parse('$baseUrl/add?billId=$billId');

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(receipt.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('✅ Fire Money Receipt created successfully');
    } else {
      print('❌ Error: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to create receipt: ${response.reasonPhrase}');
    }
  }


  /// Deletes a fire money receipt by ID.
  Future<bool> deleteMoneyReceipt(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken'); // ✅ consistent key

    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    // ✅ Ensure correct slash in URL
    final url = Uri.parse('$baseUrl/$id');

    try {
      final response = await http.delete(url, headers: headers);

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ Money receipt deleted successfully.');
        return true;
      } else {
        print('❌ Failed to delete: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to delete fire money receipt.');
      }
    } catch (e) {
      print('❌ Exception deleting receipt: $e');
      throw Exception('Error deleting money receipt: $e');
    }
  }


  // Updates a fire bill by ID.
  Future<void> updateMoneyReceipt(int id, FireMoneyReceiptModel moneyreceipt) async {
    try {
      final response = await http.put(
        Uri.parse('${baseUrl}update/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(moneyreceipt.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('Money receipt updated successfully.');
      } else {
        final errorMessage = jsonDecode(response.body)['message'] ?? 'Unknown error';
        throw Exception('Failed to update fire money receipt: $errorMessage (Status: ${response.statusCode})');
      }
    } catch (e) {
      print('Error updating money receipt: $e');
      throw Exception('Could not update money receipt. Please check your network connection and try again.');
    }
  }

}