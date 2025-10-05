import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Logout extends StatefulWidget {
  const Logout({super.key});

  @override
  State<Logout> createState() => _LogoutState();
}

class _LogoutState extends State<Logout> {
  bool _isLoggingOut = false; // State to manage logout progress

  Future<void> _logout(BuildContext context) async {
    setState(() {
      _isLoggingOut = true; // Show loading indicator
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all stored preferences
    if (context.mounted) {
      setState(() {
        _isLoggingOut = false; // Hide loading indicator
      });
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false); // Navigate to login page
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Successfully logged out')),
      ); // Show logout confirmation
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _logout(context); // Call the logout function
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'ইসলামী ইন্স্যুরেন্স কোম্পানী বাংলাদেশ লিমিটেড',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(
              'mdkutub150@gmail.com, +8801763001787',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green, Colors.blue, Colors.lightGreen, Colors.teal],
            ),
          ),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const CircleAvatar(
              backgroundImage: NetworkImage(
                'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQntUidjT9ib73xOZ_LYOvhZg9bSvlU9hOGjaWbTALttUeqeEjJUWKJHbT4r1UqjFM3caQ&usqp=CAU',
              ),
            ),
            tooltip: 'Open Drawer',
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      body: Center(
        child: _isLoggingOut
            ? const CircularProgressIndicator() // Show a loading spinner during logout
            : ElevatedButton.icon(
          onPressed: _showLogoutDialog, // Show logout dialog when button is pressed
          icon: const Icon(Icons.logout),
          label: const Text('Logout'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red, // Button background color
            foregroundColor: Colors.white, // Text and icon color
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8), // Rounded corners
            ),
          ),
        ),
      ),
    );
  }
}