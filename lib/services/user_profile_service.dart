import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile_model.dart';

class UserProfileService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  DocumentReference<Map<String, dynamic>> _profileDoc(String uid) =>
      _db.collection('users').doc(uid);

  /// Stream the user's profile, auto-creating if it doesn't exist
  Stream<UserProfile?> streamProfile(String uid) =>
      _profileDoc(uid).snapshots().map((snap) {
        if (!snap.exists) return null;
        return UserProfile.fromFirestore(snap);
      });

  /// Get profile once
  Future<UserProfile?> getProfile(String uid) async {
    final snap = await _profileDoc(uid).get();
    if (!snap.exists) return null;
    return UserProfile.fromFirestore(snap);
  }

  /// Ensure a Firestore profile document exists for the current user.
  /// Called after login/signup. Merges auth info without overwriting existing data.
  Future<UserProfile> ensureProfile() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final docRef = _profileDoc(user.uid);
    final snap = await docRef.get();

    if (snap.exists) {
      // Update email/displayName from Auth in case they changed
      await docRef.update({
        'displayName': user.displayName ?? snap.data()?['displayName'] ?? 'User',
        'email': user.email ?? snap.data()?['email'] ?? '',
        'photoUrl': user.photoURL,
        'lastActiveDate': Timestamp.now(),
      });
      final updated = await docRef.get();
      return UserProfile.fromFirestore(updated);
    } else {
      // First time — create new profile
      final profile = UserProfile.fromAuthUser(
        uid: user.uid,
        displayName: user.displayName ?? 'User',
        email: user.email ?? '',
        photoUrl: user.photoURL,
      );
      await docRef.set(profile.toMap());
      return profile;
    }
  }

  /// Update specific profile fields
  Future<void> updateProfile(String uid, Map<String, dynamic> fields) =>
      _profileDoc(uid).update(fields);

  /// Update display name in both Firebase Auth and Firestore
  Future<void> updateDisplayName(String uid, String newName) async {
    await _auth.currentUser?.updateDisplayName(newName);
    await _profileDoc(uid).update({'displayName': newName});
  }

  /// Record a completed focus session (adds minutes to total)
  Future<void> recordFocusSession(String uid, int minutes) async {
    await _profileDoc(uid).update({
      'totalFocusMinutes': FieldValue.increment(minutes),
      'lastActiveDate': Timestamp.now(),
    });
  }

  /// Update daily streak — call when user completes a task
  Future<void> updateStreak(String uid) async {
    final snap = await _profileDoc(uid).get();
    if (!snap.exists) return;

    final data = snap.data()!;
    final lastActive = (data['lastActiveDate'] as Timestamp?)?.toDate();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    int currentStreak = data['currentStreak'] as int? ?? 0;
    int longestStreak = data['longestStreak'] as int? ?? 0;

    if (lastActive != null) {
      final lastDay = DateTime(lastActive.year, lastActive.month, lastActive.day);
      final diff = today.difference(lastDay).inDays;

      if (diff == 0) {
        // Already active today, no change
        return;
      } else if (diff == 1) {
        // Consecutive day
        currentStreak += 1;
      } else {
        // Streak broken
        currentStreak = 1;
      }
    } else {
      currentStreak = 1;
    }

    if (currentStreak > longestStreak) {
      longestStreak = currentStreak;
    }

    await _profileDoc(uid).update({
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastActiveDate': Timestamp.now(),
    });
  }

  /// Compute a "productivity score" from tasks data
  /// This is purely a convenience — the raw data comes from tasks collection
  Future<int> computeProductivityScore(String uid) async {
    final tasksSnap = await _db
        .collection('users')
        .doc(uid)
        .collection('tasks')
        .get();

    if (tasksSnap.docs.isEmpty) return 0;

    int completedCount = 0;
    int totalCount = tasksSnap.docs.length;
    int highPriorityDone = 0;
    int onTimeDone = 0;

    for (final doc in tasksSnap.docs) {
      final data = doc.data();
      final status = data['status'] as String? ?? 'pending';
      final priority = data['priority'] as String? ?? 'medium';
      final dueDate = (data['dueDate'] as Timestamp?)?.toDate();
      final createdAt = (data['createdAt'] as Timestamp?)?.toDate();

      if (status == 'completed') {
        completedCount++;
        if (priority == 'high' || priority == 'urgent') {
          highPriorityDone++;
        }
        if (dueDate != null && createdAt != null && createdAt.isBefore(dueDate)) {
          onTimeDone++;
        }
      }
    }

    // Score formula: completion rate + bonuses for priority and timeliness
    if (totalCount == 0) return 0;
    double score = (completedCount / totalCount) * 500;
    score += highPriorityDone * 25;
    score += onTimeDone * 15;

    return score.clamp(0, 9999).round();
  }
}
