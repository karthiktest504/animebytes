import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();
  
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUpWithEmail() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeToTerms) {
      _showErrorSnackBar('Please agree to the Terms of Service and Privacy Policy');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _authService.signUpWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _fullNameController.text.trim(),
      );

      if (response.user != null && mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Account created successfully! Please check your email to verify.'),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        
        // Navigate to onboarding or main app
        Navigator.pushReplacementNamed(context, '/onboarding-flow-screen');
      }
    } on AuthException catch (e) {
      if (mounted) {
        _showErrorSnackBar(e.message);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('An unexpected error occurred. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      await _authService.signInWithGoogle();
      // The auth state listener will handle navigation
    } on AuthException catch (e) {
      if (mounted) {
        _showErrorSnackBar(e.message);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Google sign-in failed. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signInWithApple() async {
    setState(() => _isLoading = true);

    try {
      await _authService.signInWithApple();
      // The auth state listener will handle navigation
    } on AuthException catch (e) {
      if (mounted) {
        _showErrorSnackBar(e.message);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Apple sign-in failed. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
              Color(0xFF0F0F23),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 2.h),
                
                // Back Button
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    padding: EdgeInsets.all(3.w),
                  ),
                ),
                
                SizedBox(height: 3.h),
                
                // Header
                _buildHeader(),
                
                SizedBox(height: 4.h),
                
                // Signup Form
                _buildSignupForm(),
                
                SizedBox(height: 3.h),
                
                // Social Login
                _buildSocialLogin(),
                
                SizedBox(height: 3.h),
                
                // Sign In Link
                _buildSignInLink(),
                
                SizedBox(height: 2.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create Account',
          style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 28.sp,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          'Join thousands of anime fans worldwide',
          style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 16.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildSignupForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Full Name Field
          TextFormField(
            controller: _fullNameController,
            keyboardType: TextInputType.name,
            textCapitalization: TextCapitalization.words,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Full Name',
              labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
              prefixIcon: Icon(Icons.person_outlined, color: Colors.white.withValues(alpha: 0.7)),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.lightTheme.colorScheme.primary, width: 2),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your full name';
              }
              if (value.trim().length < 2) {
                return 'Name must be at least 2 characters';
              }
              return null;
            },
          ),
          
          SizedBox(height: 2.h),
          
          // Email Field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Email',
              labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
              prefixIcon: Icon(Icons.email_outlined, color: Colors.white.withValues(alpha: 0.7)),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.lightTheme.colorScheme.primary, width: 2),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          
          SizedBox(height: 2.h),
          
          // Password Field
          TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Password',
              labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
              prefixIcon: Icon(Icons.lock_outlined, color: Colors.white.withValues(alpha: 0.7)),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
                onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
              ),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.lightTheme.colorScheme.primary, width: 2),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a password';
              }
              if (value.length < 8) {
                return 'Password must be at least 8 characters';
              }
              if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
                return 'Password must contain uppercase, lowercase and number';
              }
              return null;
            },
          ),
          
          SizedBox(height: 2.h),
          
          // Confirm Password Field
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: !_isConfirmPasswordVisible,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
              prefixIcon: Icon(Icons.lock_outlined, color: Colors.white.withValues(alpha: 0.7)),
              suffixIcon: IconButton(
                icon: Icon(
                  _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
                onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
              ),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.lightTheme.colorScheme.primary, width: 2),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              }
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          
          SizedBox(height: 2.h),
          
          // Terms Agreement
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: _agreeToTerms,
                onChanged: (value) => setState(() => _agreeToTerms = value ?? false),
                activeColor: AppTheme.lightTheme.colorScheme.primary,
                checkColor: Colors.white,
                side: BorderSide(color: Colors.white.withValues(alpha: 0.5)),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 1.5.w),
                  child: Text.rich(
                    TextSpan(
                      text: 'I agree to the ',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 13.sp,
                      ),
                      children: [
                        TextSpan(
                          text: 'Terms of Service',
                          style: TextStyle(
                            color: AppTheme.lightTheme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        const TextSpan(text: ' and '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: TextStyle(
                            color: AppTheme.lightTheme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 3.h),
          
          // Sign Up Button
          SizedBox(
            width: double.infinity,
            height: 6.h,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _signUpWithEmail,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey[600],
                elevation: 8,
                shadowColor: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialLogin() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.3))),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                'Or sign up with',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 14.sp,
                ),
              ),
            ),
            Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.3))),
          ],
        ),
        
        SizedBox(height: 3.h),
        
        Row(
          children: [
            // Google Sign Up
            Expanded(
              child: SizedBox(
                height: 6.h,
                child: OutlinedButton.icon(
                  onPressed: _isLoading ? null : _signInWithGoogle,
                  icon: Image.asset(
                    'assets/images/google_logo.png',
                    width: 5.w,
                    height: 5.w,
                    errorBuilder: (context, error, stackTrace) => 
                        Icon(Icons.g_mobiledata, color: Colors.white, size: 6.w),
                  ),
                  label: Text(
                    'Google',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),
            
            SizedBox(width: 4.w),
            
            // Apple Sign Up
            Expanded(
              child: SizedBox(
                height: 6.h,
                child: OutlinedButton.icon(
                  onPressed: _isLoading ? null : _signInWithApple,
                  icon: Icon(Icons.apple, color: Colors.white, size: 6.w),
                  label: Text(
                    'Apple',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSignInLink() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Already have an account? ",
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 14.sp,
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
            child: Text(
              'Sign In',
              style: TextStyle(
                color: AppTheme.lightTheme.colorScheme.primary,
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}