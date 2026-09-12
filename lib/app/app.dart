import 'package:flutter/material.dart';

import '../core/presentation/theme/app_theme.dart';
import '../features/main_navigation/presentation/pages/main_navigation_page.dart';
import 'dependency_injection.dart';


/// 配置主题和应用首页
///
/// 依赖由 AppRoot 持有，这里只负责传递
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
        /// 将知识库控制器传给主导航
        /// 再由主导航传给知识库页面
        knowledgeDeckController: dependencies.knowledgeDeckController
      ),
    );
  }
}
