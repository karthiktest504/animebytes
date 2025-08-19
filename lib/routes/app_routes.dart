import 'package:flutter/material.dart';
import '../presentation/story_detail_screen/story_detail_screen.dart';
import '../presentation/profile_settings_screen/profile_settings_screen.dart';
import '../presentation/saved_stories_screen/saved_stories_screen.dart';
import '../presentation/onboarding_flow_screen/onboarding_flow_screen.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/daily_feed_screen/daily_feed_screen.dart';
import '../presentation/auth_screens/welcome_screen.dart';
import '../presentation/auth_screens/login_screen.dart';
import '../presentation/auth_screens/signup_screen.dart';
import '../presentation/auth_screens/forgot_password_screen.dart';

class AppRoutes {
  // App routes
  static const String initial = '/';
  static const String splash = '/splash-screen';
  
  // Auth routes
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  
  // Main app routes
  static const String onboardingFlow = '/onboarding-flow-screen';
  static const String dailyFeed = '/daily-feed-screen';
  static const String storyDetail = '/story-detail-screen';
  static const String profileSettings = '/profile-settings-screen';
  static const String savedStories = '/saved-stories-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    splash: (context) => const SplashScreen(),
    
    // Auth screens
    welcome: (context) => const WelcomeScreen(),
    login: (context) => const LoginScreen(),
    signup: (context) => const SignupScreen(),
    forgotPassword: (context) => const ForgotPasswordScreen(),
    
    // Main app screens
    onboardingFlow: (context) => const OnboardingFlowScreen(),
    dailyFeed: (context) => const DailyFeedScreen(),
    storyDetail: (context) => const StoryDetailScreen(),
    profileSettings: (context) => const ProfileSettingsScreen(),
    savedStories: (context) => const SavedStoriesScreen(),
  };
}
