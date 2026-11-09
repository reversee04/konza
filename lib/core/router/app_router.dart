import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/splash_screen.dart';
import '../../features/auth/onboarding_screen.dart';
import '../../features/auth/phone_auth_screen.dart';
import '../../features/auth/otp_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/booking/booking_screen.dart';
import '../../features/tracking/tracking_screen.dart';
import '../../features/recycling/recycling_screen.dart';
import '../../features/subscriptions/subscriptions_screen.dart';
import '../../features/payments/payments_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../shared/widgets/main_shell.dart';
import '../providers/providers.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final loggedIn = auth.isAuthenticated;
      final goingToAuth = state.matchedLocation.startsWith('/auth') ||
          state.matchedLocation == '/splash' ||
          state.matchedLocation == '/onboarding';

      if (!loggedIn && !goingToAuth) return '/splash';
      if (loggedIn && goingToAuth) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/auth/phone',
        builder: (_, __) => const PhoneAuthScreen(),
      ),
      GoRoute(
        path: '/auth/otp',
        builder: (context, state) {
          final phone = state.extra as String? ?? '';
          return OtpScreen(phone: phone);
        },
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
          GoRoute(path: '/book', builder: (_, __) => const BookingScreen()),
          GoRoute(path: '/tracking', builder: (_, __) => const TrackingScreen()),
          GoRoute(path: '/recycling', builder: (_, __) => const RecyclingScreen()),
          GoRoute(path: '/subscriptions', builder: (_, __) => const SubscriptionsScreen()),
          GoRoute(path: '/payments', builder: (_, __) => const PaymentsScreen()),
          GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
        ],
      ),
    ],
  );
});
