import 'package:flutter/material.dart';

import '../features/flashcard/presentation/pages/flashcard_page.dart';
import 'dependency_injection.dart';
import '../core/presentation/theme/app_theme.dart';


class ZaiwanApp extends StatelessWidget {
  const ZaiwanApp({required this.dependencies, super.key});

  final AppDependencies dependencies;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zaiwan',
      debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
      home: FlashcardPage(controller: dependencies.flashcardController),
    );
  }
}
