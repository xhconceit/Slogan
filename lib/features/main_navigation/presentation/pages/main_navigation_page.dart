import "package:flutter/material.dart";

import '../../../home/presentation/pages/home_page.dart';
import '../../../knowledge_card/presentation/controllers/create_knowledge_deck_controller.dart';
import '../../../knowledge_card/presentation/controllers/knowledge_deck_controller.dart';
import '../../../knowledge_card/presentation/controllers/manage_knowledge_deck_controller.dart';
import '../../../knowledge_card/presentation/pages/knowledge_deck_page.dart';
import '../controllers/main_navigation_controller.dart';
import '../models/main_navigation_item.dart';
import '../widgets/liquid_glass_tab_bar.dart';

/// 应用的三个一级页面及底部导航
///
/// 选中状态保存在控制器里
/// 监听和重建给 ListenableBuilder
class MainNavigationPage extends StatelessWidget {
  const MainNavigationPage({
    required this.controller,
    required this.knowledgeDeckController,
    required this.createKnowledgeDeckController,
    required this.manageKnowledgeDeckController,
    super.key,
  });

  final MainNavigationController controller;
  final KnowledgeDeckController knowledgeDeckController;
  final CreateKnowledgeDeckController createKnowledgeDeckController;
  final ManageKnowledgeDeckController manageKnowledgeDeckController;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        return Scaffold(
          // 页面内容延伸到底栏下面，供玻璃效果采样
          extendBody: true,
          // 切换标签时保留各页面的状态
          // IndexedStack 会在首次构建时创建所有子页面
          // 所有知识库加载会在应用启动时触发
          body: IndexedStack(
            index: controller.selectedIndex,
            children: [
              const HomePage(),
              KnowledgeDeckPage(
                controller: knowledgeDeckController,
                createController: createKnowledgeDeckController,
                manageController: manageKnowledgeDeckController,
              ),
              const ProfilePage(),
            ],
          ),
          bottomNavigationBar: LiquidGlassTabBar(
            items: mainNavigationItems,
            currentIndex: controller.selectedIndex,

            /// 点击导航项更新控制器
            /// 控制器通知 ListenableBuilder 刷新
            onTap: controller.selectIndex,
          ),
        );
      },
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('我的')),
      body: const Center(child: Text('个人中心')),
    );
  }
}
