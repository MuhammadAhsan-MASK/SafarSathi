import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserRoleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Immediate in-memory role state so UI transitions work instantaneously
  /// even when Firestore network writes are queued or offline.
  static final ValueNotifier<String?> localRoleNotifier = ValueNotifier<String?>(null);
  static String? _localRoleUid;

  static void setLocalRole(String? role, {String? uid}) {
    _localRoleUid = uid ?? FirebaseAuth.instance.currentUser?.uid;
    localRoleNotifier.value = role;
  }

  Future<String?> getUserRole() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    if (localRoleNotifier.value != null && _localRoleUid == user.uid) {
      return localRoleNotifier.value;
    }

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
      await Future.delayed(const Duration(seconds: 1));
      retries++;
    }
    return null;
  }

  Stream<String?> getUserRoleStream() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value(_localRoleUid == null ? localRoleNotifier.value : null);
    }

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
        final cred = await _auth.signInAnonymously().timeout(const Duration(seconds: 3));
        user = cred.user;
      } catch (e) {
        debugPrint('Anonymous signin fallback error: $e');
      }
    }
    if (user == null) {
      throw Exception('Unable to sign in to switch account mode.');
    }

    // Update local reactive role scoped to this authenticated uid
    setLocalRole(newRole, uid: user.uid);

    final Map<String, dynamic> data = {
      'role': newRole,
      'email': user.email ?? 'partner_${user.uid.substring(0, 6)}@sastasafar.pk',
      'name': user.displayName ?? (additionalData?['businessName'] ?? 'Service Partner'),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (additionalData != null) {
      data.addAll(additionalData);
    }

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(data, SetOptions(merge: true))
          .timeout(const Duration(seconds: 3));
    } catch (e) {
      // Queued in Firestore offline cache / ignored so UI isn't blocked offline
      debugPrint('Role sync deferred or timed out: $e');
    }
  }
}
