import 'package:flutter/material.dart';
import 'assignment_detail_screen.dart';

class AssignmentScreen extends StatelessWidget {
  const AssignmentScreen({super.key});

  final List<String> topics = const [
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
        padding: EdgeInsets.all(16),
        separatorBuilder: (_, __) =>const Divider() ,
        itemCount: topics.length,
        itemBuilder: (context, index) {
          final topic = topics[index];
          return Card(
            child: ListTile(
              leading: Icon(Icons.school,color: Colors.blue,),
              title: Text(topic, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AssignmentDetailScreen(topic: topic),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
