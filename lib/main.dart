import 'package:flutter/material.dart';
import 'package:hikou/core/hikou_theme.dart';
import 'package:hikou/features/home/presentation/home.dart';

void main() {
  runApp(const HikouApp());
}

class HikouApp extends StatelessWidget {
  const HikouApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Hikou',
        theme: HikouTheme.theme,
        home: const Home(title: 'Hikou'),
      );
}
