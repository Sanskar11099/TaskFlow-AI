import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String displayName;
  final String email;
  final String? photoUrl;
  final DateTime joinedAt;
  final int totalFocusMinutes;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastActiveDate;

  const UserProfile({
    required this.uid,
    required this.displayName,
    required this.email,
    this.photoUrl,
    required this.joinedAt,
    this.totalFocusMinutes = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastActiveDate,
  });

  UserProfile copyWith({
    String? displayName,
    String? email,
    String? photoUrl,
    int? totalFocusMinutes,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastActiveDate,
  }) =>
      UserProfile(
        uid: uid,
        displayName: displayName ?? this.displayName,
        email: email ?? this.email,
        photoUrl: photoUrl ?? this.photoUrl,
        joinedAt: joinedAt,
        totalFocusMinutes: totalFocusMinutes ?? this.totalFocusMinutes,
        currentStreak: currentStreak ?? this.currentStreak,
        longestStreak: longestStreak ?? this.longestStreak,
        lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      );

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'displayName': displayName,
        'email': email,
        'photoUrl': photoUrl,
        'joinedAt': Timestamp.fromDate(joinedAt),
        'totalFocusMinutes': totalFocusMinutes,
        'currentStreak': currentStreak,
        'longestStreak': longestStreak,
        'lastActiveDate':
            lastActiveDate != null ? Timestamp.fromDate(lastActiveDate!) : null,
      };

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      uid: doc.id,
      displayName: data['displayName'] as String? ?? 'User',
      email: data['email'] as String? ?? '',
      photoUrl: data['photoUrl'] as String?,
      joinedAt: (data['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      totalFocusMinutes: data['totalFocusMinutes'] as int? ?? 0,
      currentStreak: data['currentStreak'] as int? ?? 0,
      longestStreak: data['longestStreak'] as int? ?? 0,
      lastActiveDate: (data['lastActiveDate'] as Timestamp?)?.toDate(),
    );
  }

  /// Create a fresh profile from Firebase Auth user
  factory UserProfile.fromAuthUser({
    required String uid,
    required String displayName,
    required String email,
    String? photoUrl,
  }) =>
      UserProfile(
        uid: uid,
        displayName: displayName,
        email: email,
        photoUrl: photoUrl,
        joinedAt: DateTime.now(),
      );

  String get initials => displayName
      .split(' ')
      .map((w) => w.isNotEmpty ? w[0] : '')
      .take(2)
      .join()
      .toUpperCase();

  String get focusHoursFormatted {
    final hours = totalFocusMinutes ~/ 60;
    final mins = totalFocusMinutes % 60;
    if (hours == 0) return '${mins}m';
    return '${hours}.${(mins * 10 ~/ 60)}h';
  }
}
