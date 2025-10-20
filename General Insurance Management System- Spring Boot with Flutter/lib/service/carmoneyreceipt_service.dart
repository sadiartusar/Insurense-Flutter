
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

  // Create a new marine bill
  Future<void> createMoneyReceipt(CarMoneyReceiptModel receipt, String policyId, {String? token}) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final response = await http.post(Uri.parse(baseUrl + "/add"),
      headers: headers,
      body: jsonEncode(receipt.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to create Car bill');
    }
  }

  /// Deletes a fire money receipt by ID.
  Future<bool> deleteMoneyReceipt(int id) async {
    final String apiUrl = '${baseUrl}delete/$id';

    try {
      final response = await http.delete(Uri.parse(apiUrl));

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