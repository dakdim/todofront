import 'package:flutter/material.dart';
import 'view/home.dart'; // Import home.dart

void main() {
  runApp(const MyApp()); // Root widget
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Homepage(), // Use myapp from home.dart as the home screen
    );
  }
}
