import 'dart:convert';

import 'package:general_insurance_management_system/model/account_model.dart';
import 'package:general_insurance_management_system/model/payment_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class PaymentService {
  final String baseUrl = 'http://localhost:8085/api/payment';

  // Fetch all bills with Spring Security token
  Future<List<Payment>> fetchPaymentDetails() async {
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
        if (b['payment'] == null) b['payment'] = {};
        return Payment.fromJson(b);
      }).toList();
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized! Token may be invalid or expired.');
    } else {
      throw Exception('Failed to fetch payments: ${response.statusCode}');
    }
  }



  Future<bool> payPremium({
    required int senderId,
    required int receiverId,
    required double amount,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    final url = Uri.parse(
      'http://localhost:8085/api/payment/pay'
          '?senderId=$senderId&receiverId=$receiverId&amount=$amount',
    );

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      print('✅ Payment Successful');
      return true;
    } else {
      print('❌ Payment Failed: ${response.body}');
      return false;
    }
  }


  // Helper: get stored JWT token from SharedPreferences
  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Inside PaymentService class

  Future<bool> deposit({required int id, required double amount}) async {
    final url = Uri.parse('$baseUrl/deposit/$id');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: {
        'amount': amount.toString(),
      },
    );
    return response.statusCode == 200;
  }

  Future<double?> getBalance(int id) async {
    final url = Uri.parse('$baseUrl/balance/$id');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      return double.tryParse(response.body);
    }
    return null;
  }

  Future<List<Payment>?> getAllPayments() async {
    final url = Uri.parse('$baseUrl/allpaymentdetails');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data.map((e) => Payment.fromJson(e)).toList();
    }
    return null;
  }

  Future<AccountModel?> getAccountDetails(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    final url = Uri.parse('$baseUrl/api/payment/$userId/account');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return AccountModel.fromJson(data);
    } else {
      throw Exception('Failed to load account');
    }
  }



}

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException(this.message);
  @override
  String toString() => message;
}