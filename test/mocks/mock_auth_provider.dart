import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Required for User type
import 'package:news/providers/auth_provider.dart'; // Import real AuthProvider to implement/extend

// Manual mock for AuthProvider
class MockAuthProvider extends ChangeNotifier implements AuthProvider {
  // Mock properties
  User? _mockUser;
  String? _mockErrorMessage;
  bool _mockIsLoading = false;
  bool _signInCalled = false;
  String? _lastSignInEmail;
  String? _lastSignInPassword;
  bool _signUpCalled = false;
  bool _signOutCalled = false;

  // --- Mock implementations of AuthProvider members ---

  @override
  User? get user => _mockUser;

  @override
  String? get errorMessage => _mockErrorMessage;

  @override
  bool get isLoading => _mockIsLoading;

  // Mock signIn method
  @override
  Future<void> signIn(String email, String password) async {
    _signInCalled = true;
    _lastSignInEmail = email;
    _lastSignInPassword = password;
    _mockIsLoading = true;
    notifyListeners(); // Notify loading start

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 100));

    // Simulate success or failure based on test setup (can be configured externally)
    if (_mockErrorMessage == null) {
      // Simulate successful login
      _mockUser = MockUser(); // Use a simple mock User object
    } else {
      // Simulate failed login (error message should be set before calling)
      _mockUser = null;
    }

    _mockIsLoading = false;
    notifyListeners(); // Notify loading end and potential user/error change
  }

  // Mock signUp method (implement if needed for signup screen tests, basic stub here)
  @override
  Future<void> signUp(String email, String password, String name) async {
    _signUpCalled = true;
    _mockIsLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 100));
    // Simulate success or failure
    if (_mockErrorMessage == null) {
      _mockUser = MockUser();
    } else {
       _mockUser = null;
    }
    _mockIsLoading = false;
    notifyListeners();
  }

  // Mock signOut method
  @override
  Future<void> signOut() async {
     _signOutCalled = true;
    _mockUser = null;
    notifyListeners();
  }

  // --- Mock control methods ---

  void setMockUser(User? user) {
    _mockUser = user;
    notifyListeners();
  }

  void setMockErrorMessage(String? message) {
    _mockErrorMessage = message;
    // Don't notify here, error is usually set before action
  }

  void setMockLoading(bool loading) {
    _mockIsLoading = loading;
    notifyListeners();
  }

  void reset() {
    _mockUser = null;
    _mockErrorMessage = null;
    _mockIsLoading = false;
    _signInCalled = false;
    _lastSignInEmail = null;
    _lastSignInPassword = null;
    _signUpCalled = false;
    _signOutCalled = false;
    // Don't notify here, typically called in setUp/tearDown
  }

  // --- Getters for test verification ---
  bool get signInCalled => _signInCalled;
  String? get lastSignInEmail => _lastSignInEmail;
  String? get lastSignInPassword => _lastSignInPassword;
  bool get signUpCalled => _signUpCalled;
  bool get signOutCalled => _signOutCalled;


  // --- Unimplemented methods (required by implements AuthProvider) ---
  // We only mock what's necessary for LoginScreen tests.
  // Add stubs for other methods if they were part of the interface.
  // Since AuthProvider itself is a class, we don't strictly need to implement
  // everything unless we were implementing an abstract class. However,
  // to fully satisfy the 'implements AuthProvider' contract, we might add stubs.
  // For this test, we only need the methods used by LoginScreen.

  // Stubbing internal Firebase instances (not used directly in mock logic)
  @override
  dynamic noSuchMethod(Invocation invocation) {
     // This handles calls to methods/getters not explicitly overridden
     // For example, calls to the internal _auth or _firestore instances.
     // You might want to log these or return default values if needed.
     print('Warning: MockAuthProvider received unexpected call: ${invocation.memberName}');
     return super.noSuchMethod(invocation);
   }
}

// Minimal mock User class for testing purposes
class MockUser implements User {
  @override
  String get uid => 'mock_user_id';

  @override
  String? get email => 'mock@example.com';

  // Add other User properties/methods if needed by the UI, otherwise stub them
  @override
  bool get emailVerified => true;
  @override
  bool get isAnonymous => false;
  @override
  UserMetadata get metadata => MockUserMetadata();
  @override
  List<UserInfo> get providerData => [];
  @override
  String? get phoneNumber => null;
  @override
  String? get photoURL => null;
  @override
  String? get displayName => 'Mock User';
  @override
  Future<void> delete() async {}
  @override
  Future<String> getIdToken([bool forceRefresh = false]) async => 'mock_token';
  @override
  Future<IdTokenResult> getIdTokenResult([bool forceRefresh = false]) async => MockIdTokenResult();
  @override
  Future<UserCredential> linkWithCredential(AuthCredential credential) async => throw UnimplementedError();
  @override
  Future<UserCredential> linkWithPopup(AuthProvider provider) async => throw UnimplementedError();
  @override
  Future<ConfirmationResult> linkWithPhoneNumber(String phoneNumber, [RecaptchaVerifier? verifier]) async => throw UnimplementedError();
  @override
  Future<User> reload() async => this;
  @override
  Future<void> sendEmailVerification([ActionCodeSettings? actionCodeSettings]) async {}
  @override
  Future<User> unlink(String providerId) async => this;
  @override
  Future<void> updateEmail(String newEmail) async {}
  @override
  Future<void> updatePassword(String newPassword) async {}
  @override
  Future<void> updatePhoneNumber(PhoneAuthCredential credential) async {}
  @override
  Future<void> updatePhotoURL(String? photoURL) async {}
  @override
  Future<void> updateDisplayName(String? displayName) async {}
  @override
  Future<void> verifyBeforeUpdateEmail(String newEmail, [ActionCodeSettings? actionCodeSettings]) async {}
  @override
  String get tenantId => throw UnimplementedError();
  @override
  MultiFactor get multiFactor => throw UnimplementedError();
  @override
  Future<void> reauthenticateWithCredential(AuthCredential credential) async {}
  @override
  Future<UserCredential> reauthenticateWithPopup(AuthProvider provider) async => throw UnimplementedError();
  @override
  Future<ConfirmationResult> reauthenticateWithPhoneNumber(String phoneNumber, [RecaptchaVerifier? verifier]) async => throw UnimplementedError();
  @override
  Map<String, dynamic> toJson() => {};
}

// Minimal mock UserMetadata
class MockUserMetadata implements UserMetadata {
  @override
  DateTime? get creationTime => DateTime.now().subtract(Duration(days: 1));
  @override
  DateTime? get lastSignInTime => DateTime.now();
}

// Minimal mock IdTokenResult
class MockIdTokenResult implements IdTokenResult {
   @override
   Map<String, dynamic>? get claims => {};
   @override
   DateTime? get expirationTime => DateTime.now().add(Duration(hours: 1));
   @override
   DateTime? get issuedAtTime => DateTime.now();
   @override
   String? get signInProvider => 'password';
   @override
   String? get token => 'mock_token';
   @override
   DateTime? get authTime => DateTime.now();
   @override
   String? get signInSecondFactor => null;
 }
