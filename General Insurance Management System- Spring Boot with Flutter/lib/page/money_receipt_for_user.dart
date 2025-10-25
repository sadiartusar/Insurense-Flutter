// page/user_cover_notes_page.dart

import 'package:flutter/material.dart';
import 'package:general_insurance_management_system/service/http_service.dart';
// AuthService ইমপোর্ট করার দরকার নেই, কারণ HttpService নিজেই ইমেইল/টোকেন ম্যানেজ করছে।

class UserCoverNotesPage extends StatefulWidget {
  const UserCoverNotesPage({super.key});

  @override
  State<UserCoverNotesPage> createState() => _UserCoverNotesPageState();
}

class _UserCoverNotesPageState extends State<UserCoverNotesPage> {
  // late Future<List<Map<String, dynamic>>> _notesFuture;

  @override
  void initState() {
    super.initState();
    // 💡 পেজ লোড হওয়ার সাথে সাথেই ডেটা ফেচ করা
    // _notesFuture = HttpService().fetchUserCoverNotes(); 
    // State এর ভেতরে ফাংশনকে লজিক সহ কল করার জন্য initState এর পর call করা হলো
  }

  // 💡 ডেটা ফেচ করার ফাংশন
  Future<List<Map<String, dynamic>>> _fetchNotes() async {
    // HttpService টোকেন ব্যবহার করে সুরক্ষিতভাবে ডেটা ফেচ করবে
    return HttpService().fetchUserCoverNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Fire Cover Notes'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchNotes(), // 💡 এখানে কল করা হলো
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Error: Could not load data. ${snapshot.error.toString()}', textAlign: TextAlign.center,),
                )
            );
          } else if (snapshot.hasData && snapshot.data!.isEmpty) {
            return const Center(
                child: Text('No Cover Notes have been issued to you yet.')
            );
          } else {
            final notes = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                return _buildNoteCard(note);
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildNoteCard(Map<String, dynamic> note) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cover Note No: ${note['coverNoteNo'] ?? 'N/A'}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal)),
            const Divider(),
            _buildInfoRow('Policyholder', note['policyholder'] ?? 'N/A'),
            _buildInfoRow('Sum Insured', '${(note['sumInsured'] ?? 0.0).toStringAsFixed(2)} TK'),
            _buildInfoRow('Gross Premium', '${(note['grossPremium'] ?? 0.0).toStringAsFixed(2)} TK', isBold: true),
            _buildInfoRow('Monthly Premium', '${(note['monthlyPremium'] ?? 0.0).toStringAsFixed(2)} TK', isMonthly: true),
            // Date format: Spring Boot থেকে আসা ISO String কে শুধু date এ দেখানো
            _buildInfoRow('Date Issued', note['issuedAt']?.toString().substring(0, 10) ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  // ছোট UI helper
  Widget _buildInfoRow(String title, String value, {bool isBold = false, bool isMonthly = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontWeight: isBold ? FontWeight.w600 : FontWeight.normal)),
          Text(value, style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : (isMonthly ? FontWeight.w800 : FontWeight.w500),
              color: isMonthly ? Colors.green.shade700 : Colors.black87
          )),
        ],
      ),
    );
  }
}