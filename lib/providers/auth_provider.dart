import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Define a provider for FirebaseAuth instance
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

// Define a provider for FirebaseFirestore instance
final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

// The State for our AuthNotifier could be User? or a more complex object
// For AsyncNotifier, the state is managed as AsyncValue<User?>

final authNotifierProvider = AsyncNotifierProvider<AuthNotifier, User?>(() {
  return AuthNotifier();
});

class AuthNotifier extends AsyncNotifier<User?> {
  late FirebaseAuth _auth;
  late FirebaseFirestore _firestore;

  @override
  Future<User?> build() async {
    _auth = ref.watch(firebaseAuthProvider);
    _firestore = ref.watch(firebaseFirestoreProvider);

    // Listen to auth state changes and update the state accordingly
    // This stream will automatically update the state when the user signs in or out
    final stream = _auth.authStateChanges();
    ref.onDispose(() => stream.listen(null).cancel()); // Clean up listener

    await for (final user in stream) {
      state = AsyncData(user); // Update state with the new user status
      if (user != null) return user; // Return current user if already logged in
    }
    return null; // Default to null if no user ever logs in during init
  }

  // Sign In method
  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      state = AsyncData(userCredential.user);
    } on FirebaseAuthException catch (e) {
      state = AsyncError(e.message ?? 'Sign in failed', StackTrace.current);
    } catch (e) {
      state = AsyncError(e.toString(), StackTrace.current);
    }
  }

  // Sign Up method with storing details in Firestore
  Future<void> signUp(String email, String password, String name) async {
    state = const AsyncLoading();
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;

      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'name': name,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      state = AsyncData(user);
    } on FirebaseAuthException catch (e) {
      state = AsyncError(e.message ?? 'Sign up failed', StackTrace.current);
    } catch (e) {
      state = AsyncError(e.toString(), StackTrace.current);
    }
  }

  // Sign Out method
  Future<void> signOut() async {
    state = const AsyncLoading();
    try {
      await _auth.signOut();
      state = const AsyncData(null); // User is now null
    } on FirebaseAuthException catch (e) {
      state = AsyncError(e.message ?? 'Sign out failed', StackTrace.current);
    } catch (e) {
      state = AsyncError(e.toString(), StackTrace.current);
    }
  }
}
