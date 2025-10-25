import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:general_insurance_management_system/model/user_model.dart';
import 'package:general_insurance_management_system/service/auth_service.dart';

// ⚠️ গুরুত্বপূর্ণ: আপনার সার্ভার অ্যাড্রেস পরিবর্তন না করে থাকলে,
// এটি মোবাইল ডিভাইসে কাজ করবে না। লোকালহোস্টের বদলে আপনার IPv4 অ্যাড্রেস ব্যবহার করুন।
const String _IMAGE_BASE_URL = 'http://localhost:8085/images/users/';

class AllUsersPage extends StatefulWidget {
  const AllUsersPage({super.key});

  @override
  State<AllUsersPage> createState() => _AllUsersPageState();
}

class _AllUsersPageState extends State<AllUsersPage> {
  late Future<List<UserModel>> _futureUsers;

  @override
  void initState() {
    super.initState();
    _futureUsers = AuthService().fetchAllUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Users (Admin Panel)"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 4, // AppBar-এ হালকা শ্যাডো যোগ করা হলো
      ),
      body: FutureBuilder<List<UserModel>>(
        future: _futureUsers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.deepPurple));
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 40),
                    const SizedBox(height: 10),
                    Text(
                      'Failed to load users. Please check server connection.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red.shade700, fontSize: 16),
                    ),
                    Text(
                      'Details: ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                  ],
                ),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No users found.", style: TextStyle(fontSize: 18, color: Colors.grey)));
          }

          final users = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];

                // সম্পূর্ণ ইমেজ URL তৈরি করা হচ্ছে
                final String? imageUrl = user.photo != null
                    ? '$_IMAGE_BASE_URL${user.photo}'
                    : null;

                // রোল অনুযায়ী রং সেট করা
                final isUserAdmin = user.role == Role.ADMIN;
                final roleColor = isUserAdmin ? Colors.red.shade700 : Colors.teal.shade700;

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  elevation: 3, // কার্ডকে আরও স্পষ্ট করতে হালকা শ্যাডো
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // গোলাকার কোণ

                  // এডমিন ইউজারের জন্য কার্ডের হালকা বর্ডার দেওয়া হলো
                  color: isUserAdmin ? Colors.red.shade50 : Colors.white,

                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),

                    // ----------------------------------------------------
                    // স্মার্ট ইমেজ হ্যান্ডলিং এর জন্য CachedNetworkImage ব্যবহার
                    // ----------------------------------------------------
                    leading: CircleAvatar(
                      radius: 28, // একটু বড় করা হলো
                      backgroundColor: isUserAdmin
                          ? Colors.red.shade400
                          : Colors.teal.shade400,

                      child: ClipOval(
                        child: imageUrl != null && imageUrl.isNotEmpty
                            ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          width: 56,
                          height: 56,
                          // ছবি লোড হওয়ার সময় একটি ছোট Circular Indicator দেখানো
                          placeholder: (context, url) => Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                                backgroundColor: roleColor,
                              ),
                            ),
                          ),
                          // ছবি লোড না হলে বা ভুল হলে একটি আইকন দেখানো
                          errorWidget: (context, url, error) => const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 30,
                          ),
                        )
                        // যদি URL না থাকে, নামের প্রথম অক্ষর দেখানো (Fallback)
                            : Text(
                          user.name?.substring(0, 1).toUpperCase() ?? "?",
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      ),
                    ),
                    // ----------------------------------------------------

                    title: Text(
                      user.name ?? "Unknown",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          user.email ?? "No Email",
                          style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                        ),
                        Text(
                          "Phone: ${user.phone ?? 'N/A'}",
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                        ),
                      ],
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: roleColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: roleColor, width: 1),
                      ),
                      child: Text(
                        user.role?.toString().split('.').last ?? 'N/A',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: roleColor,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}