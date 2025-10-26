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
  // Future<bool> deposit({required int id, required double amount}) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final token = prefs.getString('authToken');
  //
  //   final url = Uri.parse('$baseUrl/deposit/$id');
  //
  //   final response = await http.post(
  //     url,
  //     headers: {
  //       'Authorization': 'Bearer $token',
  //       'Content-Type': 'application/json',
  //     },
  //     body: jsonEncode({'amount': amount}),
  //   );
  //
  //   return response.statusCode == 200;
  // }

  Future<String> depositMoney(int id, double amount) async {
    // API endpoint: /deposit/{id}?amount={amount}
    final url = Uri.parse('$baseUrl/deposit/$id?amount=$amount');

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    if (token == null) {
      throw Exception('User is not authenticated.');
    }

    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token', // JWT Token
        },

        body: json.encode({}),
      );

      if (response.statusCode == 200) {
        // সফল ডিপোজিট হলে Spring থেকে "Deposit successful" স্ট্রিং আসবে
        return response.body;
      } else if (response.statusCode == 404) {
        // যদি Account not found হয়
        throw Exception('Account not found. Status: ${response.statusCode}');
      } else {
        // অন্যান্য ত্রুটি
        throw Exception('Failed to deposit money. Status: ${response.statusCode}');
      }
    } catch (e) {
      // নেটওয়ার্ক ত্রুটি বা অন্যান্য ব্যতিক্রম
      throw Exception('An error occurred during deposit: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchCompanyVoltDetails() async {
    final url = Uri.parse('$baseUrl/showcompanydetails');

    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('authToken');
    if (token == null) {
      throw Exception('Admin authentication token not found. Please log in.');
    }

    final response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token', // JWT Token (Admin)
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.cast<Map<String, dynamic>>();
    } else {
      print("Failed to load company details. Status: ${response.statusCode}");
      throw Exception('Failed to load company details. Status: ${response.statusCode}');
    }
  }
}
