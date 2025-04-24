import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:news/appcolors.dart';
import 'package:news/providers/auth_provider.dart';
import 'package:news/screens/login_screen.dart';
import 'package:news/screens/news_screen.dart';
import 'package:news/screens/signup_screen.dart';
import 'package:provider/provider.dart';

import 'mocks/mock_auth_provider.dart'; // Import the manual mock

void main() {
  // Use late to initialize in setUp
  late MockAuthProvider mockAuthProvider;

  // Helper function to build the widget tree for testing
  Future<void> pumpLoginScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
        ],
        child: ScreenUtilInit(
          designSize: const Size(375, 812), // Standard design size for ScreenUtil
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (_, child) {
            return MaterialApp(
              // Define routes for navigation testing
              routes: {
                '/': (context) => LoginScreen(),
                '/news': (context) => NewsScreen(), // Placeholder NewsScreen
                '/signup': (context) => SignupScreen(), // Placeholder SignupScreen
              },
              home: LoginScreen(),
              theme: ThemeData(
                 // Define colors used in LoginScreen if necessary for theme lookups
                 primaryColor: AppColors.blue,
                 hintColor: AppColors.black,
                 scaffoldBackgroundColor: AppColors.whiteshade,
                 // Add other theme properties if LoginScreen relies on them
              ),
            );
          },
        ),
      ),
    );
    // Pump and settle to allow animations/futures (like initial build) to complete
    await tester.pumpAndSettle();
  }

  setUp(() {
    mockAuthProvider = MockAuthProvider();
    // Reset the mock before each test to ensure isolation
    mockAuthProvider.reset();
  });

  group('LoginScreen Widget Tests', () {
    testWidgets('Renders Email and Password fields, Login button, and Signup link', (WidgetTester tester) async {
      await pumpLoginScreen(tester);

      // Verify Email field
      expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);

      // Verify Password field
      expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);

      // Verify Login button (using the text inside it)
      // Need to find the Text widget itself as the button is an InkWell wrapping a Container
      expect(find.text('Login'), findsOneWidget);
      // More specific check: Find the container and check its child
      final loginButtonContainerFinder = find.byWidgetPredicate((widget) =>
          widget is Container &&
          (widget.decoration as BoxDecoration?)?.color == AppColors.blue &&
          widget.child is Center &&
          (widget.child as Center).child is Text &&
          ((widget.child as Center).child as Text).data == 'Login');
      expect(loginButtonContainerFinder, findsOneWidget);


      // Verify Signup link text
      expect(find.textContaining('New here?'), findsOneWidget);
      expect(find.text('Signup'), findsOneWidget);
      // Verify RichText structure
       expect(find.byWidgetPredicate((widget) =>
            widget is RichText &&
            widget.text.toPlainText() == 'New here? Signup'), findsOneWidget);
    });

    testWidgets('Password field is initially obscured', (WidgetTester tester) async {
      await pumpLoginScreen(tester);

      final passwordField = tester.widget<TextFormField>(find.widgetWithText(TextFormField, 'Password'));
      expect(passwordField.obscureText, isTrue);
      // Also check for the visibility_off icon
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
      expect(find.byIcon(Icons.visibility), findsNothing);
    });

    testWidgets('Password visibility toggle works', (WidgetTester tester) async {
      await pumpLoginScreen(tester);

      // Initial state check
      expect(tester.widget<TextFormField>(find.widgetWithText(TextFormField, 'Password')).obscureText, isTrue);
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);

      // Tap the visibility toggle icon
      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pumpAndSettle(); // Rebuilds due to StatefulBuilder

      // Verify state after tap
      expect(tester.widget<TextFormField>(find.widgetWithText(TextFormField, 'Password')).obscureText, isFalse);
      expect(find.byIcon(Icons.visibility), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off), findsNothing);

       // Tap again to hide
      await tester.tap(find.byIcon(Icons.visibility));
      await tester.pumpAndSettle();

       // Verify state after second tap
      expect(tester.widget<TextFormField>(find.widgetWithText(TextFormField, 'Password')).obscureText, isTrue);
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
      expect(find.byIcon(Icons.visibility), findsNothing);
    });

    testWidgets('Shows validation error for empty email and password', (WidgetTester tester) async {
      await pumpLoginScreen(tester);

      // Tap Login button without entering anything
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle(); // Allow validation messages to appear

      // Verify error messages
      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);

      // Verify signIn was NOT called
      expect(mockAuthProvider.signInCalled, isFalse);
    });

     testWidgets('Shows validation error for invalid email format', (WidgetTester tester) async {
      await pumpLoginScreen(tester);

      // Enter invalid email and valid password
      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'invalid-email');
      await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'password123');
      await tester.pump();

      // Tap Login button
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      // Verify email error message
      expect(find.text('Please enter a valid email address'), findsOneWidget);
      // Verify no password error
      expect(find.text('Please enter your password'), findsNothing);
      expect(find.text('Password must be at least 6 characters'), findsNothing);

      // Verify signIn was NOT called
      expect(mockAuthProvider.signInCalled, isFalse);
    });

    testWidgets('Shows validation error for short password', (WidgetTester tester) async {
      await pumpLoginScreen(tester);

       // Enter valid email and short password
      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'test@example.com');
      await tester.enterText(find.widgetWithText(TextFormField, 'Password'), '12345'); // 5 chars
      await tester.pump();

      // Tap Login button
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      // Verify password error message
      expect(find.text('Password must be at least 6 characters'), findsOneWidget);
      // Verify no email error
       expect(find.text('Please enter your email'), findsNothing);
       expect(find.text('Please enter a valid email address'), findsNothing);

       // Verify signIn was NOT called
      expect(mockAuthProvider.signInCalled, isFalse);
    });

    testWidgets('Calls AuthProvider.signIn with correct credentials on valid submission', (WidgetTester tester) async {
      await pumpLoginScreen(tester);

      const email = 'test@example.com';
      const password = 'password123';

      // Enter valid credentials
      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), email);
      await tester.enterText(find.widgetWithText(TextFormField, 'Password'), password);
      await tester.pump();

      // Tap Login button
      await tester.tap(find.text('Login'));
      // Don't pumpAndSettle immediately, let signIn start
      await tester.pump();

      // Verify signIn was called with correct credentials
      expect(mockAuthProvider.signInCalled, isTrue);
      expect(mockAuthProvider.lastSignInEmail, email);
      expect(mockAuthProvider.lastSignInPassword, password);

      // Let the mock finish (simulated delay + state update)
      await tester.pumpAndSettle();
    });

     testWidgets('Shows loading indicator during sign in', (WidgetTester tester) async {
      await pumpLoginScreen(tester);

      const email = 'test@example.com';
      const password = 'password123';

      // Enter valid credentials
      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), email);
      await tester.enterText(find.widgetWithText(TextFormField, 'Password'), password);
      await tester.pump();

      // Tap Login button - DO NOT pumpAndSettle yet
      await tester.tap(find.text('Login'));
      await tester.pump(); // Start the process

      // Verify loading state in provider (mock simulates this)
      expect(mockAuthProvider.isLoading, isTrue);

      // Verify UI changes during loading
      // Login button should be replaced by indicator *inside* the container now
      expect(find.text('Login'), findsNothing); // Text is gone
      expect(find.byType(CircularProgressIndicator), findsOneWidget); // Indicator is present

      // Check if button container is greyed out (more robust check)
      final loginButtonContainerFinder = find.byWidgetPredicate((widget) =>
          widget is Container &&
          (widget.decoration as BoxDecoration?)?.color == Colors.grey.shade400); // Check for grey color
      expect(loginButtonContainerFinder, findsOneWidget);


      // Let the sign in process complete
      await tester.pumpAndSettle();

       // Verify loading state is false after completion
      expect(mockAuthProvider.isLoading, isFalse);
       // Verify UI returns to normal (or navigates away if successful)
      // In this case, mock doesn't set a user, so it should return to normal button
      expect(find.text('Login'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      final loginButtonContainerFinderAfter = find.byWidgetPredicate((widget) =>
          widget is Container &&
          (widget.decoration as BoxDecoration?)?.color == AppColors.blue); // Back to blue
      expect(loginButtonContainerFinderAfter, findsOneWidget);

    });

    testWidgets('Displays error message from AuthProvider on failed login', (WidgetTester tester) async {
      // Setup mock to simulate login failure
      const errorMessage = 'Invalid credentials';
      mockAuthProvider.setMockErrorMessage(errorMessage);

      await pumpLoginScreen(tester);

      // Enter valid credentials (format-wise)
      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'test@example.com');
      await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'password123');
      await tester.pump();

      // Tap Login button
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle(); // Let the mock signIn complete

      // Verify error message is displayed
      expect(find.text(errorMessage), findsOneWidget);
       // Verify user is not set in provider
      expect(mockAuthProvider.user, isNull);
    });

    // --- Navigation Tests ---
    // Note: These require placeholder screens and routes setup in pumpLoginScreen

     testWidgets('Navigates to NewsScreen on successful login', (WidgetTester tester) async {
      // Setup mock for successful login
      mockAuthProvider.setMockUser(MockUser()); // Simulate a logged-in user *after* signIn
       // Reset error message in case it was set in a previous test's setup
       mockAuthProvider.setMockErrorMessage(null);


      await pumpLoginScreen(tester);

      // Enter valid credentials
      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'test@example.com');
      await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'password123');
      await tester.pump();

      // Tap Login button
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle(); // Allow mock signIn and navigation to complete

      // Verify navigation occurred (NewsScreen should be present)
      // Note: This assumes NewsScreen has a unique widget, like its AppBar title or Scaffold key
      expect(find.byType(LoginScreen), findsNothing); // Old screen is gone
      expect(find.byType(NewsScreen), findsOneWidget); // New screen is present

      // Optional: Verify specific content on NewsScreen if needed
      // expect(find.text('News Feed'), findsOneWidget); // Example check
    });

     testWidgets('Navigates to SignupScreen when Signup button is tapped', (WidgetTester tester) async {
      await pumpLoginScreen(tester);

      // Find the 'Signup' text which is part of the RichText in a TextButton
      final signupTextFinder = find.text('Signup');
      expect(signupTextFinder, findsOneWidget);

      // Tap the 'Signup' text (or the TextButton containing it)
      // Tapping the specific text span might be tricky, target the button/RichText
       final richTextFinder = find.byWidgetPredicate((widget) =>
            widget is RichText &&
            widget.text.toPlainText() == 'New here? Signup');
       expect(richTextFinder, findsOneWidget);

       // Find the TextButton ancestor of the RichText
       final textButtonFinder = find.ancestor(of: richTextFinder, matching: find.byType(TextButton));
       expect(textButtonFinder, findsOneWidget);


      await tester.tap(textButtonFinder);
      await tester.pumpAndSettle(); // Allow navigation to complete

      // Verify navigation occurred
      expect(find.byType(LoginScreen), findsNothing);
      expect(find.byType(SignupScreen), findsOneWidget);

       // Optional: Verify specific content on SignupScreen if needed
      // expect(find.text('Create Account'), findsOneWidget); // Example check
    });

  });
}

// Helper Mock User class (already defined in mock_auth_provider.dart, ensure it's accessible or redefine simply here if needed)
// class MockUser implements User { ... } // If not importing
// Need placeholders for NewsScreen and SignupScreen for navigation tests to work
class NewsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text('Mock News Screen')));
}

class SignupScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text('Mock Signup Screen')));
}
