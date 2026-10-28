class UserModel {
  final String? uid;
  final String? email;
  final String? displayName;
  final String? photoURL;
  final int totalSessions;
  final int totalMinutes;
  final int currentStreak;
  final int bestStreak;
  final DateTime? lastSessionDate;
  final bool isFirebaseEnabled;

  UserModel({
    this.uid,
    this.email,
    this.displayName,
    this.photoURL,
    required this.totalSessions,
    required this.totalMinutes,
    required this.currentStreak,
    required this.bestStreak,
    this.lastSessionDate,
    required this.isFirebaseEnabled,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'totalSessions': totalSessions,
      'totalMinutes': totalMinutes,
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
      'lastSessionDate': lastSessionDate?.toIso8601String(),
      'isFirebaseEnabled': isFirebaseEnabled,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      email: map['email'],
      displayName: map['displayName'],
      photoURL: map['photoURL'],
      totalSessions: map['totalSessions'] ?? 0,
      totalMinutes: map['totalMinutes'] ?? 0,
      currentStreak: map['currentStreak'] ?? 0,
      bestStreak: map['bestStreak'] ?? 0,
      lastSessionDate: map['lastSessionDate'] != null 
          ? DateTime.parse(map['lastSessionDate']) 
          : null,
      isFirebaseEnabled: map['isFirebaseEnabled'] ?? false,
    );
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
    int? totalSessions,
    int? totalMinutes,
    int? currentStreak,
    int? bestStreak,
    DateTime? lastSessionDate,
    bool? isFirebaseEnabled,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      totalSessions: totalSessions ?? this.totalSessions,
      totalMinutes: totalMinutes ?? this.totalMinutes,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      lastSessionDate: lastSessionDate ?? this.lastSessionDate,
      isFirebaseEnabled: isFirebaseEnabled ?? this.isFirebaseEnabled,
    );
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, displayName: $displayName, totalSessions: $totalSessions, totalMinutes: $totalMinutes, currentStreak: $currentStreak, bestStreak: $bestStreak, lastSessionDate: $lastSessionDate, isFirebaseEnabled: $isFirebaseEnabled)';
  }
}
