import "package:flutter/cupertino.dart";


final class MainNavigationItem {
  const MainNavigationItem({
    required this.label,
    required this.icon,
    required this.activeIcon
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
}