import "package:flutter/cupertino.dart";

final class MainNavigationItem {
  const MainNavigationItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
}

const mainNavigationItems = [
  MainNavigationItem(
    label: "今日",
    icon: CupertinoIcons.house,
    activeIcon: CupertinoIcons.house_fill,
  ),
  MainNavigationItem(
    label: "闪卡",
    icon: CupertinoIcons.rectangle_stack,
    activeIcon: CupertinoIcons.rectangle_stack_fill,
  ),
  MainNavigationItem(
    label: "我的",
    icon: CupertinoIcons.person,
    activeIcon: CupertinoIcons.person_fill,
  ),
];
