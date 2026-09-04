import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";

class AppleBottomNavigationBar extends StatelessWidget {
  const AppleBottomNavigationBar({
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return CupertinoTabBar(
      currentIndex: currentIndex,
      onTap: onTap,
      activeColor: Theme.of(context).colorScheme.primary,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.house),
          activeIcon: Icon(CupertinoIcons.house_fill),
          label: "今日",
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.rectangle_stack),
          activeIcon: Icon(CupertinoIcons.rectangle_stack_fill),
          label: "闪卡",
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.person),
          activeIcon: Icon(CupertinoIcons.person_fill),
          label: "我的",
        )
      ]
    );
  }
}