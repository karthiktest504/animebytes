import 'package:flutter/material.dart';
import '../presentation/story_detail_screen/story_detail_screen.dart';
import '../presentation/profile_settings_screen/profile_settings_screen.dart';
import '../presentation/saved_stories_screen/saved_stories_screen.dart';
import '../presentation/onboarding_flow_screen/onboarding_flow_screen.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/daily_feed_screen/daily_feed_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String storyDetail = '/story-detail-screen';
  static const String profileSettings = '/profile-settings-screen';
  static const String savedStories = '/saved-stories-screen';
  static const String onboardingFlow = '/onboarding-flow-screen';
  static const String splash = '/splash-screen';
  static const String dailyFeed = '/daily-feed-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    storyDetail: (context) => const StoryDetailScreen(),
    profileSettings: (context) => const ProfileSettingsScreen(),
    savedStories: (context) => const SavedStoriesScreen(),
    onboardingFlow: (context) => const OnboardingFlowScreen(),
    splash: (context) => const SplashScreen(),
    dailyFeed: (context) => const DailyFeedScreen(),
    // TODO: Add your other routes here
  };
}
