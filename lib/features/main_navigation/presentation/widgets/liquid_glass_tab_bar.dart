import "dart:ui";

import "package:flutter/cupertino.dart";

import '../models/main_navigation_item.dart';

class LiquidGlassTabBar extends StatelessWidget {
  const LiquidGlassTabBar({
    required this.items,
    required this.currentIndex,
    required this.onTap,
    super.key,
  }) : assert(
         currentIndex >= 0 && currentIndex < items.length,
         'currentIndex 必须对应一个导航项',
       );

  final List<MainNavigationItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = CupertinoColors.systemBackground
        .resolveFrom(context)
        .withValues(alpha: 0.72);

    final activeColor = CupertinoColors.activeBlue.resolveFrom(context);

    final borderColor = CupertinoColors.separator
        .resolveFrom(context)
        .withValues(alpha: 0.22);

    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: borderColor),
              boxShadow: [
                BoxShadow(
                  color: CupertinoColors.black.withValues(alpha: 0.10),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: SizedBox(
              height: 64,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final itemWidth = constraints.maxWidth / items.length;

                  return Stack(
                    children: [
                      // 在不同导航项之间滑动的选中胶囊
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 320),
                        curve: Curves.easeOutCubic,
                        left: itemWidth * currentIndex,
                        top: 0,
                        bottom: 0,
                        width: itemWidth,
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: activeColor.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: CupertinoColors.white.withValues(
                                  alpha: 0.20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // 按钮需要放在胶囊上面，确保可以接收点击
                      Row(
                        children: List.generate(
                          items.length,
                          (index) => Expanded(
                            child: _NavigationButton(
                              item: items[index],
                              selected: currentIndex == index,
                              onPressed: () => onTap(index),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavigationButton extends StatelessWidget {
  const _NavigationButton({
    required this.item,
    required this.selected,
    required this.onPressed,
  });

  final MainNavigationItem item;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final activeColor = CupertinoColors.activeBlue.resolveFrom(context);
    final inactiveColor = CupertinoColors.secondaryLabel.resolveFrom(context);

    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: CupertinoButton(
        padding: const EdgeInsets.all(6),
        pressedOpacity: 0.65,
        onPressed: onPressed,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: Icon(
                  selected ? item.activeIcon : item.icon,
                  key: ValueKey(selected),
                  size: 23,
                  color: selected ? activeColor : inactiveColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.label,
                maxLines: 1,
                style: TextStyle(
                  color: selected ? activeColor : inactiveColor,
                  fontSize: 10,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
