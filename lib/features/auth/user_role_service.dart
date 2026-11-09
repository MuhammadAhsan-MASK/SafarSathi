import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserRoleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> getUserRole() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    // Retry logic to handle race condition during signup
    int retries = 0;
    while (retries < 5) {
      try {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          return doc.data()?['role'] as String?;
        }
      } catch (e) {
        debugPrint('Error fetching role: $e');
      }
      // Wait 1 second before retrying
      await Future.delayed(const Duration(seconds: 1));
      retries++;
    }
    return null;
  }

  Stream<String?> getUserRoleStream() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(null);

    return _firestore.collection('users').doc(user.uid).snapshots().map((doc) {
      if (doc.exists) {
        return doc.data()?['role'] as String?;
      }
      return null;
    });
  }

  Future<void> updateUserRole(String newRole, {Map<String, dynamic>? additionalData}) async {
    User? user = _auth.currentUser;
    if (user == null) {
      try {
        final cred = await _auth.signInAnonymously();
        user = cred.user;
      } catch (e) {
        debugPrint('Anonymous signin fallback error: $e');
      }
    }
    if (user == null) throw Exception('No user logged in');

    final Map<String, dynamic> data = {
      'role': newRole,
      'email': user.email ?? 'partner_${user.uid.substring(0, 6)}@sastasafar.pk',
      'name': user.displayName ?? (additionalData?['businessName'] ?? 'Service Partner'),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (additionalData != null) {
      data.addAll(additionalData);
    }

    await _firestore.collection('users').doc(user.uid).set(
      data,
      SetOptions(merge: true),
    );
  }
}
