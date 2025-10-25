import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveUserData(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).set(data);
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserData(String uid) async {
    return await _db.collection('users').doc(uid).get();
  }

  Future<void> saveFireMoneyReceipt(String docId, Map<String, dynamic> data) async {
    await _db.collection('fire_money_receipts').doc(docId).set(data);
  }
}
