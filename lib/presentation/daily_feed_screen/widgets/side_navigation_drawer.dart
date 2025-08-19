import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../models/user_profile.dart';
import '../../../services/auth_service.dart';

class SideNavigationDrawer extends StatefulWidget {
  final UserProfile? userProfile;

  const SideNavigationDrawer({
    super.key,
    this.userProfile,
  });

  @override
  State<SideNavigationDrawer> createState() => _SideNavigationDrawerState();
}

class _SideNavigationDrawerState extends State<SideNavigationDrawer> {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[900] : Colors.white,
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),

              Divider(color: Colors.grey[400]),

              // Navigation items
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(vertical: 1.h),
                  children: [
                    _buildNavItem(
                      icon: Icons.home_outlined,
                      title: 'Daily Digest',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushReplacementNamed(
                            context, AppRoutes.dailyFeed);
                      },
                    ),
                    _buildNavItem(
                      icon: Icons.bookmark_outline,
                      title: 'Saved Items',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, AppRoutes.savedStories);
                      },
                    ),
                    _buildNavItem(
                      icon: Icons.favorite_outline,
                      title: 'Liked Shorts',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, AppRoutes.savedStories,
                            arguments: 'liked');
                      },
                    ),
                    _buildNavItem(
                      icon: Icons.settings_outlined,
                      title: 'Settings',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, AppRoutes.profileSettings);
                      },
                    ),
                    _buildNavItem(
                      icon: Icons.feedback_outlined,
                      title: 'Feedback',
                      onTap: () {
                        Navigator.pop(context);
                        _showFeedbackDialog();
                      },
                    ),
                  ],
                ),
              ),

              // ...existing code...
              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        children: [
          // Avatar
          CircleAvatar(
            radius: 30.sp,
            backgroundImage: widget.userProfile?.avatarUrl != null
                ? CachedNetworkImageProvider(widget.userProfile!.avatarUrl!)
                : null,
            child: widget.userProfile?.avatarUrl == null
                ? Icon(Icons.person, size: 36.sp)
                : null,
          ),

          SizedBox(height: 2.h),

          // Name
          Text(
            widget.userProfile?.fullName ?? 'Guest User',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),

          // Email or login prompt
          if (widget.userProfile != null) ...[
            SizedBox(height: 0.5.h),
            Text(
              widget.userProfile!.email,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[600],
              ),
            ),

            // Daily streak
            if (widget.userProfile!.dailyStreak > 0) ...[
              SizedBox(height: 1.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: Colors.orange.withAlpha(26),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.orange),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.local_fire_department,
                        size: 14.sp, color: Colors.orange),
                    SizedBox(width: 1.w),
                    Text(
                      '${widget.userProfile!.dailyStreak} day streak',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ] else ...[
            SizedBox(height: 0.5.h),
            Text(
              'Sign in to save stories & personalize',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        size: 22.sp,
        color: textColor ??
            (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: textColor ??
              (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87),
        ),
      ),
      onTap: onTap,
      dense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 4.w),
    );
  }

  void _handleSignOut() async {
    try {
      Navigator.pop(context);
      await _authService.signOut();
      Navigator.pushReplacementNamed(context, AppRoutes.dailyFeed);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signed out successfully')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Sign out failed: $error'),
            backgroundColor: Colors.red),
      );
    }
  }

  void _showInviteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Invite Friends'),
        content: const Text(
            'Share AnimeBytes with your friends and earn rewards when they join!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement share functionality
            },
            child: const Text('Share App'),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog() {
    final TextEditingController feedbackController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Feedback'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Help us improve AnimeBytes!'),
            SizedBox(height: 2.h),
            TextField(
              controller: feedbackController,
              decoration: const InputDecoration(
                hintText: 'Enter your feedback...',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Thank you for your feedback!')),
              );
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  void _showAuthDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign In Required'),
        content: const Text(
            'Please sign in to access personalized features and save your favorite stories.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to auth screen when implemented
            },
            child: const Text('Sign In'),
          ),
        ],
      ),
    );
  }
}