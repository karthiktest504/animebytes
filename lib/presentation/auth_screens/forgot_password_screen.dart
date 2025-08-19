import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _authService = AuthService();
  
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _authService.resetPassword(_emailController.text.trim());
      
      if (mounted) {
        setState(() => _emailSent = true);
        _showSuccessSnackBar('Password reset email sent! Please check your inbox.');
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

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green[600],
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
                
                SizedBox(height: 6.h),
                
                // Icon
                Center(
                  child: Container(
                    width: 20.w,
                    height: 20.w,
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.lock_reset,
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 10.w,
                    ),
                  ),
                ),
                
                SizedBox(height: 4.h),
                
                // Header
                _buildHeader(),
                
                SizedBox(height: 6.h),
                
                // Content based on state
                if (!_emailSent) _buildResetForm() else _buildSuccessMessage(),
                
                SizedBox(height: 4.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          _emailSent ? 'Check Your Email' : 'Forgot Password?',
          textAlign: TextAlign.center,
          style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 28.sp,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          _emailSent 
              ? 'We\'ve sent a password reset link to your email address.'
              : 'Don\'t worry! It happens. Please enter the email address associated with your account.',
          textAlign: TextAlign.center,
          style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 16.sp,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildResetForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Email Field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Email Address',
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
          
          SizedBox(height: 4.h),
          
          // Send Reset Email Button
          SizedBox(
            width: double.infinity,
            height: 6.h,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _sendResetEmail,
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
                      'Send Reset Link',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
          
          SizedBox(height: 3.h),
          
          // Back to Login
          Center(
            child: TextButton(
              onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.arrow_back,
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 5.w,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Back to Sign In',
                    style: TextStyle(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessMessage() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Icon(
                Icons.mark_email_read,
                color: Colors.green,
                size: 12.w,
              ),
              SizedBox(height: 2.h),
              Text(
                'Email Sent Successfully!',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                'Please check your inbox and follow the instructions to reset your password.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14.sp,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        
        SizedBox(height: 4.h),
        
        // Resend Email Button
        SizedBox(
          width: double.infinity,
          height: 6.h,
          child: OutlinedButton(
            onPressed: () => setState(() => _emailSent = false),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              'Resend Email',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        
        SizedBox(height: 2.h),
        
        // Back to Login
        Center(
          child: TextButton(
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
            child: Text(
              'Back to Sign In',
              style: TextStyle(
                color: AppTheme.lightTheme.colorScheme.primary,
                fontWeight: FontWeight.w500,
                fontSize: 14.sp,
              ),
            ),
          ),
        ),
      ],
    );
  }
}