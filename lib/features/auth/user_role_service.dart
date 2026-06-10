import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserRoleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> getUserRole() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    // Retry logic to handle race condition during signup
    int retries = 0;
    while (retries < 5) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return doc.data()?['role'] as String?;
      }
      // Wait 1 second before retrying
      await Future.delayed(const Duration(seconds: 1));
      retries++;
    }
    return null;
  }
}
