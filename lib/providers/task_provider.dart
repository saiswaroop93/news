import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Assuming firebaseAuthProvider and firebaseFirestoreProvider are globally accessible
// (e.g., defined in auth_provider.dart and imported here, or defined here if not).
// For this subtask, we'll re-define them here to ensure they are available.
// In a real app, you'd typically define these once.
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);
final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

class Task {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final Timestamp createdAt;
  final Timestamp? dueDate;
  final bool isCompleted;

  Task({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.createdAt,
    this.dueDate,
    this.isCompleted = false,
  });

  factory Task.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot, SnapshotOptions? options) {
    final data = snapshot.data();
    return Task(
      id: snapshot.id,
      userId: data?['userId'] ?? '',
      title: data?['title'] ?? '',
      description: data?['description'],
      createdAt: data?['createdAt'] ?? Timestamp.now(), // Default to now if missing
      dueDate: data?['dueDate'],
      isCompleted: data?['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      if (description != null) 'description': description,
      'createdAt': createdAt, // Should be FieldValue.serverTimestamp() on creation
      if (dueDate != null) 'dueDate': dueDate,
      'isCompleted': isCompleted,
    };
  }
}

final taskNotifierProvider = AsyncNotifierProvider<TaskNotifier, List<Task>>(() {
  return TaskNotifier();
});

class TaskNotifier extends AsyncNotifier<List<Task>> {
  late FirebaseFirestore _firestore;
  late FirebaseAuth _auth;

  @override
  Future<List<Task>> build() async {
    _firestore = ref.watch(firebaseFirestoreProvider);
    _auth = ref.watch(firebaseAuthProvider);

    final User? user = _auth.currentUser;
    if (user == null) {
      return []; // Not logged in, no tasks
    }

    // Stream for real-time updates
    final stream = _firestore
        .collection('tasks')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .withConverter<Task>(
          fromFirestore: Task.fromFirestore,
          toFirestore: (Task task, _) => task.toFirestore(),
        )
        .snapshots();

    // Listen to the stream and update state
    // Cancel the subscription when the provider is disposed
    final streamSubscription = stream.listen(
      (snapshot) {
        state = AsyncData(snapshot.docs.map((doc) => doc.data()).toList());
      },
      onError: (error, stackTrace) {
        state = AsyncError(error, stackTrace);
      },
    );

    ref.onDispose(() {
      streamSubscription.cancel();
    });

    // Perform an initial fetch for the Future required by build()
    try {
        final initialSnapshot = await _firestore
            .collection('tasks')
            .where('userId', isEqualTo: user.uid)
            .orderBy('createdAt', descending: true)
            .withConverter<Task>(
                fromFirestore: Task.fromFirestore,
                toFirestore: (Task task, _) => task.toFirestore(),
            )
            .get();
        return initialSnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e, s) {
        // If initial fetch fails, the stream listener might still recover,
        // but build needs to return a future or throw.
        // The error will be caught by Riverpod and state will be AsyncError.
        return Future.error(e,s);
    }
  }

  // CRUD methods will be added later
  Future<void> addTask(String title, {String? description, DateTime? dueDate}) async {
    final User? user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in. Cannot add task.');
    }

    try {
      final newTaskData = {
        'userId': user.uid,
        'title': title,
        if (description != null && description.isNotEmpty) 'description': description,
        'createdAt': FieldValue.serverTimestamp(), // Use server timestamp
        if (dueDate != null) 'dueDate': Timestamp.fromDate(dueDate),
        'isCompleted': false,
      };

      await _firestore.collection('tasks').add(newTaskData);
      // No explicit state update here, as the stream listener in `build()`
      // will pick up the new task and update the state (AsyncData).
    } catch (e, s) {
      // If we had an AsyncLoading state, we'd need to set AsyncError here.
      // For now, we can just rethrow or log.
      // Consider how errors from addTask should be exposed to the UI.
      // One option is for this method to return Future<void> and throw on error,
      // and the UI calls it in a try-catch or uses .catchError().
      print('Error adding task: $e'); // Simple logging
      throw Exception('Failed to add task: $e'); // Rethrow to be caught by UI if needed
    }
  }

  Future<void> updateTask(String taskId, Map<String, dynamic> dataToUpdate) async {
    final User? user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in. Cannot update task.');
    }
    try {
      await _firestore.collection('tasks').doc(taskId).update(dataToUpdate);
    } catch (e) {
      print('Error updating task $taskId: $e');
      throw Exception('Failed to update task: $e');
    }
  }

  Future<void> toggleTaskCompleted(String taskId, bool currentStatus) async {
    final User? user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in. Cannot toggle task status.');
    }
    try {
      await _firestore.collection('tasks').doc(taskId).update({'isCompleted': !currentStatus});
    } catch (e) {
      print('Error toggling task $taskId status: $e');
      throw Exception('Failed to toggle task status: $e');
    }
  }

  Future<void> deleteTask(String taskId) async {
    final User? user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in. Cannot delete task.');
    }
    try {
      await _firestore.collection('tasks').doc(taskId).delete();
    } catch (e) {
      print('Error deleting task $taskId: $e');
      throw Exception('Failed to delete task: $e');
    }
  }
}
