import 'package:capstone/providers/theme_provider.dart';
import 'package:capstone/screens/assignmentsscreen.dart';
import 'package:capstone/screens/badgesscreen.dart';
import 'package:capstone/screens/gamifyscreen.dart';
import 'package:capstone/screens/lessonscreen.dart';
import 'package:capstone/screens/progressscreen.dart';
import 'package:capstone/screens/quiz_screen.dart';
import 'package:capstone/screens/topicpickerscreen.dart';
import 'package:capstone/services/gemni_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  String _quote = "Today's Motivation";
  final _gemini = GeminiService();
  @override
  void initState() {
    super.initState();
    _loadQuote();
  }

  Future<void> _loadQuote() async {
  try {
    final q = await _gemini.getdailyQuote();
    setState(() {
      _quote = q;
    });
  } catch (e) {
    // Handle Gemini API error (like 503 overload)
    setState(() {
      _quote = "🌟 Keep pushing forward! Even when servers are overloaded, you’ve got this!";
    });
    debugPrint("Error fetching quote: $e"); // For debugging
  }
}


  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
       // backgroundColor: Colors.greenAccent,
        title: Text("Capstone", style: TextStyle(fontWeight: FontWeight.w500)),
       // foregroundColor: Colors.black,
        actions: [
          IconButton(
            onPressed: () {
              themeProvider.toggleTheme();
            },
            icon: Icon(themeProvider.currentTheme == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "Welcome To Caplearn",
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 35, 214, 127),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildbutton(Icons.book, "Learn", Colors.blue, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Lessonscreen()),
                      );
                    }),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildbutton(
                      Icons.task_sharp,
                      "Assignments",
                      Colors.green,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AssignmentScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildbutton(
                      Icons.bar_chart,
                      "Progress",
                      Colors.deepOrange,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProgressScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildbutton(
                      Icons.quiz,
                      "Quiz",
                      Colors.deepPurpleAccent,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => TopicPickerScreen(
                                  onTopicSelected: (topic) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => QuizScreen(topic: topic),
                                      ),
                                    );
                                  },
                                ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildbutton(
                      Icons.games,
                      "Gamify",
                      Colors.pinkAccent,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => TopicPickerScreen(
                                  onTopicSelected: (topic) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) =>
                                                GamifyScreen(topic: topic),
                                      ),
                                    );
                                  },
                                ),
                          ),
                        );
                      },
                    ),
                  ),
          
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildbutton(
                      Icons.badge,
                      "Badges",
                      Colors.lightBlue,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => BadgesScreen()),
                        );
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "Daily Quotes",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
                ),
              ),
              SizedBox(height: 20),
              Card(
                elevation: 4,
                color: Theme.of(context).colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                  color: Theme.of(context).colorScheme.primary, // outline color
                 width: 2, // border thickness
                 ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _quote,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontStyle: FontStyle.italic,
          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildbutton(
  IconData icon,
  String title,
  Color color,
  VoidCallback onTap,
) {
  return InkWell(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
          color: Colors.white.withOpacity(0.1), // subtle shadow
          blurRadius: 6, // how soft
          offset: const Offset(2, 4), 
          )
        ],
       // color: Colors.blue.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: color),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    ),
  );
}
