import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'employee_dashboard.dart';
import 'admin_dashboard.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      print('🚀 Login button pressed');
      print('📧 Email: ${_emailController.text.trim()}');

      final authService = AuthService();
      final employee = await authService.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );

      print('✅ Sign in completed, employee: ${employee?.name}');

      if (employee != null && mounted) {
        print(
            '🔀 Navigating to ${employee.isAdmin ? "Admin" : "Employee"} Dashboard');

        // Navigate to appropriate dashboard
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => employee.isAdmin
                ? const AdminDashboard()
                : const EmployeeDashboard(),
          ),
        );
      } else {
        print('⚠️ Employee is null!');
      }
    } catch (e, stackTrace) {
      print('❌ Login error caught in UI: $e');
      print('📍 Stack trace: $stackTrace');

      if (mounted) {
        // Better error messages
        String errorMessage = 'Login failed';
        if (e.toString().contains('user-not-found')) {
          errorMessage = 'No user found with this email';
        } else if (e.toString().contains('wrong-password')) {
          errorMessage = 'Incorrect password';
        } else if (e.toString().contains('invalid-email')) {
          errorMessage = 'Invalid email format';
        } else if (e.toString().contains('Employee not found')) {
          errorMessage = 'Employee account not set up in database';
        } else if (e.toString().contains('network')) {
          errorMessage = 'Network error. Check your connection';
        } else {
          errorMessage = 'Login failed: ${e.toString()}';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: AppTheme.primaryBlack,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isSmallScreen ? 16 : 32),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 450),
            child: Card(
              color: AppTheme.darkGrey,
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: EdgeInsets.all(isSmallScreen ? 24 : 40),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo and title
                      Icon(
                        Icons.local_fire_department,
                        size: isSmallScreen ? 60 : 80,
                        color: AppTheme.secondaryGold,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'BIRYANI BY FLAME',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 20 : 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.secondaryGold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Employee Login',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                          color: AppTheme.lightGold,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Email field
                      TextFormField(
                        controller: _emailController,
                        autofocus: true,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        cursorColor: AppTheme.secondaryGold,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppTheme.primaryBlack,
                          labelText: 'Email / Employee ID',
                          labelStyle:
                              const TextStyle(color: AppTheme.lightGold),
                          prefixIcon: const Icon(
                            Icons.person,
                            color: AppTheme.lightGold,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                                color: AppTheme.lightGold, width: 1),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                                color: AppTheme.lightGold, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppTheme.secondaryGold,
                              width: 2,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Password field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        cursorColor: AppTheme.secondaryGold,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppTheme.primaryBlack,
                          labelText: 'Password',
                          labelStyle:
                              const TextStyle(color: AppTheme.lightGold),
                          prefixIcon: const Icon(
                            Icons.lock,
                            color: AppTheme.lightGold,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: AppTheme.lightGold,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                                color: AppTheme.lightGold, width: 1),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                                color: AppTheme.lightGold, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppTheme.secondaryGold,
                              width: 2,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Login button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.secondaryGold,
                            foregroundColor: AppTheme.primaryBlack,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppTheme.primaryBlack,
                                    ),
                                  ),
                                )
                              : Text(
                                  'LOGIN',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 14 : 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
