import 'package:flutter/material.dart';

import '../features/flashcard/presentation/pages/flashcard_page.dart';
import 'dependency_injection.dart';

class ZaiwanApp extends StatelessWidget {
  const ZaiwanApp({required this.dependencies, super.key});

  final AppDependencies dependencies;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zaiwan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2F64C5)),
        scaffoldBackgroundColor: const Color(0xFFF8F6F1),
      ),
      home: FlashcardPage(controller: dependencies.flashcardController),
    );
  }
}
