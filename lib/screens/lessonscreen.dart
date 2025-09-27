import 'package:capstone/screens/chatscreen.dart';
import 'package:flutter/material.dart';

class Lessonscreen extends StatelessWidget {
  const Lessonscreen({super.key});

  final List<String> topics = const [
    "Algebra",
    "Geometry",
    "Trignomentry",
    "Calculus",
    "Statistics",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      //  backgroundColor: Colors.greenAccent,
        title: Text('Lessons'),
       // foregroundColor: Colors.black,
      ),
      body: ListView.separated(
        padding: EdgeInsets.all(16),
        separatorBuilder: (_,__)=> const Divider(),
        itemCount: topics.length,
        itemBuilder: (context, index) {
          final topic = topics[index];
          return ListTile(
              leading: const Icon(Icons.school,color: Colors.blue,),
              title: Text(topic,style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ChatScreen(topic: topic)),
                );
              },
            );
          
        },
      ),
    );
  }
}
