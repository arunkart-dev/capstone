import 'package:capstone/databases/badge_manager.dart';
import 'package:capstone/databases/db_helper.dart';
import 'package:capstone/services/gemni_service.dart';
import 'package:flutter/material.dart';

class QuizScreen extends StatefulWidget {
  final String topic;
  const QuizScreen({super.key, required this.topic});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final GeminiService _gemini = GeminiService();
  List<Map<String, dynamic>> quiz = [];
  int currentIndex = 0;
  int score = 0;
  String? selectedOption;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadQuiz();
  }

  Future<void> _loadQuiz() async {
  setState(() => loading = true);

  final today = DateTime.now().toIso8601String().split("T").first;

  // Load today's quizzes
  final dbQuizzes = await DBHelper.instance.getQuizzes(widget.topic, today);

  if (dbQuizzes.isNotEmpty) {
    quiz = dbQuizzes;
  } else {
    // Clear old quizzes
    await DBHelper.instance.clearOldQuizzes();

    // Generate new quizzes
    final generated = await _gemini.generateQuiz(widget.topic, count: 5);

    for (var q in generated) {
      await DBHelper.instance.insertQuiz(
        widget.topic,
        q['question'],
        q['options'].toString(),
        q['answer'],
      );
    }

    quiz = await DBHelper.instance.getQuizzes(widget.topic, today);
  }

  setState(() => loading = false);
}


  void _submitAnswer() async {
  if (selectedOption == null) return;

  final q = quiz[currentIndex];
  final correct = q['answer'];

  if (selectedOption == correct) {
    score += 10;
  }

  // Update userAnswer in DB
  await DBHelper.instance.updateQuizAnswer(q['id'], selectedOption!);

  if (currentIndex < quiz.length - 1) {
    setState(() {
      currentIndex++;
      selectedOption = null;
    });
  } else {
    // ✅ Update progress
    await DBHelper.instance.insertProgress('quiz', score ~/ 10);

    // ✅ Check badges
    await BadgeManager().checkQuizMaster(score, quiz.length);
    await BadgeManager().checkMathGenius();

    _showResult();
  }
}


  void _showResult() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          "Quiz Finished",
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
        ),
        content: Text("Your score: $score / ${quiz.length * 10}"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final q = quiz[currentIndex];

    // Flexible parsing of options
Map<String, String> parseOptions(dynamic rawOptions) {
  if (rawOptions == null) return {};

  // If already a Map from DB
  if (rawOptions is Map<String, dynamic>) {
    return rawOptions.map((k, v) => MapEntry(k.toString(), v.toString()));
  }

  // If stored as a JSON-like string
  if (rawOptions is String) {
    final cleaned = rawOptions.trim();

    // Case 1: {A: Apple, B: Banana}
    if (cleaned.startsWith("{") && cleaned.endsWith("}")) {
      return Map.fromEntries(
        cleaned
            .substring(1, cleaned.length - 1) // remove { }
            .split(", ")
            .where((e) => e.contains(":"))
            .map((e) {
          final split = e.split(":");
          final key = split.first.trim();
          final value = split.sublist(1).join(":").trim();
          return MapEntry(key, value);
        }),
      );
    }

    // Case 2: [Apple, Banana, Cherry]
    if (cleaned.startsWith("[") && cleaned.endsWith("]")) {
      final listItems = cleaned
          .substring(1, cleaned.length - 1) // remove [ ]
          .split(", ")
          .map((e) => e.trim())
          .toList();

      final letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".split("");
      return Map.fromIterables(
        letters.take(listItems.length),
        listItems,
      );
    }
  }

  return {};
}


// inside build():
final options = parseOptions(q['options']);


    return Scaffold(
      appBar: AppBar(
        title: Text("Quiz - ${widget.topic}"),
        backgroundColor: Colors.greenAccent,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Q${currentIndex + 1}: ${q['question']}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...options.entries.map((entry) {
              final key = entry.key;
              final value = entry.value;
              return RadioListTile<String>(
                value: key,
                groupValue: selectedOption,
                onChanged: (val) => setState(() => selectedOption = val),
                title: Text("$key) $value"),
              );
            }),
            const Spacer(),
            ElevatedButton(
              onPressed: _submitAnswer,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent,
                foregroundColor: Colors.black,
                minimumSize: const Size(100, 40),
              ),
              child: Text(
                currentIndex == quiz.length - 1 ? "Finish Quiz" : "Next Question",
              ),
            )
          ],
        ),
      ),
    );
  }
}
