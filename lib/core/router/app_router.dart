import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';

import '../../features/home/screens/customer_home_screen.dart';
import '../../features/services/screens/services_screen.dart';
import '../../features/services/screens/service_details_screen.dart';
import '../../features/requests/screens/create_request_screen.dart';
import '../../features/requests/screens/request_success_screen.dart';
import '../../features/requests/screens/my_requests_screen.dart';
import '../../features/requests/screens/request_details_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/edit_profile_screen.dart';
import '../../features/agent/screens/agent_dashboard_screen.dart';
import '../../features/agent/screens/agent_request_details_screen.dart';
import '../../models/service_item.dart';
import '../../models/service_request.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),

    // Main Customer Bottom Navigation Routes
    GoRoute(
      path: '/home',
      builder: (context, state) => const CustomerHomeScreen(),
    ),
    GoRoute(
      path: '/services',
      builder: (context, state) => const ServicesScreen(),
    ),
    GoRoute(
      path: '/service-details',
      builder: (context, state) {
        final service = state.extra as ServiceItem?;
        return ServiceDetailsScreen(service: service);
      },
    ),
    GoRoute(
      path: '/create-request',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return CreateRequestScreen(
          initialServiceId: extra?['serviceId'] as String?,
          initialServiceName: extra?['serviceName'] as String?,
        );
      },
    ),
    GoRoute(
      path: '/request-success',
      builder: (context, state) {
        final requestId = state.extra as String? ?? 'REQ-2026-000123';
        return RequestSuccessScreen(requestId: requestId);
      },
    ),
    GoRoute(
      path: '/requests',
      builder: (context, state) => const MyRequestsScreen(),
    ),
    GoRoute(
      path: '/request-details',
      builder: (context, state) {
        final request = state.extra as ServiceRequest;
        return RequestDetailsScreen(request: request);
      },
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/edit-profile',
      builder: (context, state) => const EditProfileScreen(),
    ),

    // Service Agent / Technician Routes
    GoRoute(
      path: '/agent-dashboard',
      builder: (context, state) => const AgentDashboardScreen(),
    ),
    GoRoute(
      path: '/agent-request-details',
      builder: (context, state) {
        final request = state.extra as ServiceRequest;
        return AgentRequestDetailsScreen(request: request);
      },
    ),
  ],
);
