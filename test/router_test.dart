import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Needed for FirebaseAuth Exception types if mocking errors
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

// --- Mock Screens ---

class MockLoginScreen extends StatelessWidget {
  const MockLoginScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              key: const ValueKey('login_to_signup_button'),
              onPressed: () => context.go('/signup'),
              child: const Text('Go to Signup'),
            ),
             ElevatedButton(
              key: const ValueKey('login_to_news_button'), // For testing post-login nav
              onPressed: () => context.go('/news'),
              child: const Text('Go to News'),
            ),
          ],
        ),
      ),
    );
  }
}

class MockSignupScreen extends StatelessWidget {
  const MockSignupScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Signup')),
      body: Center(
        child: ElevatedButton(
          key: const ValueKey('signup_to_login_button'),
          onPressed: () => context.go('/login'),
          child: const Text('Go to Login'),
        ),
      ),
    );
  }
}

class MockNewsScreen extends StatelessWidget {
  const MockNewsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('News')),
      body: const Center(child: Text('News Content')),
    );
  }
}

// --- Test Router Creator ---

// Helper function to create a GoRouter instance configured for testing
GoRouter createTestRouter(MockFirebaseAuth mockAuth, {String initialLocation = '/news'}) {
  // Create a mock user for logged-in scenarios if needed
  // final mockUser = MockUser(uid: 'test-uid', email: 'test@example.com');

  return GoRouter(
    initialLocation: initialLocation, // Allow overriding initial location for deep link tests
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const MockLoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const MockSignupScreen(),
      ),
      GoRoute(
        path: '/news',
        builder: (context, state) => const MockNewsScreen(),
      ),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      // Use the injected mockAuth instance
      final user = mockAuth.currentUser;
      final bool loggedIn = user != null;
      final bool loggingIn = state.matchedLocation == '/login';
      final bool signingUp = state.matchedLocation == '/signup';
      final bool isPublicRoute = loggingIn || signingUp;

      // Debug print statements (optional)
      // print('Redirect check: loggedIn=$loggedIn, location=${state.matchedLocation}, isPublic=$isPublicRoute');

      if (!loggedIn && !isPublicRoute) {
        // print('Redirecting to /login');
        return '/login';
      }
      if (loggedIn && isPublicRoute) {
        // print('Redirecting to /news');
        return '/news';
      }
      // print('No redirect needed');
      return null;
    },
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(child: Text('Error: ${state.error}')),
    ),
    // Enable navigator observers if needed for more complex state checking
    // observers: [],
  );
}


