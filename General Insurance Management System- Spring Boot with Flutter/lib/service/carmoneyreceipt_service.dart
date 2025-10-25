
import 'package:general_insurance_management_system/model/carmoneyreceipt_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class CarMoneyReceiptService {
  final String baseUrl = 'http://localhost:8085/api/carmoneyreciept';

  Future<List<CarMoneyReceiptModel>> fetchMoneyReceipts() async {
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
            .map((json) => CarMoneyReceiptModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load Car Bills');
      }
    }
    catch(e){
      throw Exception('Network error: $e');
    }
  }

  Future<void> createMoneyReceipt(
  CarMoneyReceiptModel  receipt,
      int carBillId,
      ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken'); // ✅ same key everywhere

    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final url = Uri.parse('$baseUrl/add?carBillId=$carBillId');

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(receipt.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('✅ Car Money Receipt created successfully');
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

    final url = Uri.parse('$baseUrl/$id');

    try {
      final response = await http.delete(url, headers:headers);

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true; // Deletion successful
      } else {
        throw Exception('Failed to delete Car Money Receipt: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Error deleting Marine Money Receipt: $e');
    }
  }

  // Updates a fire bill by ID.
  Future<void> updateMoneyReceipt(int id, CarMoneyReceiptModel moneyreceipt) async {
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
        throw Exception('Failed to update car money receipt: $errorMessage (Status: ${response.statusCode})');
      }
    } catch (e) {
      print('Error updating money receipt: $e');
      throw Exception('Could not update money receipt. Please check your network connection and try again.');
    }
  }

}