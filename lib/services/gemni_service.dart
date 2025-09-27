import 'dart:async';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static const String _apiKey = "AIzaSyDBhGzFwQk1Gxmb46HW2NaOV_YkNwhphwU";

  final GenerativeModel _model;
  final Duration timeout;

  GeminiService({
    String modelName = 'gemini-1.5-flash', // ✅ or use 'gemini-1.5-pro'
    this.timeout = const Duration(seconds: 30),
  }) : _model = GenerativeModel(model: modelName, apiKey: _apiKey);

  Future<String> _generate(String prompt) async {
    try {
      final resp = await _model
          .generateContent([Content.text(prompt)])
          .timeout(timeout);

      final text = resp.text;
      if (text == null || text.trim().isEmpty) {
        return 'No response from Gemini.';
      }
      return text.trim();
    } on TimeoutException {
      return 'Request timed out. Please try again.';
    } catch (e) {
      return 'Error: $e';
    }
  }

  Future<List<String>> generateSyllabus(String subject, {int count = 5}) async {
    final prompt = '''
You are a math syllabus generator.
Create a numbered list of $count concise topics for: $subject.
Only output the list, one item per line.
''';

    final text = await _generate(prompt);
    return _extractLines(text);
  }

  Future<List<Map<String, dynamic>>> generateGameQuiz(String topic, {int count = 5}) async {
  final prompt = '''
Create $count very short and fun math quiz questions for the topic: $topic.
Each question should have 4 options (A, B, C, D).
Clearly mark the correct answer.
Format exactly like this:

Q: [question]
A) [option]
B) [option]
C) [option]
D) [option]
Answer: [letter]

Keep questions simple but interesting.
''';

  final text = await _generate(prompt);

  // Parse Gemini response into a List of Maps
  final questions = <Map<String, dynamic>>[];
  final blocks = text.split(RegExp(r'\nQ:'));
  for (var block in blocks) {
    if (block.trim().isEmpty) continue;

    final lines = block.trim().split('\n');
    final question = lines[0].replaceFirst(RegExp(r'^Q:\s*'), '').trim();

    final options = <String>[];
    String answer = '';

    for (var line in lines.skip(1)) {
      line = line.trim();
      if (line.startsWith('A)') ||
          line.startsWith('B)') ||
          line.startsWith('C)') ||
          line.startsWith('D)')) {
        options.add(line);
      } else if (line.toLowerCase().startsWith('answer:')) {
        answer = line.split(':')[1].trim();
      }
    }

    if (question.isNotEmpty && options.isNotEmpty && answer.isNotEmpty) {
      questions.add({
        "question": question,
        "options": options,
        "answer": answer,
      });
    }
  }

  return questions;
}



  Future<String> getdailyQuote() async {
    final prompt = '''
      Give me one short motivational quote about mathematics or learning.
Keep it under 20 words.
      ''';
    return _generate(prompt);
  }

  Future<List<Map<String, dynamic>>> generateQuiz(String topic, {int count = 5}) async {
  final prompt = '''
Create $count multiple-choice math quiz questions for the topic: $topic.
For each question, provide:
1. The question text
2. Four options labeled A, B, C, D
3. Clearly mark which option is correct

Format each question like this:
Q: [question text]
A) option1
B) option2
C) option3
D) option4
Answer: B
''';

  final text = await _generate(prompt);
  return _parseQuiz(text);
}

List<Map<String, dynamic>> _parseQuiz(String text) {
  final quiz = <Map<String, dynamic>>[];
  final blocks = text.split(RegExp(r'Q\d*:|Q:')).where((b) => b.trim().isNotEmpty);

  for (var block in blocks) {
    final lines = block.trim().split('\n').map((l) => l.trim()).toList();
    if (lines.length < 6) continue;

    final question = lines[0].replaceFirst(RegExp(r'^Q:?\s*'), '');
    final options = {
      'A': lines[1].replaceFirst('A)', '').trim(),
      'B': lines[2].replaceFirst('B)', '').trim(),
      'C': lines[3].replaceFirst('C)', '').trim(),
      'D': lines[4].replaceFirst('D)', '').trim(),
    };
    final answerMatch = RegExp(r'Answer:\s*([A-D])').firstMatch(block);
    final correct = answerMatch?.group(1);

    quiz.add({
      'question': question,
      'options': options,
      'answer': correct,
    });
  }
  return quiz;
}


  // inside GeminiService class

/// Generate a list of assignment questions for a topic
Future<List<String>> generateAssignments(String topic, {int count = 5}) async {
  final prompt = '''
Create $count concise math practice problems for the topic: $topic.
List each question on a new line. Do NOT provide the answers.
''';

  final text = await _generate(prompt);
  return _extractLines(text);
}

/// Get step-by-step solution for a single question
Future<String> getAnswer(String question) async {
  final prompt = '''
Solve the following math problem step-by-step for a beginner:
$question

Show each step on a new line, and give the final answer at the end.
''';
  return _generate(prompt);
}



  Future<String> askQuestion(
    String topic,
    String userInput, {
    String level = 'beginner',
  }) async {
    final prompt = '''
Topic: $topic
Question: $userInput
Explain step-by-step for a $level. 
If there is math, format clearly with each step on a new line.
''';
    return _generate(prompt);
  }

  List<String> _extractLines(String text) {
    return text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .map((l) => l.replaceFirst(RegExp(r'^\s*[-*\d\.\)]\s*'), ''))
        .toList();
  }
}
