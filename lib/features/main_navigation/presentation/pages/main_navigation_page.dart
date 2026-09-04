import "package:flutter/material.dart";

import "../../../flashcard/presentation/controllers/flashcard_controller.dart";
import "../../../flashcard/presentation/pages/flashcard_page.dart";
import "../../../home/presentation/pages/home_page.dart";
import "../controllers/main_navigation_controller.dart";
import "../widgets/apple_bottom_navigation_bar.dart";


class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({
    required this.controller,
    required this.flashcardController,
    super.key,
  });

  final MainNavigationController controller;
  final FlashcardController flashcardController;

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    _pages = [
      const HomePage(),
      FlashcardPage(
        controller: widget.flashcardController,
      ),
      const ProfilePage(),
    ];

    widget.controller.addListener(_refresh);
  }

  void _refresh() {
    setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_refresh);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: widget.controller.selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: AppleBottomNavigationBar(
        currentIndex: widget.controller.selectedIndex,
        onTap: widget.controller.selectIndex,
      ),
    );
  }
}


class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的'),
      ),
      body: const Center(
        child: Text('个人中心'),
      ),
    );
  }
}