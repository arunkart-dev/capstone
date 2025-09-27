import 'dart:async';
import 'package:capstone/databases/badge_manager.dart';
import 'package:capstone/databases/db_helper.dart';
import 'package:capstone/services/gemni_service.dart';
import 'package:flutter/material.dart';

class GamifyScreen extends StatefulWidget {
  final String topic;
  const GamifyScreen({super.key, required this.topic});

  @override
  State<GamifyScreen> createState() => _GamifyScreenState();
}

class _GamifyScreenState extends State<GamifyScreen> {
  final GeminiService _gemini = GeminiService();
  List<Map<String, dynamic>> _questions = [];
  int _currentIndex = 0;
  int _score = 0;
  int _streak = 0;
  int _timeLeft = 10;
  Timer? _timer;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadGameQuiz();
  }

  Future<void> _loadGameQuiz() async {
  _loading = true;
  setState(() {});

  // 1️⃣ Load quizzes from DB
  final today = DateTime.now().toIso8601String().split("T").first;

  // 1️⃣ Clear old quizzes to ensure daily regeneration
  await DBHelper.instance.clearOldQuizzes();

  // 2️⃣ Load today's quizzes from DB
  final dbQuizzes = await DBHelper.instance.getQuizzes(widget.topic, today);

  if (dbQuizzes.isNotEmpty) {
    _questions = dbQuizzes.map((q) {
      // Parse options safely
      List<String> optionsList = [];
      final opts = q['options'];
      if (opts is String) {
        final items = opts.replaceAll("{", "").replaceAll("}", "").split(", ");
        for (var e in items) {
          if (e.contains(":")) {
            optionsList.add(e.split(":")[1].trim());
          } else {
            optionsList.add(e.trim());
          }
        }
      } else if (opts is List) {
        optionsList = List<String>.from(opts);
      }

      // Create new Map instead of modifying DB row
      return {
        ...q,
        'options': optionsList,
      };
    }).toList();
  } else {
    // 2️⃣ Generate new questions using Gemini
    final generated = await _gemini.generateGameQuiz(widget.topic, count: 5);
    print("Generated questions: ${generated.length}");

    // Save generated questions to DB
    for (var q in generated) {
      await DBHelper.instance.insertQuiz(
        widget.topic,
        q['question'],
        q['options'].toString(),
        q['answer'],
      );
    }

    // Load back from DB
    final saved = await DBHelper.instance.getQuizzes(widget.topic,today);
    _questions = saved.map((q) {
      List<String> optionsList = [];
      final opts = q['options'];
      if (opts is String) {
        final items = opts.replaceAll("{", "").replaceAll("}", "").split(", ");
        for (var e in items) {
          if (e.contains(":")) {
            optionsList.add(e.split(":")[1].trim());
          } else {
            optionsList.add(e.trim());
          }
        }
      } else if (opts is List) {
        optionsList = List<String>.from(opts);
      }
      return {
        ...q,
        'options': optionsList,
      };
    }).toList();
  }

  _loading = false;
  setState(() {});

  _startTimer();
}


  void _startTimer() {
    _timeLeft = 10;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        _nextQuestion(false);
      }
    });
  }

 void _nextQuestion(bool correct) async {
  _timer?.cancel();
  if (correct) {
    _score += 10;
    _streak++;

    // ✅ Check for streak-related badges
    if (_streak == 5) {
      await BadgeManager().checkStreakKing(_streak);
      await BadgeManager().checkMathGenius();
    }
  } else {
    _streak = 0;
  }

  if (_currentIndex < _questions.length - 1) {
    setState(() {
      _currentIndex++;
    });
    _startTimer();
  } else {
    // Update progress table in DB
    await DBHelper.instance.insertProgress('gamify', _score ~/ 10);

    // ✅ End-of-game badge checks
    await BadgeManager().checkMathGenius();

    _showGameOver();
  }
}


  void _showGameOver() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Game Over 🎮"),
        content: Text("Final Score: $_score\nBest Streak: $_streak"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final q = _questions[_currentIndex];
    final options = List<String>.from(q["options"]);

    return Scaffold(
      appBar: AppBar(
        title: Text("Gamify: ${widget.topic}"),
       // backgroundColor: Colors.greenAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("Score: $_score   🔥 Streak: $_streak",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: _timeLeft / 10,
              color: Colors.red,
              backgroundColor: Colors.grey.shade300,
            ),
            const SizedBox(height: 20),
            Text(
              q["question"] ?? "",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...options.map((opt) {
              return ElevatedButton(
                onPressed: () {
                  bool correct = opt.startsWith(q["answer"]);
                  _nextQuestion(correct);
                },
                child: Text(opt),
              );
            }),
          ],
        ),
      ),
    );
  }
}
