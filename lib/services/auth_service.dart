import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/employee.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current employee details
  Future<Employee?> getCurrentEmployee() async {
    final user = currentUser;
    if (user == null) return null;

    try {
      // Add retry logic for Firestore connection issues
      return await _retryFirestoreOperation(() async {
        final doc =
            await _firestore.collection('employees').doc(user.uid).get();
        if (!doc.exists) return null;
        return Employee.fromMap(doc.data()!);
      });
    } catch (e) {
      print('❌ Error getting current employee: $e');
      return null;
    }
  }

  // Retry helper for Firestore operations
  Future<T> _retryFirestoreOperation<T>(
    Future<T> Function() operation, {
    int maxAttempts = 3,
    Duration delay = const Duration(milliseconds: 500),
  }) async {
    int attempts = 0;
    Duration currentDelay = delay;

    while (attempts < maxAttempts) {
      try {
        attempts++;
        return await operation();
      } catch (e) {
        print('⚠️ Firestore operation attempt $attempts failed: $e');

        if (attempts >= maxAttempts) {
          print('❌ Max retry attempts reached. Giving up.');
          rethrow;
        }

        // Check if it's a Firestore internal error
        if (e.toString().contains('INTERNAL ASSERTION FAILED') ||
            e.toString().contains('FIRESTORE')) {
          print('🔄 Retrying in ${currentDelay.inMilliseconds}ms...');
          await Future.delayed(currentDelay);
          currentDelay *= 2; // Exponential backoff
        } else {
          // If it's not a Firestore error, don't retry
          rethrow;
        }
      }
    }

    throw Exception('Failed after $maxAttempts attempts');
  }

  // Sign in with email and password
  Future<Employee?> signIn(String email, String password) async {
    try {
      print('🔐 Attempting to sign in with: $email');

      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('✅ Authentication successful! UID: ${credential.user!.uid}');

      // Get employee details with retry logic
      print('📄 Fetching employee document from Firestore...');

      final employee = await _retryFirestoreOperation(() async {
        final doc = await _firestore
            .collection('employees')
            .doc(credential.user!.uid)
            .get();

        if (!doc.exists) {
          print('❌ Employee document not found in Firestore');
          throw Exception('Employee not found in database');
        }

        print('✅ Employee document found!');
        print('📋 Document data: ${doc.data()}');

        return Employee.fromMap(doc.data()!);
      });

      print('✅ Employee object created: ${employee.name} (${employee.role})');

      return employee;
    } on FirebaseAuthException catch (e) {
      print('❌ Firebase Auth error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e, stackTrace) {
      print('❌ Sign in error: $e');
      print('📍 Stack trace: $stackTrace');

      // If employee not found, sign out
      if (e.toString().contains('Employee not found')) {
        await _auth.signOut();
      }

      rethrow;
    }
  }

  // Create new employee (Admin only)
  Future<Employee> createEmployee({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
    required double salary,
    String? address,
    String? emergencyContact,
  }) async {
    try {
      // Create auth user
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create employee document
      final employee = Employee(
        id: credential.user!.uid,
        name: name,
        email: email,
        phone: phone,
        role: role,
        salary: salary,
        joiningDate: DateTime.now(),
        address: address,
        emergencyContact: emergencyContact,
      );

      await _firestore
          .collection('employees')
          .doc(employee.id)
          .set(employee.toMap());

      return employee;
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Change password
  Future<void> changePassword(String newPassword) async {
    await currentUser?.updatePassword(newPassword);
  }
}