// --- Test Main Function ---
void main() {
  late MockFirebaseAuth mockAuth;
  late GoRouter router;

  // Helper function to pump the widget tree with the test router
  Future<void> pumpApp(WidgetTester tester, GoRouter testRouter) async {
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: testRouter,
      ),
    );
    await tester.pumpAndSettle(); // Let the router settle
  }

  setUp(() {
    // Default to logged-out state for most tests
    mockAuth = MockFirebaseAuth(signedIn: false);
    router = createTestRouter(mockAuth);
  });

  testWidgets('Initial route redirects to /login when logged out', (WidgetTester tester) async {
    // Arrange: Router is already created with mockAuth (logged out)
    await pumpApp(tester, router);

    // Assert
    expect(find.byType(MockLoginScreen), findsOneWidget);
    expect(find.byType(MockNewsScreen), findsNothing);
    expect(router.location, '/login'); // Check router's final location
  });

  testWidgets('Initial route stays at /news when logged in', (WidgetTester tester) async {
    // Arrange: Log in the mock user
    mockAuth = MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'test-uid'));
    router = createTestRouter(mockAuth); // Recreate router with logged-in state

    await pumpApp(tester, router);

    // Assert
    expect(find.byType(MockNewsScreen), findsOneWidget);
    expect(find.byType(MockLoginScreen), findsNothing);
    expect(router.location, '/news');
  });

   testWidgets('Redirects to /news if logged in user tries to access /login', (WidgetTester tester) async {
    // Arrange: Log in the mock user
    mockAuth = MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'test-uid'));
    // Start at /login intentionally
    router = createTestRouter(mockAuth, initialLocation: '/login');

    await pumpApp(tester, router);

    // Assert: Should be redirected to /news
    expect(find.byType(MockNewsScreen), findsOneWidget);
    expect(find.byType(MockLoginScreen), findsNothing);
     expect(router.location, '/news');
  });

  testWidgets('Redirects to /news if logged in user tries to access /signup', (WidgetTester tester) async {
    // Arrange: Log in the mock user
    mockAuth = MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'test-uid'));
    // Start at /signup intentionally
    router = createTestRouter(mockAuth, initialLocation: '/signup');

    await pumpApp(tester, router);

    // Assert: Should be redirected to /news
    expect(find.byType(MockNewsScreen), findsOneWidget);
    expect(find.byType(MockSignupScreen), findsNothing);
     expect(router.location, '/news');
  });


  testWidgets('Navigation from Login to Signup works', (WidgetTester tester) async {
    // Arrange: Start logged out (default setup), pump app to show Login screen
    await pumpApp(tester, router);
    expect(find.byType(MockLoginScreen), findsOneWidget); // Pre-condition

    // Act: Tap the button to go to Signup
    await tester.tap(find.byKey(const ValueKey('login_to_signup_button')));
    await tester.pumpAndSettle(); // Allow navigation to complete

    // Assert
    expect(find.byType(MockSignupScreen), findsOneWidget);
    expect(find.byType(MockLoginScreen), findsNothing);
     expect(router.location, '/signup');
  });

  testWidgets('Navigation from Signup to Login works', (WidgetTester tester) async {
    // Arrange: Start logged out, navigate to Signup first
     router = createTestRouter(mockAuth, initialLocation: '/signup'); // Start at signup
    await pumpApp(tester, router);
    expect(find.byType(MockSignupScreen), findsOneWidget); // Pre-condition

    // Act: Tap the button to go to Login
    await tester.tap(find.byKey(const ValueKey('signup_to_login_button')));
    await tester.pumpAndSettle(); // Allow navigation to complete

    // Assert
    expect(find.byType(MockLoginScreen), findsOneWidget);
    expect(find.byType(MockSignupScreen), findsNothing);
     expect(router.location, '/login');
  });

   testWidgets('Navigation from Login to News works (after mock login)', (WidgetTester tester) async {
    // Arrange: Start logged out on Login screen
    await pumpApp(tester, router);
    expect(find.byType(MockLoginScreen), findsOneWidget);

    // Act:
    // 1. Simulate logging in (by changing the mock) - Note: In a real app, this would trigger a state change
    mockAuth.signInWithEmailAndPassword(email: 'test@test.com', password: 'pw'); // This updates mockAuth.currentUser
    // 2. Tap button that uses context.go('/news')
    await tester.tap(find.byKey(const ValueKey('login_to_news_button')));
    await tester.pumpAndSettle();

    // Assert: Should be on News screen because redirect logic allows it now
    expect(find.byType(MockNewsScreen), findsOneWidget);
    expect(find.byType(MockLoginScreen), findsNothing);
    expect(router.location, '/news');
  });


  // --- Deep Link Tests ---
  // Note: Testing actual platform deep linking is complex. These tests verify
  // that the router *would* navigate correctly if the platform provided the URL.

  testWidgets('Deep link newsapp://news navigates to NewsScreen when logged in', (WidgetTester tester) async {
    // Arrange: Log in user
     mockAuth = MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'test-uid'));
     // Create router *without* initialLocation, let GoRouter handle the deep link path
     router = createTestRouter(mockAuth);

     // Act: Simulate deep link by navigating the router directly
     // We wrap the pump in runAsync to handle potential async operations within go()
     await tester.runAsync(() async {
        router.go('/news'); // Simulate the path extracted from 'newsapp://news'
        await pumpApp(tester, router); // Pump the app *after* go()
     });


    // Assert
    expect(find.byType(MockNewsScreen), findsOneWidget);
    expect(router.location, '/news');
  });

   testWidgets('Deep link newsapp://login navigates to LoginScreen when logged out', (WidgetTester tester) async {
    // Arrange: User is logged out (default)
     router = createTestRouter(mockAuth);

     // Act: Simulate deep link
     await tester.runAsync(() async {
        router.go('/login'); // Simulate path from 'newsapp://login'
        await pumpApp(tester, router);
     });

    // Assert
    expect(find.byType(MockLoginScreen), findsOneWidget);
    expect(router.location, '/login');
  });

   testWidgets('Deep link https://news.example.com/news navigates to NewsScreen when logged in', (WidgetTester tester) async {
    // Arrange: Log in user
     mockAuth = MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'test-uid'));
     router = createTestRouter(mockAuth);

     // Act: Simulate deep link path
      await tester.runAsync(() async {
        router.go('/news'); // Simulate path from 'https://news.example.com/news'
        await pumpApp(tester, router);
      });

    // Assert
    expect(find.byType(MockNewsScreen), findsOneWidget);
     expect(router.location, '/news');
  });

   testWidgets('Deep link https://news.example.com/login navigates to LoginScreen when logged out', (WidgetTester tester) async {
    // Arrange: User is logged out (default)
     router = createTestRouter(mockAuth);

     // Act: Simulate deep link path
      await tester.runAsync(() async {
        router.go('/login'); // Simulate path from 'https://news.example.com/login'
        await pumpApp(tester, router);
      });

    // Assert
    expect(find.byType(MockLoginScreen), findsOneWidget);
     expect(router.location, '/login');
  });

  // Add more tests as needed, e.g., for error handling, query parameters, path parameters
}
