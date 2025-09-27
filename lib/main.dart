import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:capstone/providers/theme_provider.dart';
import 'package:capstone/screens/splashscreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize theme provider and load saved theme
  final themeProvider = ThemeProvider();
  await themeProvider.loadTheme();

  runApp(
    ChangeNotifierProvider<ThemeProvider>.value(
      value: themeProvider,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'Mathslearn',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.currentTheme,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light, // ✅ light mode matches
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark, // ✅ dark mode matches
        ),
      ),
      home: const Splashscreen(),
    );
  }
}
