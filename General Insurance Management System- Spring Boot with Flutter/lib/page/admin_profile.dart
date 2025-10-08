

import 'package:flutter/material.dart';
import 'package:general_insurance_management_system/service/auth_service.dart';

class AdminProfile extends StatelessWidget {
  final Map<String, dynamic> profile;
  final AuthService _authService = AuthService();


  AdminProfile({Key? key, required this.profile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String baseUrl = "http://localhost:8085/images/admin/";
    final String? photoName = profile['photo'];
    final String? photoUrl = (photoName != null && photoName.isNotEmpty)
        ? "$baseUrl$photoName"
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Profile"),
        backgroundColor: Colors.black12,
        centerTitle: true,
      ),
      drawer: _buildDrawer(context, photoUrl),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(photoUrl),
            const SizedBox(height: 24),
            _buildSectionTitle("Personal Info"),
            _buildInfoRow("Phone", profile['phone']),
            _buildInfoRow("Address", profile['address']),
            _buildInfoRow("role", profile['role']),
            const SizedBox(height: 20),

          ],
        ),
      ),
    );
  }

  // ------------------------
  // PROFILE HEADER
  // ------------------------
  Widget _buildProfileHeader(String? photoUrl) {
    return Center(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))],
              border: Border.all(color: Colors.purple, width: 3),
            ),
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey[200],
              backgroundImage: (photoUrl != null)
                  ? NetworkImage(photoUrl)
                  : const AssetImage('asset/images/avatar.jpg') as ImageProvider,
            ),
          ),
          const SizedBox(height: 12),
          Text(profile['name'] ?? 'Unknown', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text("Email: ${profile['user']?['email'] ?? 'N/A'}", style: TextStyle(fontSize: 16, color: Colors.grey[700])),
        ],
      ),
    );
  }

  // ------------------------
  // DRAWER
  // ------------------------
  Drawer _buildDrawer(BuildContext context, String? photoUrl) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Colors.purple),
            accountName: Text(profile['name'] ?? 'Unknown User', style: const TextStyle(fontWeight: FontWeight.bold)),
            accountEmail: Text(profile['user']?['email'] ?? 'N/A'),
            currentAccountPicture: CircleAvatar(
              backgroundImage: (photoUrl != null)
                  ? NetworkImage(photoUrl)
                  : const AssetImage('assets/images/default_avatar.jpg') as ImageProvider,
            ),
          ),
          _buildDrawerItem(context, Icons.person, "My Profile", () => Navigator.pop(context)),
          _buildDrawerItem(context, Icons.abc, "Summary", () async {

          }),

        ],
      ),
    );
  }

  ListTile _buildDrawerItem(BuildContext context, IconData icon, String title, VoidCallback onTap, {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color)),
      onTap: onTap,
    );
  }

  // ------------------------
  // SECTION TITLES
  // ------------------------
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildInfoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value?.toString() ?? "N/A")),
        ],
      ),
    );
  }

  // ------------------------
  // EDUCATION
  // ------------------------
  List<Widget> _buildEducationSection() {
    return List.generate(profile['educations']?.length ?? 0, (i) {
      final edu = profile['educations'][i];
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("${edu['level']} - ${edu['institute']}", style: const TextStyle(fontWeight: FontWeight.bold)),
              Text("${edu['board'] ?? 'N/A'}, ${edu['year']}"),
              Text("Result: ${edu['result']}"),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildSkillsSection() {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: List.generate(profile['skills']?.length ?? 0, (i) {
        final skill = profile['skills'][i];
        return Chip(label: Text("${skill['name']} (${skill['level']})"), backgroundColor: Colors.indigo[50]);
      }),
    );
  }

  List<Widget> _buildExperienceSection() {
    return List.generate(profile['experiences']?.length ?? 0, (i) {
      final exp = profile['experiences'][i];
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: ListTile(
          title: Text("${exp['position']} - ${exp['company']}"),
          subtitle: Text("${exp['fromDate'] ?? 'N/A'} to ${exp['toDate'] ?? 'N/A'}\n${exp['description'] ?? ''}"),
        ),
      );
    });
  }

  Widget _buildHobbiesSection() {
    return Wrap(
      spacing: 8,
      children: List.generate(profile['hobbies']?.length ?? 0, (i) {
        final h = profile['hobbies'][i];
        return Chip(label: Text(h['name']));
      }),
    );
  }

  Widget _buildLanguagesSection() {
    return Wrap(
      spacing: 8,
      children: List.generate(profile['languages']?.length ?? 0, (i) {
        final lang = profile['languages'][i];
        return Chip(label: Text("${lang['name']} (${lang['proficiency']})"));
      }),
    );
  }

  List<Widget> _buildReferencesSection() {
    return List.generate(profile['refferences']?.length ?? 0, (i) {
      final ref = profile['refferences'][i];
      return ListTile(
        title: Text(ref['name']),
        subtitle: Text("${ref['relation']} - ${ref['contact']}"),
        leading: Icon(Icons.person, color: Colors.purple),
      );
    });
  }

  List<Widget> _buildTrainingsSection() {
    return List.generate(profile['trainings']?.length ?? 0, (i) {
      final tr = profile['trainings'][i];
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: ListTile(
          title: Text(tr['title']),
          subtitle: Text("${tr['institute']} - ${tr['duration']}"),
        ),
      );
    });
  }
}