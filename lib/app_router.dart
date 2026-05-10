import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/home_screen.dart';
import 'screens/task_detail_screen.dart';
import 'screens/edit_task_screen.dart';
import 'screens/search_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/focus_screen.dart';
import 'screens/ai_assistant_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'models/task_model.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/signup', builder: (_, __) => const SignupScreen()),
    GoRoute(path: '/forgot-password', builder: (_, __) => const ForgotPasswordScreen()),
    GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
    GoRoute(
      path: '/task/:id',
      builder: (_, state) {
        final task = state.extra as TaskModel;
        return TaskDetailScreen(task: task);
      },
    ),
    GoRoute(
      path: '/task/:id/edit',
      builder: (_, state) {
        final task = state.extra as TaskModel;
        return EditTaskScreen(task: task);
      },
    ),
    GoRoute(path: '/search', builder: (_, __) => const SearchScreen()),
    GoRoute(path: '/calendar', builder: (_, __) => const CalendarScreen()),
    GoRoute(path: '/focus', builder: (_, __) => const FocusScreen()),
    GoRoute(path: '/ai-assistant', builder: (_, __) => const AiAssistantScreen()),
    GoRoute(path: '/analytics', builder: (_, __) => const AnalyticsScreen()),
    GoRoute(path: '/notifications', builder: (_, __) => const NotificationsScreen()),
    GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
    GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
  ],
  errorBuilder: (_, state) => Scaffold(
    body: Center(child: Text('Route not found: ${state.uri}')),
  ),
);
