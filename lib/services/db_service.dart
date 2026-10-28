import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import '../models/session_model.dart';

class DbService {
  static Database? _database;
  static const String _dbName = 'shrex.db';
  static const int _dbVersion = 1;

  static Future<void> init() async {
    try {
      _database = await _initDatabase();
      debugPrint('Database initialized successfully');
    } catch (e) {
      debugPrint('Error initializing database: $e');
      rethrow;
    }
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        start_time TEXT NOT NULL,
        end_time TEXT,
        duration_seconds INTEGER NOT NULL,
        success INTEGER NOT NULL DEFAULT 0,
        streak_at_time INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE user_stats (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        total_sessions INTEGER NOT NULL DEFAULT 0,
        total_minutes INTEGER NOT NULL DEFAULT 0,
        current_streak INTEGER NOT NULL DEFAULT 0,
        best_streak INTEGER NOT NULL DEFAULT 0,
        last_session_date TEXT,
        updated_at TEXT NOT NULL
      )
    ''');

    // Insert default user stats
    await db.insert('user_stats', {
      'total_sessions': 0,
      'total_minutes': 0,
      'current_streak': 0,
      'best_streak': 0,
      'last_session_date': null,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database migrations here
  }

  static Database get database {
    if (_database == null) {
      throw Exception('Database not initialized. Call DbService.init() first.');
    }
    return _database!;
  }

  // Session operations
  static Future<int> insertSession(SessionModel session) async {
    final db = database;
    return await db.insert('sessions', session.toMap());
  }

  static Future<List<SessionModel>> getAllSessions() async {
    final db = database;
    final maps = await db.query(
      'sessions',
      orderBy: 'start_time DESC',
    );
    return maps.map((map) => SessionModel.fromMap(map)).toList();
  }

  static Future<List<SessionModel>> getSessionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = database;
    final maps = await db.query(
      'sessions',
      where: 'start_time BETWEEN ? AND ?',
      whereArgs: [
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
      orderBy: 'start_time DESC',
    );
    return maps.map((map) => SessionModel.fromMap(map)).toList();
  }

  static Future<int> getTotalSessions() async {
    final db = database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM sessions WHERE success = 1');
    return (result.first['count'] as int?) ?? 0;
  }

  static Future<int> getTotalMinutes() async {
    final db = database;
    final result = await db.rawQuery('SELECT SUM(duration_seconds) as total FROM sessions WHERE success = 1');
    final totalSeconds = (result.first['total'] as int?) ?? 0;
    return totalSeconds ~/ 60;
  }

  // User stats operations
  static Future<Map<String, dynamic>> getUserStats() async {
    final db = database;
    final result = await db.query('user_stats', limit: 1);
    return result.isNotEmpty ? result.first : {};
  }

  static Future<void> updateUserStats(Map<String, dynamic> stats) async {
    final db = database;
    stats['updated_at'] = DateTime.now().toIso8601String();
    await db.update('user_stats', stats, where: 'id = 1');
  }

  static Future<void> incrementStreak() async {
    final stats = await getUserStats();
    final currentStreak = stats['current_streak'] ?? 0;
    final bestStreak = stats['best_streak'] ?? 0;
    
    final newStreak = currentStreak + 1;
    await updateUserStats({
      'current_streak': newStreak,
      'best_streak': newStreak > bestStreak ? newStreak : bestStreak,
      'last_session_date': DateTime.now().toIso8601String(),
    });
  }

  static Future<void> resetStreak() async {
    await updateUserStats({
      'current_streak': 0,
      'last_session_date': null,
    });
  }

  static Future<void> clearAllData() async {
    final db = database;
    await db.delete('sessions');
    await db.delete('user_stats');
    
    // Re-insert default user stats
    await db.insert('user_stats', {
      'total_sessions': 0,
      'total_minutes': 0,
      'current_streak': 0,
      'best_streak': 0,
      'last_session_date': null,
      'updated_at': DateTime.now().toIso8601String(),
    });
    
    debugPrint('All data cleared successfully');
  }

  static Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
