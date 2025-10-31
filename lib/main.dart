import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fyro_invoicing/services/database_service.dart';
import 'package:fyro_invoicing/services/auth_service.dart';
import 'package:fyro_invoicing/theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/employee_dashboard.dart';
import 'screens/admin_dashboard.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize database (Hive - for offline support)
  await DatabaseService.init();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Biryani By Flame',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AuthWrapper(),
    );
  }
}

// Wrapper to check authentication state
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    print('🔄 AuthWrapper: Building...');

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        print('🔄 AuthWrapper: ConnectionState = ${snapshot.connectionState}');
        print('🔄 AuthWrapper: HasData = ${snapshot.hasData}');
        print('🔄 AuthWrapper: User = ${snapshot.data?.uid}');

        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          print('⏳ AuthWrapper: Waiting for auth state...');
          return const Scaffold(
            backgroundColor: AppTheme.primaryBlack,
            body: Center(
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppTheme.secondaryGold),
              ),
            ),
          );
        }

        // Not logged in
        if (!snapshot.hasData || snapshot.data == null) {
          print('❌ AuthWrapper: No user logged in, showing LoginScreen');
          return const LoginScreen();
        }

        print('✅ AuthWrapper: User logged in, UID: ${snapshot.data!.uid}');

        // Logged in - determine which dashboard to show
        return FutureBuilder(
          future: AuthService().getCurrentEmployee(),
          builder: (context, employeeSnapshot) {
            print(
                '📄 FutureBuilder: ConnectionState = ${employeeSnapshot.connectionState}');
            print('📄 FutureBuilder: HasData = ${employeeSnapshot.hasData}');
            print(
                '📄 FutureBuilder: Employee = ${employeeSnapshot.data?.name}');

            if (employeeSnapshot.connectionState == ConnectionState.waiting) {
              print('⏳ FutureBuilder: Loading employee data...');
              return const Scaffold(
                backgroundColor: AppTheme.primaryBlack,
                body: Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppTheme.secondaryGold),
                  ),
                ),
              );
            }

            final employee = employeeSnapshot.data;
            if (employee == null) {
              print(
                  '❌ FutureBuilder: No employee data found, showing LoginScreen');
              return const LoginScreen();
            }

            print(
                '✅ FutureBuilder: Employee found - ${employee.name} (${employee.role})');

            // Show appropriate dashboard based on role
            if (employee.isAdmin) {
              print('🔑 Showing AdminDashboard');
              return const AdminDashboard();
            } else {
              print('👤 Showing EmployeeDashboard');
              return const EmployeeDashboard();
            }
          },
        );
      },
    );
  }
}
