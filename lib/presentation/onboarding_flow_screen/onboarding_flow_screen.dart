import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import './widgets/genre_selection_widget.dart';
import './widgets/interactive_demo_widget.dart';
import './widgets/onboarding_card_widget.dart';
import './widgets/page_indicator_widget.dart';

class OnboardingFlowScreen extends StatefulWidget {
  const OnboardingFlowScreen({super.key});

  @override
  State<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends State<OnboardingFlowScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  int _currentPage = 0;
  List<String> _selectedGenres = [];
  bool _canProceed = false;

  final List<Map<String, dynamic>> _onboardingData = [
    {
      'title': 'Welcome to AnimeBytes',
      'description':
          'Discover daily anime news and updates in a story-style format. Swipe through bite-sized content perfect for your busy schedule.',
      'imagePath':
          'https://images.unsplash.com/photo-1578662996442-48f60103fc96?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3',
      'backgroundColor': const Color(0xFF6C5CE7),
      'buttonText': 'Get Started',
      'showGestureHints': false,
    },
    {
      'title': 'Navigate Like a Pro',
      'description':
          'Tap left and right edges to navigate between stories. Try the interactive demo below to get the hang of it!',
      'imagePath':
          'https://images.unsplash.com/photo-1551698618-1dfe5d97d256?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3',
      'backgroundColor': const Color(0xFFA29BFE),
      'buttonText': 'Try It Out',
      'showGestureHints': true,
      'demoType': 'tap_zones',
    },
    {
      'title': 'Like, Save & Share',
      'description':
          'Interact with stories you love. Like your favorites, save for later reading, and share with fellow anime fans.',
      'imagePath':
          'https://images.unsplash.com/photo-1607604276583-eef5d076aa5f?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3',
      'backgroundColor': const Color(0xFF00B894),
      'buttonText': 'Practice Actions',
      'demoType': 'actions',
    },
    {
      'title': 'Personalize Your Feed',
      'description':
          'Choose your favorite anime genres to get personalized content recommendations tailored just for you.',
      'imagePath':
          'https://images.unsplash.com/photo-1578662996442-48f60103fc96?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3',
      'backgroundColor': const Color(0xFFE17055),
      'buttonText': 'Start Reading',
      'showGenreSelection': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _fadeController.forward();
    _checkCanProceed();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _checkCanProceed() {
    setState(() {
      if (_currentPage == _onboardingData.length - 1) {
        _canProceed = _selectedGenres.length >= 3;
      } else {
        _canProceed = true;
      }
    });
  }

  void _onGenresSelected(List<String> genres) {
    setState(() {
      _selectedGenres = genres;
    });
    _checkCanProceed();
  }

  void _nextPage() {
    if (_currentPage < _onboardingData.length - 1) {
      HapticFeedback.lightImpact();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipOnboarding() {
    HapticFeedback.lightImpact();
    _completeOnboarding();
  }

  Future<void> _handlePrimaryAction() async {
    if (_currentPage < _onboardingData.length - 1) {
      _nextPage();
      return;
    }

    if (_selectedGenres.length < 3) {
      HapticFeedback.selectionClick();
      final proceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Continue without enough genres?'),
          content: const Text(
            'Selecting at least 3 genres helps personalize your feed. Do you want to continue anyway?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Pick More'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Continue'),
            ),
          ],
        ),
      );

      if (proceed != true) return;
    }

    await _completeOnboarding();
  }

  Future<void> _completeOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_completed', true);
      await prefs.setBool('has_seen_onboarding', true); // Ensure flag is set for splash screen
      await prefs.setStringList('selected_genres', _selectedGenres);

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/daily-feed-screen');
      }
    } catch (e) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/daily-feed-screen');
      }
    }
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    _checkCanProceed();
  }

  void _onInteractionComplete() {
    setState(() {
      _canProceed = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
          children: [
            // Main content
            PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: _onboardingData.length,
              itemBuilder: (context, index) {
                final data = _onboardingData[index];
                return OnboardingCardWidget(
                  title: data['title'],
                  description: data['description'],
                  imagePath: data['imagePath'],
                  backgroundColor: data['backgroundColor'],
                  showGestureHints: data['showGestureHints'] ?? false,
                  interactiveElement: _buildInteractiveElement(data),
                );
              },
            ),

            // Skip button
            if (_currentPage < _onboardingData.length - 1)
              Positioned(
                top: 8.h,
                right: 6.w,
                child: SafeArea(
                  child: TextButton(
                    onPressed: _skipOnboarding,
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.black.withValues(alpha: 0.3),
                      padding:
                          EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'Skip',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                ),
              ),

            // Bottom controls
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Page indicator
                      PageIndicatorWidget(
                        currentPage: _currentPage,
                        totalPages: _onboardingData.length,
                        activeColor: Colors.white,
                        inactiveColor: Colors.white.withValues(alpha: 0.4),
                      ),

                      SizedBox(height: 3.h),

                      // Action button
                      SizedBox(
                        width: double.infinity,
                        height: 6.h,
                        child: ElevatedButton(
                          onPressed: _handlePrimaryAction,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: _onboardingData[_currentPage]
                                ['backgroundColor'],
                            disabledBackgroundColor:
                                Colors.white.withValues(alpha: 0.3),
                            disabledForegroundColor:
                                Colors.white.withValues(alpha: 0.5),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            _onboardingData[_currentPage]['buttonText'],
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ),

                      // Additional info for genre selection
                      if (_currentPage == _onboardingData.length - 1 &&
                          _selectedGenres.length < 3)
                        Padding(
                          padding: EdgeInsets.only(top: 1.h),
                          child: Text(
                            'Please select at least 3 genres to continue',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget? _buildInteractiveElement(Map<String, dynamic> data) {
    if (data['showGenreSelection'] == true) {
      return GenreSelectionWidget(
        onGenresSelected: _onGenresSelected,
        initialSelectedGenres: _selectedGenres,
      );
    }

    if (data['demoType'] != null) {
      return InteractiveDemoWidget(
        demoType: data['demoType'],
        onInteraction: _onInteractionComplete,
      );
    }

    return null;
  }
}