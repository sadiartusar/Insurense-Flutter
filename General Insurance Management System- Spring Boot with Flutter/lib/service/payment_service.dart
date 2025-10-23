import 'dart:convert';
import 'package:general_insurance_management_system/model/account_model.dart';
import 'package:general_insurance_management_system/model/payment_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class PaymentService {
  final String baseUrl = 'http://localhost:8085/api/payment';

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



  /// ✅ Get balance for a user
  Future<double?> getBalance(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    final url = Uri.parse('$baseUrl/balance/$id');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return double.tryParse(response.body);
    } else {
      print('❌ Failed to get balance: ${response.body}');
      return null;
    }
  }

  /// ✅ Get all payment history
  Future<List<Payment>?> getAllPayments() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    final url = Uri.parse('$baseUrl/allpaymentdetails');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data.map((e) => Payment.fromJson(e)).toList();
    } else {
      print('❌ Failed to fetch payments: ${response.body}');
      return null;
    }
  }

  /// ✅ Get logged-in user's account details using saved userId
  Future<AccountModel?> getLoggedInUserAccount() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    final userId = prefs.getInt('userId');

    print('🔐 PaymentService - token: $token');
    print('👤 PaymentService - userId: $userId');

    if (token == null || userId == null || userId == 0) {
      throw Exception('User not logged in or userId missing');
    }

    final url = Uri.parse('$baseUrl/$userId');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return AccountModel.fromJson(data);
    } else {
      print('❌ Failed to fetch account: ${response.body}');
      throw Exception('Failed to load account');
    }
  }

  /// ✅ Deposit into user account
  Future<bool> deposit({required int id, required double amount}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    final url = Uri.parse('$baseUrl/deposit/$id');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'amount': amount}),
    );

    return response.statusCode == 200;
  }
}
