// lib/screens/topic_picker_screen.dart
import 'package:flutter/material.dart';
import 'quiz_screen.dart';      // import if you want default behavior
  // not used here, but keep if needed elsewhere

class TopicPickerScreen extends StatelessWidget {
  final void Function(String)? onTopicSelected;

  const TopicPickerScreen({super.key, this.onTopicSelected});

  static const List<String> topics = [
    "Algebra",
    "Geometry",
    "Trigonometry",
    "Calculus",
    "Probability",
    "Statistics",
    "Number Theory",
    "Linear Algebra",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Choose a Topic"),
       // backgroundColor: Colors.greenAccent,
       // foregroundColor: Colors.black,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: topics.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final topic = topics[index];
          return ListTile(
            leading: const Icon(Icons.school, color: Colors.blue),
            title: Text(
              topic,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // If a callback was provided, call it (caller handles navigation)
              if (onTopicSelected != null) {
                onTopicSelected!(topic);
                return;
              }

              // Default behavior: navigate to QuizScreen for the selected topic
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => QuizScreen(topic: topic),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
