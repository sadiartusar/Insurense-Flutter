import 'package:flutter/material.dart';
import 'package:general_insurance_management_system/model/user_model.dart';
import 'package:general_insurance_management_system/service/auth_service.dart';



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
      ),
      body: FutureBuilder<List<UserModel>>(
        future: _futureUsers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No users found."));
          }

          final users = snapshot.data!;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                    user.role == Role.ADMIN ? Colors.red : Colors.green,
                    child: Text(
                      user.name?.substring(0, 1).toUpperCase() ?? "?",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(user.name ?? "Unknown"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.email ?? ""),
                      Text("Phone: ${user.phone ?? 'N/A'}"),
                    ],
                  ),
                  trailing: Text(
                    user.role?.toString().split('.').last ?? 'N/A',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color:
                      user.role == Role.ADMIN ? Colors.red : Colors.green,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
