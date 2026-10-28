class SessionModel {
  final int? id;
  final DateTime startTime;
  final DateTime? endTime;
  final int durationSeconds;
  final bool success;
  final int streakAtTime;
  final DateTime createdAt;

  SessionModel({
    this.id,
    required this.startTime,
    this.endTime,
    required this.durationSeconds,
    required this.success,
    required this.streakAtTime,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'duration_seconds': durationSeconds,
      'success': success ? 1 : 0,
      'streak_at_time': streakAtTime,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory SessionModel.fromMap(Map<String, dynamic> map) {
    return SessionModel(
      id: map['id'],
      startTime: DateTime.parse(map['start_time']),
      endTime: map['end_time'] != null ? DateTime.parse(map['end_time']) : null,
      durationSeconds: map['duration_seconds'],
      success: map['success'] == 1,
      streakAtTime: map['streak_at_time'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  SessionModel copyWith({
    int? id,
    DateTime? startTime,
    DateTime? endTime,
    int? durationSeconds,
    bool? success,
    int? streakAtTime,
    DateTime? createdAt,
  }) {
    return SessionModel(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      success: success ?? this.success,
      streakAtTime: streakAtTime ?? this.streakAtTime,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'SessionModel(id: $id, startTime: $startTime, endTime: $endTime, durationSeconds: $durationSeconds, success: $success, streakAtTime: $streakAtTime, createdAt: $createdAt)';
  }
}
