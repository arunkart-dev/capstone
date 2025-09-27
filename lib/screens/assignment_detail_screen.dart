import 'package:capstone/databases/db_helper.dart';
import 'package:capstone/databases/badge_manager.dart'; // ✅ Import BadgeManager
import 'package:capstone/services/gemni_service.dart';
import 'package:flutter/material.dart';

class AssignmentDetailScreen extends StatefulWidget {
  final String topic;
  const AssignmentDetailScreen({super.key, required this.topic});

  @override
  State<AssignmentDetailScreen> createState() => _AssignmentDetailScreenState();
}

class _AssignmentDetailScreenState extends State<AssignmentDetailScreen> {
  final GeminiService _gemini = GeminiService();
  final DBHelper _dbHelper = DBHelper();

  List<Map<String, dynamic>> assignments = [];
  bool _loadingAssignments = true;
  bool _loadingAnswer = false;
  String? _currentAnswer;

  @override
  void initState() {
    super.initState();
    _loadAssignments();
  }

  Future<void> _loadAssignments() async {
  setState(() {
    _loadingAssignments = true;
    assignments = [];
    _currentAnswer = null;
  });

  try {
    final today = DateTime.now().toIso8601String().split("T").first;

    // Clear old ones
    await _dbHelper.clearOldAssignments(today);

    // Fetch only today's
    final saved = await _dbHelper.getAssignments(widget.topic, today);

    if (saved.isNotEmpty) {
      setState(() {
        assignments = saved;
        _loadingAssignments = false;
      });
      return;
    }

    // If none, generate fresh
    final qs = await _gemini.generateAssignments(widget.topic, count: 5);

    for (final q in qs) {
      await _dbHelper.insertAssignment(widget.topic, q, today);
    }

    final savedAgain = await _dbHelper.getAssignments(widget.topic, today);
    setState(() {
      assignments = savedAgain;
    });
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to load assignments: $e')),
    );
  } finally {
    setState(() => _loadingAssignments = false);
  }
}


  Future<void> _showAnswer(int index) async {
    final question = assignments[index]["question"];
    setState(() {
      _loadingAnswer = true;
      _currentAnswer = null;
    });

    try {
      final ans = await _gemini.getAnswer(question);
      setState(() {
        _currentAnswer = ans;
      });

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (ctx) => DraggableScrollableSheet(
          expand: false,
          minChildSize: 0.3,
          initialChildSize: 0.45,
          maxChildSize: 0.9,
          builder: (_, controller) => Container(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              controller: controller,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Solution:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(question, style: const TextStyle(fontSize: 16)),
                  const Divider(),
                  _loadingAnswer
                      ? const Center(child: CircularProgressIndicator())
                      : Text(_currentAnswer ?? 'No answer available'),
                ],
              ),
            ),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch answer: $e')),
      );
    } finally {
      setState(() => _loadingAnswer = false);
    }
  }

  Future<void> _markCompleted(int id) async {
    await _dbHelper.markAssignmentComplete(id);

    // ✅ Check badges after marking complete
    await BadgeManager().checkCompletionBadge();
    await BadgeManager().checkMathGenius();
    
    final today = DateTime.now().toIso8601String().split("T").first;
    final updated = await _dbHelper.getAssignments(widget.topic,today);
    setState(() {
      assignments = updated;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assignments - ${widget.topic}'),
        backgroundColor: Colors.greenAccent,
        foregroundColor: Colors.black,
      ),
      body: _loadingAssignments
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAssignments,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: assignments.length,
                itemBuilder: (context, index) {
                  final q = assignments[index];
                  final completed = q["completed"] == 1;

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: ListTile(
                      title: Text(
                        q["question"],
                        style: TextStyle(
                          decoration: completed ? TextDecoration.lineThrough : null,
                          color: completed ? Colors.grey : null,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.lightbulb_outline),
                            tooltip: 'Show solution',
                            onPressed: () => _showAnswer(index),
                          ),
                          IconButton(
                            icon: Icon(
                              completed ? Icons.check_circle : Icons.check_circle_outline,
                              color: completed ? Colors.green : null,
                            ),
                            tooltip: 'Mark as completed',
                            onPressed: () => _markCompleted(q["id"]),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
