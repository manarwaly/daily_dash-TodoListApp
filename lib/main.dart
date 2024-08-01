import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:daily_dash/pages/home_page.dart';

void main() async {
  await Hive.initFlutter();
  await Hive.openBox('todoBox');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily Dash',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: const HomePage(),
    );
  }
}
