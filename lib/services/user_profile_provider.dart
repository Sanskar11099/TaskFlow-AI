import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile_model.dart';
import 'user_profile_service.dart';

final userProfileServiceProvider =
    Provider<UserProfileService>((ref) => UserProfileService());

/// Streams the current user's profile from Firestore
final userProfileProvider = StreamProvider<UserProfile?>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return Stream.value(null);
  return ref.watch(userProfileServiceProvider).streamProfile(uid);
});

/// One-shot provider for the productivity score
final productivityScoreProvider = FutureProvider<int>((ref) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return 0;
  return ref.watch(userProfileServiceProvider).computeProductivityScore(uid);
});
