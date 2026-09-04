import 'package:flutter/material.dart';

import '../core/presentation/theme/app_theme.dart';
import '../features/main_navigation/presentation/pages/main_navigation_page.dart';
import 'dependency_injection.dart';

class ZaiwanApp extends StatelessWidget {
  const ZaiwanApp({required this.dependencies, super.key});

  final AppDependencies dependencies;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zaiwan',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: MainNavigationPage(
        controller: dependencies.mainNavigationController,
        flashcardController: dependencies.flashcardController,
      ),
    );
  }
}
