import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  // Singleton instance
  static final DBHelper instance = DBHelper._internal();

  // Private constructor
  DBHelper._internal();

  factory DBHelper() => instance;

  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, "capstone.db");

    return await openDatabase(
      path,
      version: 3,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE assignments ADD COLUMN date TEXT');
        }
        if (oldVersion < 3) {
          await db.execute('ALTER TABLE quizzes ADD COLUMN date TEXT');
        }
      },
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE assignments (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            topic TEXT,
            question TEXT,
            completed INTEGER,
            date TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE quizzes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            topic TEXT,
            question TEXT,
            options TEXT,
            answer TEXT,
            userAnswer TEXT,
            date TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE progress (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            category TEXT,
            value INTEGER
          )
        ''');

        await db.execute('''
          CREATE TABLE badges (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            description TEXT,
            unlocked INTEGER
          )
        ''');

        await db.execute('''
          CREATE TABLE chats (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            topic TEXT,
            role TEXT,
            message TEXT,
            timestamp TEXT
          )
        ''');
      },
    );
  }

  // ---------------- ASSIGNMENTS ----------------
  Future<int> insertAssignment(
    String topic,
    String question,
    String today,
  ) async {
    final db = await this.db;
    final today =
        DateTime.now().toIso8601String().split("T").first; // YYYY-MM-DD
    return await db.insert("assignments", {
      "topic": topic,
      "question": question,
      "completed": 0,
      "date": today,
    });
  }

  Future<List<Map<String, dynamic>>> getAssignments(
    String topic,
    String date,
  ) async {
    final db = await this.db;
    return await db.query(
      "assignments",
      where: "topic = ? AND date = ?",
      whereArgs: [topic, date],
    );
  }

  // Optional: clear old assignments
  Future<int> clearOldAssignments(String today) async {
    final db = await this.db;
    final today = DateTime.now().toIso8601String().split("T").first;
    return await db.delete(
      "assignments",
      where: "date != ?",
      whereArgs: [today],
    );
  }

  Future<int> markAssignmentComplete(int id) async {
    final db = await this.db;
    return await db.update(
      "assignments",
      {"completed": 1},
      where: "id = ?",
      whereArgs: [id],
    );
  }

  // ---------------- QUIZZES ----------------
  // --- insertQuiz ---
Future<int> insertQuiz(String topic, String question, String options, String answer) async {
  final db = await this.db;
  final today = DateTime.now().toIso8601String().split("T").first;
  return await db.insert("quizzes", {
    "topic": topic,
    "question": question,
    "options": options,
    "answer": answer,
    "userAnswer": "",
    "date": today,
  });
}

  Future<List<Map<String, dynamic>>> getQuizzes(String topic, String date) async {
    final db = await this.db;
    return await db.query(
      "quizzes",
      where: "topic = ? AND date = ?",
      whereArgs: [topic, date],
    );
  }

  Future<int> clearOldQuizzes() async {
    final db = await this.db;
    final today = DateTime.now().toIso8601String().split("T").first;
    return await db.delete(
      "quizzes",
      where: "date != ?",
      whereArgs: [today],
    );
  }

  Future<int> updateQuizAnswer(int id, String userAnswer) async {
    final db = await this.db;
    return await db.update(
      "quizzes",
      {"userAnswer": userAnswer},
      where: "id = ?",
      whereArgs: [id],
    );
  }

  // ---------------- PROGRESS ----------------
  Future<int> insertProgress(String category, int value) async {
    final db = await this.db;
    return await db.insert("progress", {"category": category, "value": value});
  }

  Future<List<Map<String, dynamic>>> getProgress() async {
    final db = await this.db;
    return await db.query("progress");
  }

  // ---------------- BADGES ----------------
  Future<int> insertBadge(String name, String description) async {
    final db = await this.db;
    return await db.insert("badges", {
      "name": name,
      "description": description,
      "unlocked": 0,
    });
  }

  Future<List<Map<String, dynamic>>> getBadges() async {
    final db = await this.db;
    return await db.query("badges");
  }

  Future<int> unlockBadge(int id) async {
    final db = await this.db;
    return await db.update(
      "badges",
      {"unlocked": 1},
      where: "id = ?",
      whereArgs: [id],
    );
  }

  // ---------------- BADGES HELPERS ----------------
  Future<Map<String, dynamic>?> getBadgeByName(String name) async {
    final database = await db;
    final rows = await database.query(
      'badges',
      where: 'name = ?',
      whereArgs: [name],
      limit: 1,
    );
    return rows.isNotEmpty ? rows.first : null;
  }

  Future<void> unlockBadgeByName(String name) async {
    final database = await db;
    final badge = await getBadgeByName(name);
    if (badge == null) return; // badge not found in DB

    final unlocked = (badge['unlocked'] ?? 0) as int;
    if (unlocked == 1) return; // already unlocked

    await database.update(
      'badges',
      {'unlocked': 1},
      where: 'id = ?',
      whereArgs: [badge['id']],
    );
  }

  // ---------------- CHATS ----------------
  Future<int> insertChat(String topic, String role, String message) async {
    final db = await this.db;
    return await db.insert("chats", {
      "topic": topic,
      "role": role,
      "message": message,
      "timestamp": DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getChats(String topic) async {
    final db = await this.db;
    return await db.query(
      "chats",
      where: "topic = ?",
      whereArgs: [topic],
      orderBy: "timestamp ASC",
    );
  }

  Future<int> clearChats(String topic) async {
    final db = await this.db;
    return await db.delete("chats", where: "topic = ?", whereArgs: [topic]);
  }

  // ---------------- COMPLETED COUNTS ----------------
  Future<int> getCompletedAssignmentsCount() async {
    final database = await db;
    final result = await database.rawQuery(
      'SELECT COUNT(*) FROM assignments WHERE completed = 1',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getCompletedQuizzesCount() async {
    final database = await db;
    final result = await database.rawQuery(
      'SELECT COUNT(*) FROM quizzes WHERE userAnswer != ""',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
