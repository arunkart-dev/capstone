import 'package:flutter/material.dart';
import 'package:capstone/databases/db_helper.dart';
import 'package:capstone/models/badgemodel.dart' as badge_model;

class BadgesScreen extends StatefulWidget {
  const BadgesScreen({super.key});

  @override
  State<BadgesScreen> createState() => _BadgesScreenState();
}

class _BadgesScreenState extends State<BadgesScreen> {
  final List<badge_model.Badge> badges = [];

  @override
  void initState() {
    super.initState();
    _loadBadges();
  }

  Future<void> _loadBadges() async {
    // Fetch badges from DB
    final dbBadges = await DBHelper.instance.getBadges();

    if (dbBadges.isEmpty) {
      // Initialize default badges if DB is empty
      final defaultBadges = [
        badge_model.Badge(
          title: "Completion Badge",
          description: "Completed first assignment",
          icon: "https://cdn-icons-png.flaticon.com/512/190/190411.png",
        ),
        badge_model.Badge(
          title: "Quiz Master",
          description: "Scored 100% on a quiz",
          icon: "https://cdn-icons-png.flaticon.com/512/190/190422.png",
        ),
        badge_model.Badge(
          title: "Streak King",
          description: "5 correct answers streak in Gamify",
          icon: "https://cdn-icons-png.flaticon.com/512/190/190417.png",
        ),
        badge_model.Badge(
          title: "Learner",
          description: "Viewed all topics in Lessons",
          icon: "https://cdn-icons-png.flaticon.com/512/190/190406.png",
        ),
        badge_model.Badge(
          title: "Consistency Badge",
          description: "Opened app 7 days in a row",
          icon: "https://cdn-icons-png.flaticon.com/512/190/190422.png",
        ),
        badge_model.Badge(
          title: "Math Genius",
          description: "Completed 10 assignments or quizzes",
          icon: "https://cdn-icons-png.flaticon.com/512/190/190411.png",
        ),
      ];

      // Insert default badges into DB
      for (var b in defaultBadges) {
        await DBHelper.instance.insertBadge(b.title, b.description);
      }

      setState(() => badges.addAll(defaultBadges));
    } else {
      // Load badges from DB
      setState(() {
        badges.clear();
        badges.addAll(dbBadges.map((b) => badge_model.Badge(
              title: b['name'],
              description: b['description'],
              icon: b['icon'] ?? "https://cdn-icons-png.flaticon.com/512/190/190411.png",
              unlocked: b['unlocked'] == 1,
            )));
      });
    }
  }

  Future<void> unlockBadge(String title) async {
    final index = badges.indexWhere((b) => b.title == title);
    if (index != -1 && !badges[index].unlocked) {
      // Update DB: find the badge id by name (assuming names are unique)
      final dbBadges = await DBHelper.instance.getBadges();
      final badgeId = dbBadges.firstWhere((b) => b['name'] == title)['id'];
      await DBHelper.instance.unlockBadge(badgeId);

      setState(() {
        badges[index].unlocked = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Badges"),
       // backgroundColor: Colors.greenAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1,
          ),
          itemCount: badges.length,
          itemBuilder: (context, index) {
            final badge = badges[index];
            return Card(
              color: badge.unlocked ? Colors.greenAccent : Colors.grey.shade300,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.network(
                    badge.icon,
                    height: 60,
                    width: 60,
                    color: badge.unlocked ? null : Colors.grey,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    badge.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: badge.unlocked ? Colors.black : Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (badge.unlocked)
                    Text(
                      badge.description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12, color: Colors.black87),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
