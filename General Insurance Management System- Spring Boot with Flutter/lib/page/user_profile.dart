import 'package:flutter/material.dart';
import 'package:general_insurance_management_system/page/login.dart';
import 'package:general_insurance_management_system/page/user_accounts_page.dart';
import 'package:general_insurance_management_system/service/auth_service.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:animations/animations.dart';

class UserPage extends StatelessWidget {
  final Map<String, dynamic> profile;
  final AuthService _authService = AuthService();

  UserPage({super.key, required this.profile});

  // Date Formatting Function
  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return 'N/A';
    }
    try {
      final DateTime date = DateTime.parse(dateString);
      return DateFormat('dd MMMM, yyyy').format(date);
    } catch (e) {
      return 'Invalid Date';
    }
  }

  // Info Row Widget - Using Google Fonts
  Widget _buildProfileInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, color: Colors.indigo.shade700, size: 22),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widget to create clear section headers - Using Google Fonts
  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent.shade700, size: 28),
          const SizedBox(width: 10),
          Text(
            title,
            style: GoogleFonts.archivoNarrow(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent.shade700,
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widget for Animated Profile Card
  Widget _buildProfileHeaderCard(
      {required String name,
        required String position,
        required String status,
        required Color statusColor,
        required String userId,
        required Widget profilePicture}) { // Accepts the animated picture

    // Using OpenContainer for a neat reveal of the whole header
    return OpenContainer(
      transitionDuration: const Duration(milliseconds: 600),
      closedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      closedElevation: 8,
      closedColor: Colors.white,
      closedBuilder: (context, action) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            profilePicture, // Animated Picture
            const SizedBox(height: 20),
            Text(
              name,
              style: GoogleFonts.montserrat(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              position,
              style: GoogleFonts.raleway(
                fontSize: 18,
                color: Colors.deepOrange.shade600,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'User ID: $userId',
              style: GoogleFonts.roboto(
                fontSize: 15,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: statusColor, width: 1.5),
              ),
              child: Text(
                'Status: $status',
                style: GoogleFonts.roboto(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
      ),
      openBuilder: (context, action) => // Simple Modal for full detail view
      Scaffold(
        appBar: AppBar(title: Text('${name}\'s Details')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                profilePicture,
                const SizedBox(height: 20),
                Text('Full Profile View for ${name}', style: GoogleFonts.poppins(fontSize: 24)),
                // You can add more detailed info here if needed
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Base image URL (change this to your backend image folder)
    const String baseUrl = "http://localhost:8085/images/users/";
    final String photoName = profile['photo'] ?? '';
    final String? photoUrl = (photoName.isNotEmpty) ? "$baseUrl$photoName" : null;

    // Extracting data from profile map (UserModel JSON)
    final String name = profile['name'] ?? 'N/A';
    final String email = profile['email'] ?? 'N/A';
    final String phone = profile['phone'] ?? 'N/A';
    final String role = profile['role']?.toString().toUpperCase() ?? 'USER';
    final int id = profile['id'] ?? 0;

    // For simplicity, we can assume user is always active (optional)
    const String status = 'ACTIVE';
    final Color statusColor = status == 'ACTIVE' ? Colors.green.shade600 : Colors.red.shade600;

    // Profile picture widget
    final Widget profilePictureWidget = Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.blueAccent.shade700, width: 4),
        boxShadow: const [
          BoxShadow(color: Colors.black38, blurRadius: 15, offset: Offset(0, 8))
        ],
        color: Colors.white,
      ),
      child: ClipOval(
        child: photoUrl != null
            ? Image.network(
          photoUrl,
          fit: BoxFit.cover,
          width: 120,
          height: 120,
          errorBuilder: (context, error, stackTrace) => Lottie.asset(
            'assets/lottie/loading_animation.json',
            width: 120,
            height: 120,
            fit: BoxFit.cover,
          ),
        )
            : const Icon(Icons.person_4, size: 60, color: Colors.blueGrey),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        title: Text(
          'User Profile',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blueAccent.shade700,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      // Simple Drawer
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(name),
              accountEmail: Text(email),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: photoUrl != null
                    ? ClipOval(
                  child: Image.network(
                    photoUrl,
                    fit: BoxFit.cover,
                    width: 90,
                    height: 90,
                    errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.person, size: 50, color: Colors.blueGrey),
                  ),
                )
                    : const Icon(Icons.person, size: 50),
              ),
              decoration: const BoxDecoration(
                color: Colors.blueAccent,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.payment_outlined),
              title: const Text('Payment'),

              onTap: () => Navigator.push(context,MaterialPageRoute(builder: (context) => const UserAccountsPage()),),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Account'),
              onTap: () => Navigator.pop(context),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              onTap: () async {
                await _authService.logout();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => LoginPage()),
                );
              },
            ),
          ],
        ),
      ),

      // Main body
      body: CustomScrollView(
        slivers: <Widget>[
          // Header card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: _buildProfileHeaderCard(
                name: name,
                position: role,
                status: status,
                statusColor: statusColor,
                userId: id.toString(),
                profilePicture: profilePictureWidget,
              ),
            ),
          ),

          // Info card
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        _buildSectionHeader('User Information', Icons.person),
                        _buildProfileInfoRow(Icons.badge, 'User ID', id.toString()),
                        _buildProfileInfoRow(Icons.person, 'Full Name', name),
                        _buildProfileInfoRow(Icons.email, 'Email', email),
                        _buildProfileInfoRow(Icons.phone, 'Phone Number', phone),
                        _buildProfileInfoRow(Icons.admin_panel_settings, 'Role', role),
                      ],
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

}