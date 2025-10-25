import 'dart:convert';

import 'package:general_insurance_management_system/model/user_model.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decode/jwt_decode.dart';
import 'package:shared_preferences/shared_preferences.dart';
class AuthService {
  final String baseUrl = 'http://localhost:8085'; // Your backend API base URL

  /// ✅ Login method
  /// Sends credentials, gets a JWT, decodes it, and stores token + role.
  // Future<bool> login(String email, String password) async {
  //   final url = Uri.parse('$baseUrl/api/user/login');
  //   final headers = {'Content-Type': 'application/json'};
  //   final body = jsonEncode({'email': email, 'password': password});
  //
  //   final response = await http.post(url, headers: headers, body: body);
  //
  //   if (response.statusCode == 200) {
  //     final data = jsonDecode(response.body);
  //     final String token = data['token'];
  //
  //     // Decode token to extract role
  //     final Map<String, dynamic> payload = Jwt.parseJwt(token);
  //     final String role = payload['role'];
  //
  //     // Save token, role, and optionally user info
  //     final prefs = await SharedPreferences.getInstance();
  //     await prefs.setString('authToken', token);
  //     await prefs.setString('userRole', role);
  //
  //     // ✅ If backend returns user info in login response, save it
  //     if (data.containsKey('user')) {
  //       await prefs.setString('user', jsonEncode(data['user']));
  //     }
  //
  //     return true;
  //   } else {
  //     print('❌ Failed to log in: ${response.body}');
  //     return false;
  //   }
  // }

  // Future<bool> login(String email, String password) async {
  //   final url = Uri.parse('$baseUrl/api/user/login');
  //   final headers = {'Content-Type': 'application/json'};
  //   final body = jsonEncode({'email': email, 'password': password});
  //
  //   final response = await http.post(url, headers: headers, body: body);
  //
  //   if (response.statusCode == 200) {
  //     final data = jsonDecode(response.body);
  //     final String token = data['token'];
  //
  //     // Decode token for role
  //     final Map<String, dynamic> payload = Jwt.parseJwt(token);
  //     final String role = payload['role'] ?? payload['rol'] ?? 'USER';
  //
  //     int? userId;
  //
  //     // ✅ Only fetch userId for USER, not for ADMIN
  //     if (role == 'USER') {
  //       if (data.containsKey('user') &&
  //           data['user'] != null &&
  //           data['user']['id'] != null) {
  //         userId = data['user']['id'];
  //       }
  //
  //       if (userId == null) {
  //         userId = await _fetchUserIdFromProfile(token);
  //       }
  //
  //       if (userId == null) {
  //         print('User ID not found in login response or profile');
  //         return false;
  //       }
  //     }
  //
  //     // Save token, role, and (only for USER) userId
  //     final prefs = await SharedPreferences.getInstance();
  //     await prefs.setString('authToken', token);
  //     await prefs.setString('userRole', role);
  //
  //     if (userId != null) {
  //       await prefs.setInt('userId', userId);
  //     }
  //
  //     print("✅ Login success as $role");
  //     return true;
  //   } else {
  //     print('Login failed: ${response.body}');
  //     return false;
  //   }
  // }

  Future<bool> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/api/user/login');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'email': email, 'password': password});

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String token = data['token'];

        // ✅ Decode token to get role safely
        final Map<String, dynamic> payload = Jwt.parseJwt(token);
        final String role = payload['role'] ?? payload['rol'] ?? 'USER';

        int? userId;
        String? userEmail;
        String? userName;

        // ✅ Only for USER role
        if (role == 'USER') {
          if (data.containsKey('user') && data['user'] != null) {
            final user = data['user'];
            userId = user['id'];
            userEmail = user['email'];
            userName = user['name'];
          }

          // যদি backend login response এ user না দেয়, তাহলে profile থেকে আনি
          if (userId == null) {
            final profileData = await _fetchUserProfile(token);
            if (profileData != null) {
              userId = profileData['id'];
              userEmail = profileData['email'];
              userName = profileData['name'];
            }
          }

          if (userId == null) {
            print('⚠️ User ID not found.');
            return false;
          }
        }

        // ✅ Save credentials securely
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('authToken', token);
        await prefs.setString('userRole', role);

        if (userId != null) await prefs.setInt('userId', userId);
        if (userEmail != null) await prefs.setString('userEmail', userEmail);
        if (userName != null) await prefs.setString('userName', userName);

        print("✅ Login success as $role (${userEmail ?? 'Unknown user'})");
        return true;
      } else {
        print('❌ Login failed: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('🚨 Login error: $e');
      return false;
    }
  }



  // Fetch user profile to get user ID if not in login response
  Future<int?> _fetchUserIdFromProfile(String token) async {
    final url = Uri.parse('$baseUrl/api/user/profile');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final profileData = jsonDecode(response.body);
      if (profileData != null && profileData['id'] != null) {
        return profileData['id'];
      }
    } else {
      print('Failed to fetch profile: ${response.statusCode}');
    }
    return null;
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

  /// ✅ Fetch all users (ADMIN only)
  Future<List<UserModel>> fetchAllUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    final role = prefs.getString('userRole');

    if (token == null) {
      throw Exception('❌ No token found. Please login first.');
    }

    if (role != 'ADMIN') {
      throw Exception('⛔ Access denied. Only ADMIN can view all users.');
    }

    const String url = 'http://localhost:8085/api/user/all';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => UserModel.fromJson(json)).toList();
    } else if (response.statusCode == 403) {
      throw Exception('🚫 Unauthorized: Admin access required.');
    } else {
      throw Exception(
          '❌ Failed to fetch users. Status: ${response.statusCode}, Body: ${response.body}');
    }
  }


  Future<Map<String, dynamic>?> _fetchUserProfile(String token) async {
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
      print('❌ Failed to fetch profile: ${response.statusCode}');
      return null;
    }
  }



}