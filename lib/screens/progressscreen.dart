
import 'package:capstone/databases/db_helper.dart';
import 'package:capstone/services/gemni_service.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  int assignmentsCompleted = 0;
  int quizzesCompleted = 0;
  String? summary;
  bool loading = true;

  final GeminiService _gemini = GeminiService();

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    setState(() => loading = true);

    // Fetch real progress from SQLite
    final aCount = await DBHelper.instance.getCompletedAssignmentsCount();
    final qCount = await DBHelper.instance.getCompletedQuizzesCount();

    setState(() {
      assignmentsCompleted = aCount;
      quizzesCompleted = qCount;
    });

    await _generateSummary();
  }

  Future<void> _generateSummary() async {
    final prompt = """
You are a motivational math coach.
The user has completed $assignmentsCompleted assignments and $quizzesCompleted quizzes. 
Write 2-3 sentences that encourage the student, highlighting balance between practice and quizzes.
Keep it friendly and motivational.
""";

    final response = await _gemini.askQuestion("Progress", prompt);

    setState(() {
      summary = response;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
       // backgroundColor: Colors.greenAccent,
        title: const Text("Progress"),
       // foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: loading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Expanded(
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: (assignmentsCompleted > quizzesCompleted
                                  ? assignmentsCompleted
                                  : quizzesCompleted)
                              .toDouble() +
                              2, // Add some top space
                          barGroups: [
                            BarChartGroupData(x: 0, barRods: [
                              BarChartRodData(
                                toY: assignmentsCompleted.toDouble(),
                                color: Colors.blue,
                                width: 25,
                              ),
                            ]),
                            BarChartGroupData(x: 1, barRods: [
                              BarChartRodData(
                                toY: quizzesCompleted.toDouble(),
                                color: Colors.orange,
                                width: 25,
                              ),
                            ]),
                          ],
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: true),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  switch (value.toInt()) {
                                    case 0:
                                      return const Text(
                                        "Assignments",
                                        style: TextStyle(color: Colors.blue),
                                      );
                                    case 1:
                                      return const Text(
                                        "Quizzes",
                                        style: TextStyle(color: Colors.orange),
                                      );
                                  }
                                  return const Text("");
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    summary != null
                        ? Card(
                            elevation: 4,
                            color: Colors.green.shade50,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                summary!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          )
                        : const Text("No summary yet."),
                  ],
                ),
        ),
      ),
    );
  }
}
