import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:jwt_decode/jwt_decode.dart';
import 'package:shared_preferences/shared_preferences.dart';
class AuthService {
  final String baseUrl = 'http://localhost:8085'; // Your backend API base URL

  /// ✅ Login method
  /// Sends credentials, gets a JWT, decodes it, and stores token + role.
  Future<bool> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/api/user/login');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'email': email, 'password': password});

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final String token = data['token'];

      // Decode token to extract role
      final Map<String, dynamic> payload = Jwt.parseJwt(token);
      final String role = payload['role'];

      // Save token, role, and optionally user info
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('authToken', token);
      await prefs.setString('userRole', role);

      // ✅ If backend returns user info in login response, save it
      if (data.containsKey('user')) {
        await prefs.setString('user', jsonEncode(data['user']));
      }

      return true;
    } else {
      print('❌ Failed to log in: ${response.body}');
      return false;
    }
  }


  Future<bool> register(Map<String, dynamic> user) async {
    final url = Uri.parse('$baseUrl/register');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode(user);

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      String token = data['token'];

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('authToken', token);

      return true;
    } else {
      print('Failed to register: ${response.body}');
      return false;
    }
  }

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  Future<String?> getUserRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print(prefs.getString('userRole'));
    return prefs.getString('userRole');
  }

  Future<bool> isTokenExpired() async {
    String? token = await getToken();
    if (token != null) {
      DateTime expiryDate = Jwt.getExpiryDate(token)!;
      return DateTime.now().isAfter(expiryDate);
    }
    return true;
  }

  Future<bool> isLoggedIn() async {
    String? token = await getToken();
    if (token != null && !(await isTokenExpired())) {
      return true;
    } else {
      await logout();
      return false;
    }
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
    await prefs.remove('userRole');
  }

  Future<bool> hasRole(List<String> roles) async {
    String? role = await getUserRole();
    return role != null && roles.contains(role);
  }

  Future<bool> isAdmin() async {
    return await hasRole(['ADMIN']);
  }


  Future<bool> isUser() async {
    return await hasRole(['USER']);
  }


  Future<Map<String, dynamic>?> getAdminProfile() async {
    String? token = await AuthService().getToken();

    if (token == null) {
      print('No token found, please login first.');
      return null;
    }

    final url = Uri.parse('$baseUrl/api/user/profile');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Failed to load profile: ${response.statusCode} - ${response.body}');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    String? token = await getToken();

    if (token == null) {
      print("Please login first");
      return null;
    }

    final url = Uri.parse('$baseUrl/api/user/profile');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Failed to load Profile: ${response.statusCode} - ${response.body}');
      return null;
    }
  }

  Future<String> fetchBalance(int userId) async {
    // আপনার টোকেন এখানে ইনজেক্ট করতে হবে
    String? token = "আপনার_সেভ_করা_bearer_token"; // আপনার টোকেন দিন

    if (token == null) {
      return 'Token Error';
    }

    final url = Uri.parse('http://localhost:8085/api/payment/balance/$userId');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // API থেকে সরাসরি '5570.0' এর মতো স্ট্রিং আসছে
        return response.body;
      } else {
        // যদি সার্ভার কোনো এরর দেয়
        return 'Failed to load balance. Status: ${response.statusCode}';
      }
    } catch (e) {
      // নেটওয়ার্ক বা অন্য কোনো এরর
      return 'Network Error: $e';
    }
  }


}