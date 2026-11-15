import 'package:flutter/material.dart';
import '../core/theme/app_tokens.dart';
import '../state/app_state.dart';
import 'dashboard_screen.dart';
import 'workout_screen.dart';
import 'nutrition_screen.dart';
import 'marketplace_screen.dart';
import 'profile_screen.dart';
import 'active_workout_screen.dart';
import 'home_workout_mode_screen.dart';
import 'meal_scanner_screen.dart';
import 'ai_coach_screen.dart';
import '../widgets/floating_timer_bar.dart';
import '../core/graphics/graphics.dart';
import '../core/navigation/page_transitions.dart';

class MainNavigationScreen extends StatefulWidget {
  final AppState state;

  const MainNavigationScreen({super.key, required this.state});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    widget.state.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    widget.state.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  void _navigateToActiveWorkout(String planId) {
    Navigator.push(
      context,
      GymBroPageRoute(
        builder: (_) => ActiveWorkoutScreen(
          planId: planId,
          state: widget.state,
        ),
      ),
    );
  }

  void _navigateToHomeWorkoutMode() {
    Navigator.push(
      context,
      GymBroPageRoute(
        builder: (_) => HomeWorkoutModeScreen(
          state: widget.state,
          onStartWorkout: (planId) {
            Navigator.pop(context);
            _navigateToActiveWorkout(planId);
          },
        ),
      ),
    );
  }

  void _navigateToMealScanner() {
    Navigator.push(
      context,
      GymBroPageRoute(
        builder: (_) => MealScannerScreen(state: widget.state),
      ),
    );
  }

  void _navigateToAiCoach() {
    Navigator.push(
      context,
      GymBroPageRoute(
        builder: (_) => AiCoachScreen(state: widget.state),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final theme = Theme.of(context);

    final screens = [
      RepaintBoundary(
        child: DashboardScreen(
          state: widget.state,
          onOpenMealScanner: _navigateToMealScanner,
          onOpenHomeMode: _navigateToHomeWorkoutMode,
          onOpenWorkouts: () => setState(() => _currentIndex = 1),
          onStartWorkout: _navigateToActiveWorkout,
          onOpenMarketplace: () => setState(() => _currentIndex = 3),
          onOpenAiCoach: _navigateToAiCoach,
          onOpenProfile: () => setState(() => _currentIndex = 4),
        ),
      ),
      RepaintBoundary(
        child: WorkoutScreen(
          state: widget.state,
          onStartWorkout: _navigateToActiveWorkout,
          onOpenHomeMode: _navigateToHomeWorkoutMode,
        ),
      ),
      RepaintBoundary(
        child: NutritionScreen(
          state: widget.state,
          onOpenScanner: _navigateToMealScanner,
        ),
      ),
      RepaintBoundary(
        child: MarketplaceScreen(
          state: widget.state,
        ),
      ),
      RepaintBoundary(
        child: ProfileScreen(
          state: widget.state,
        ),
      ),
    ];

    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_currentIndex != 0) {
          setState(() => _currentIndex = 0);
        }
      },
      child: Scaffold(
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
              return Stack(
                fit: StackFit.expand,
                alignment: Alignment.topLeft,
                children: <Widget>[
                  ...previousChildren,
                  if (currentChild != null) currentChild,
                ],
              );
            },
            transitionBuilder: (child, animation) {
              final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(animation);
              return AnimatedBuilder(
                animation: animation,
                builder: (context, child) {
                  // Slight vertical slide (8px upward) on tab change
                  final double dy = (1.0 - animation.value) * 8.0;
                  return Transform.translate(
                    offset: Offset(0.0, dy),
                    child: FadeTransition(
                      opacity: fadeAnimation,
                      child: child,
                    ),
                  );
                },
                child: child,
              );
            },
            child: KeyedSubtree(
              key: ValueKey<int>(_currentIndex),
              child: IndexedStack(
                index: _currentIndex,
                children: screens,
              ),
            ),
          ),
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const FloatingTimerBar(),
              NavigationBar(
                selectedIndex: _currentIndex,
                onDestinationSelected: (index) =>
                    setState(() => _currentIndex = index),
                backgroundColor: theme.colorScheme.surface,
                indicatorColor: tokens.lime.withOpacity(0.18),
                indicatorShape: const StadiumBorder(),
                height: 72,
                destinations: [
                  NavigationDestination(
                    icon: const GymBroIcon(
                      icon: GymBroNavIconType.home,
                      size: 22,
                      active: false,
                    ),
                    selectedIcon: GymBroIcon(
                      icon: GymBroNavIconType.home,
                      size: 22,
                      active: true,
                      activeColor: tokens.lime,
                    ),
                    label: 'داشبورد',
                  ),
                  NavigationDestination(
                    icon: const GymBroIcon(
                      icon: GymBroNavIconType.workout,
                      size: 22,
                      active: false,
                    ),
                    selectedIcon: GymBroIcon(
                      icon: GymBroNavIconType.workout,
                      size: 22,
                      active: true,
                      activeColor: tokens.lime,
                    ),
                    label: 'تمرینات',
                  ),
                  NavigationDestination(
                    icon: const GymBroIcon(
                      icon: GymBroNavIconType.nutrition,
                      size: 22,
                      active: false,
                    ),
                    selectedIcon: GymBroIcon(
                      icon: GymBroNavIconType.nutrition,
                      size: 22,
                      active: true,
                      activeColor: tokens.lime,
                    ),
                    label: 'تغذیه',
                  ),
                  NavigationDestination(
                    icon: const GymBroIcon(
                      icon: GymBroNavIconType.marketplace,
                      size: 22,
                      active: false,
                    ),
                    selectedIcon: GymBroIcon(
                      icon: GymBroNavIconType.marketplace,
                      size: 22,
                      active: true,
                      activeColor: tokens.lime,
                    ),
                    label: 'باشگاه',
                  ),
                  NavigationDestination(
                    icon: const GymBroIcon(
                      icon: GymBroNavIconType.profile,
                      size: 22,
                      active: false,
                    ),
                    selectedIcon: GymBroIcon(
                      icon: GymBroNavIconType.profile,
                      size: 22,
                      active: true,
                      activeColor: tokens.lime,
                    ),
                    label: 'پروفایل',
                  ),
                ],
              ),
            ],
          ),
        ),
    );
  }
}
