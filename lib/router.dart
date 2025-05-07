import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth

// Import screen widgets
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/news_screen.dart';

// It might be better to get auth state via a Provider or service
// but for simplicity here, we check directly.

final GoRouter router = GoRouter(
  initialLocation: '/news', // Start at news, redirect logic will handle auth
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignupScreen(),
    ),
    GoRoute(
      path: '/news',
      builder: (context, state) => const NewsScreen(),
    ),
  ],
  redirect: (BuildContext context, GoRouterState state) {
    // Get the current user from FirebaseAuth
    final user = FirebaseAuth.instance.currentUser;
    final bool loggedIn = user != null;

    // Define public routes
    final bool loggingIn = state.matchedLocation == '/login';
    final bool signingUp = state.matchedLocation == '/signup';
    final bool isPublicRoute = loggingIn || signingUp;

    // If the user is not logged in and trying to access a protected route, redirect to login.
    if (!loggedIn && !isPublicRoute) {
      return '/login';
    }

    // If the user is logged in and trying to access login or signup, redirect to news.
    if (loggedIn && isPublicRoute) {
      return '/news';
    }

    // Otherwise, allow navigation.
    return null;
  },
  // Optional: Add error handling
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Page not found: ${state.error}'),
    ),
  ),
);
