import 'package:flutter/material.dart';
import 'package:general_insurance_management_system/page/accounts_details.dart';
import 'package:general_insurance_management_system/page/data_store.dart';
import 'package:general_insurance_management_system/page/login.dart';
import 'package:general_insurance_management_system/page/money_receipt_for_user.dart'; // assuming this holds UserCoverNotesPage
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

  // --- Design Constants ---
  static const Color _primaryColor = Color(0xFF1976D2); // Blue 700
  static const Color _accentColor = Color(0xFFFF9800);  // Deep Orange for accent

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

  // Info Row Widget
  Widget _buildProfileInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, color: _primaryColor, size: 22),
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

  // Section Header Widget
  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, color: _primaryColor, size: 28),
          const SizedBox(width: 10),
          Text(
            title,
            style: GoogleFonts.archivoNarrow(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  // Grid Action Button Widget
  Widget _buildGridActionButton(BuildContext context,
      {required String title,
        required IconData icon,
        required Color color,
        required Widget page}) {
    return OpenContainer(
      transitionDuration: const Duration(milliseconds: 500),
      closedElevation: 3,
      closedColor: Colors.white,
      closedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      closedBuilder: (context, action) => InkWell(
        onTap: action, // OpenContainer action
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 36),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
        ),
      ),
      openBuilder: (context, action) => page,
    );
  }

  // Profile Header Card with Gradient
  Widget _buildProfileHeaderCard({
    required String name,
    required String position,
    required String userId,
    required Widget profilePicture}) {

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        // গ্ৰ্যাডিয়েন্ট ব্যাকগ্রাউন্ড
        gradient: LinearGradient(
          colors: [_primaryColor, _primaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(25.0),
      child: Column(
        children: [
          profilePicture,
          const SizedBox(height: 15),
          Text(
            name,
            style: GoogleFonts.montserrat(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            position,
            style: GoogleFonts.raleway(
              fontSize: 18,
              color: _accentColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'ID: $userId',
              style: GoogleFonts.roboto(
                fontSize: 14,
                color: Colors.white,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }


  // --- Logout Function ---
  void _handleLogout(BuildContext context) async {
    await _authService.logout();
    // Transition effect for logout
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => LoginPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeScaleTransition(animation: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    // API endpoint is usually defined once
    const String baseUrl = "http://localhost:8085/images/users/";
    final String photoName = profile['photo'] ?? '';
    final String? photoUrl = (photoName.isNotEmpty) ? "$baseUrl$photoName" : null;

    // Extracting data
    final String name = profile['name'] ?? 'N/A';
    final String email = profile['email'] ?? 'N/A';
    final String phone = profile['phone'] ?? 'N/A';
    final String role = profile['role']?.toString().toUpperCase() ?? 'USER';
    final int id = profile['id'] ?? 0;

    // Profile picture widget
    final Widget profilePictureWidget = Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: const [
          BoxShadow(color: Colors.black38, blurRadius: 15, offset: Offset(0, 5))
        ],
        color: Colors.white,
      ),
      child: ClipOval(
        child: photoUrl != null
            ? Image.network(
          photoUrl,
          fit: BoxFit.cover,
          width: 100,
          height: 100,
          errorBuilder: (context, error, stackTrace) => Lottie.asset(
            // Fallback Lottie animation if image fails
            'assets/lottie/user_placeholder.json',
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          ),
        )
            : const Icon(Icons.person_4, size: 50, color: Colors.blueGrey),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(
          'User Dashboard',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: _primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      // Smart Drawer
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              accountEmail: Text(email, style: GoogleFonts.roboto()),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: profilePictureWidget,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_primaryColor, _primaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),

            // Drawer items simplified
            _buildDrawerTile(context, Icons.account_balance_wallet, 'My Account', const AccountDetailsPage()),
            _buildDrawerTile(context, Icons.receipt_long, 'My Cover Notes', const UserCoverNotesPage()),
            _buildDrawerTile(context, Icons.currency_exchange, 'Make Payment', const UserAccountsPage()),


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
              onTap: () => _handleLogout(context),
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
              padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
              child: _buildProfileHeaderCard(
                name: name,
                position: role,
                userId: id.toString(),
                profilePicture: profilePictureWidget,
              ),
            ),
          ),

          // Action Grid
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: _buildSectionHeader('Quick Actions', Icons.dashboard),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            sliver: SliverGrid.count(
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 1.2, // Adjusts height/width ratio
              children: [
                _buildGridActionButton(
                  context,
                  title: 'My Account',
                  icon: Icons.account_balance_wallet_outlined,
                  color: Colors.green.shade600,
                  page: const AccountDetailsPage(),
                ),
                _buildGridActionButton(
                  context,
                  title: 'My Payable Amount',
                  icon: Icons.receipt_long,
                  color: Colors.orange.shade600,
                  page: const UserCoverNotesPage(),
                ),
                _buildGridActionButton(
                  context,
                  title: 'Make Payment',
                  icon: Icons.currency_exchange,
                  color: Colors.indigo.shade600,
                  page: const UserAccountsPage(),
                ),
              ],
            ),
          ),

          // User Info Card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              child: _buildSectionHeader('Contact Information', Icons.info_outline),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
                        _buildProfileInfoRow(Icons.person, 'Full Name', name),
                        _buildProfileInfoRow(Icons.email, 'Email', email),
                        _buildProfileInfoRow(Icons.phone, 'Phone Number', phone),
                        _buildProfileInfoRow(Icons.admin_panel_settings, 'Role', role),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30), // Bottom space
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// Helper for Drawer Tiles
Widget _buildDrawerTile(BuildContext context, IconData icon, String title, Widget page) {
  return ListTile(
    leading: Icon(icon, color: Colors.blueAccent.shade700),
    title: Text(title, style: GoogleFonts.roboto(fontSize: 16)),
    onTap: () {
      Navigator.pop(context); // Close Drawer
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => page),
      );
    },
  );
}