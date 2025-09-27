import 'package:capstone/databases/db_helper.dart';
import 'package:capstone/services/gemni_service.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String topic;
  const ChatScreen({super.key, required this.topic});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Map<String, String>> messages = [];
  final TextEditingController _controller = TextEditingController();
  final GeminiService _gemini = GeminiService();
  final DBHelper _dbHelper = DBHelper();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
    _loadSyllabus();
  }

  Future<void> _loadChatHistory() async {
    final data = await _dbHelper.getChats(widget.topic);
    setState(() {
      messages.addAll(data.map((row) => {
            "role": row["role"] as String,
            "text": row["message"] as String,
          }));
    });
  }

  Future<void> _loadSyllabus() async {
    setState(() => isLoading = true);
    final topics = await _gemini.generateSyllabus(widget.topic, count: 5);

    final syllabusMsg =
        "Here’s your ${widget.topic} syllabus:\n${topics.join("\n")}";

    setState(() {
      messages.add({"role": "gemini", "text": syllabusMsg});
      isLoading = false;
    });

    await _dbHelper.insertChat(widget.topic, "gemini", syllabusMsg);
  }

  Future<void> _sendMessage(String text) async {
    setState(() {
      messages.add({"role": "user", "text": text});
      isLoading = true;
    });
    _controller.clear();

    await _dbHelper.insertChat(widget.topic, "user", text);

    final reply = await _gemini.askQuestion(widget.topic, text);

    setState(() {
      messages.add({"role": "gemini", "text": reply});
      isLoading = false;
    });

    await _dbHelper.insertChat(widget.topic, "gemini", reply);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.topic),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isUser = msg["role"] == "user";

                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser
                          ? theme.colorScheme.primary.withOpacity(0.8)
                          : theme.colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      msg["text"] ?? "",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isUser
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Write your query here',
                      hintStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.hintColor,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    if (_controller.text.isNotEmpty && !isLoading) {
                      _sendMessage(_controller.text);
                    }
                  },
                  icon: Icon(
                    Icons.send,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
