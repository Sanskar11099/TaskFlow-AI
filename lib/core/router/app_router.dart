import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../ui/auth/splash_screen.dart';
import '../../ui/auth/onboarding_screen.dart';
import '../../ui/auth/login_screen.dart';
import '../../ui/auth/signup_screen.dart';
import '../../ui/auth/forgot_password_screen.dart';
import '../../ui/home/home_screen.dart';
import '../../ui/task/task_detail_screen.dart';
import '../../ui/task/edit_task_screen.dart';
import '../../ui/search/search_screen.dart';
import '../../ui/calendar/calendar_screen.dart';
import '../../ui/focus/focus_screen.dart';
import '../../ui/ai/ai_assistant_screen.dart';
import '../../ui/analytics/analytics_screen.dart';
import '../../ui/notifications/notifications_screen.dart';
import '../../ui/profile/profile_screen.dart';
import '../../ui/settings/settings_screen.dart';
import '../../data/models/task_model.dart';

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
