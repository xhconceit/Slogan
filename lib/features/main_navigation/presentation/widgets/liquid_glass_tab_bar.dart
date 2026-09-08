import 'dart:ui';

import 'package:flutter/cupertino.dart';

import '../models/main_navigation_item.dart';

class LiquidGlassTabBar extends StatefulWidget {
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
  State<LiquidGlassTabBar> createState() => _LiquidGlassTabBarState();
}

class _LiquidGlassTabBarState extends State<LiquidGlassTabBar> {
  double? _dragPosition;

  FragmentShader? _glassShader;

  @override
  void initState() {
    super.initState();
    _loadGlassShader();
  }

  Future<void> _loadGlassShader() async {
    if (!ImageFilter.isShaderFilterSupported) {
      debugPrint("当前渲染后端不支持背景 Shader，使用模糊效果");
      return;
    }
    try {
      final program = await FragmentProgram.fromAsset("shaders/glass.frag");
      if (!mounted) return;
      final shader = program.fragmentShader();

      // 索引 0、1 是 Flutter 设置的 u_size。
      // 索引 2 对应我们定义的 u_strength。
      shader.setFloat(2, 0.18);

      setState(() {
        _glassShader = shader;
      });
    } catch (error) {
      debugPrint("玻璃 Shader 加载失败: $error");
    }
  }

  @override
  void dispose() {
    _glassShader?.dispose();
    super.dispose();
  }

  bool _isPressed = false;
  void _setPressed(bool value) {
    if (_isPressed == value) return;
    setState(() => _isPressed = value);
  }

  void _updateDrag(double dx, double itemWidth, bool isRtl) {
    final visualPosition = dx / itemWidth - 0.5;
    final logicalPosition = isRtl
        ? widget.items.length - 1 - visualPosition
        : visualPosition;

    setState(() {
      _dragPosition = logicalPosition
          .clamp(0.0, (widget.items.length - 1).toDouble())
          .toDouble();
    });
  }

  void _finishDrag() {
    final index = _dragPosition?.round();

    setState(() {
      _dragPosition = null;
      _isPressed = false;
    });

    if (index != null && index != widget.currentIndex) {
      widget.onTap(index);
    }
  }

  void _cancelDrag() {
    setState(() {
      _dragPosition = null;
      _isPressed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    final backgroundColor = CupertinoColors.systemBackground
        .resolveFrom(context)
        .withValues(alpha: isDark ? 0.55 : 0.30);

    final borderColor = CupertinoColors.white.withValues(
      alpha: isDark ? 0.20 : 0.45,
    );

    final highlightStrength = isDark ? 0.45 : 1.0;
    final radius = BorderRadius.circular(34);

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: DecoratedBox(
        // 阴影放在裁剪区域外，避免被切掉。
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.black.withValues(alpha: 0.12),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: BackdropFilter(
            filter: _glassShader == null
                ? ImageFilter.blur(sigmaX: 24, sigmaY: 24)
                : ImageFilter.shader(_glassShader!),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: radius,
                border: Border.all(color: borderColor, width: 0.8),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    CupertinoColors.white.withValues(
                      alpha: 0.38 * highlightStrength,
                    ),
                    CupertinoColors.white.withValues(
                      alpha: 0.06 * highlightStrength,
                    ),
                    CupertinoColors.white.withValues(
                      alpha: 0.02 * highlightStrength,
                    ),
                    CupertinoColors.white.withValues(
                      alpha: 0.18 * highlightStrength,
                    ),
                  ],
                  stops: const [0.0, 0.35, 0.65, 1.0],
                ),
              ),
              child: SizedBox(
                height: 66,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final itemWidth =
                        constraints.maxWidth / widget.items.length;

                    final position =
                        _dragPosition ?? widget.currentIndex.toDouble();

                    final visualPosition = isRtl
                        ? widget.items.length - 1 - position
                        : position;

                    return Listener(
                      // 已识别的拖动收到 PointerCancel 时也可能触发结束回调。
                      // 先清除预览位置，避免将系统取消当作用户松手提交。
                      onPointerCancel: (_) => _cancelDrag(),
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onHorizontalDragStart: (details) {
                          _setPressed(true);
                          _updateDrag(
                            details.localPosition.dx,
                            itemWidth,
                            isRtl,
                          );
                        },
                        onHorizontalDragUpdate: (details) {
                          _updateDrag(
                            details.localPosition.dx,
                            itemWidth,
                            isRtl,
                          );
                        },
                        onHorizontalDragEnd: (_) => _finishDrag(),
                        onHorizontalDragCancel: _cancelDrag,
                        onTapDown: (_) => _setPressed(true),
                        onTapUp: (_) => _setPressed(false),
                        onTapCancel: () => _setPressed(false),
                        child: Stack(
                          children: [
                            // 高光只绘制在背景上，不覆盖图标，也不接收触摸。
                            Positioned.fill(
                              child: IgnorePointer(
                                child: AnimatedContainer(
                                  duration:
                                      reduceMotion || _dragPosition != null
                                      ? Duration.zero
                                      : const Duration(milliseconds: 360),
                                  curve: Curves.easeOutCubic,
                                  decoration: BoxDecoration(
                                    gradient: RadialGradient(
                                      center: Alignment(
                                        !reduceMotion && _dragPosition != null
                                            ? (visualPosition + 0.5) /
                                                      widget.items.length *
                                                      2 -
                                                  1
                                            : -0.65,
                                        -0.85,
                                      ),
                                      radius: 2.4,
                                      colors: [
                                        CupertinoColors.white.withValues(
                                          alpha:
                                              highlightStrength *
                                              (_isPressed ? 0.28 : 0.12),
                                        ),
                                        CupertinoColors.white.withValues(
                                          alpha: 0,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            AnimatedPositioned(
                              duration: _dragPosition != null || reduceMotion
                                  ? Duration.zero
                                  : const Duration(milliseconds: 320),
                              curve: Curves.easeOutCubic,
                              left: itemWidth * visualPosition,
                              top: 0,
                              bottom: 0,
                              width: itemWidth,
                              child: IgnorePointer(
                                child: Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: TweenAnimationBuilder<Offset>(
                                    tween: Tween<Offset>(
                                      begin: const Offset(1, 1),
                                      end: _isPressed && !reduceMotion
                                          ? const Offset(1.06, 0.94)
                                          : const Offset(1, 1),
                                    ),
                                    duration: reduceMotion
                                        ? Duration.zero
                                        : Duration(
                                            milliseconds: _isPressed
                                                ? 140
                                                : 420,
                                          ),
                                    curve: _isPressed
                                        ? Curves.easeOutCubic
                                        : Curves.elasticOut,
                                    builder: (context, scale, child) {
                                      return Transform(
                                        alignment: Alignment.center,
                                        transform: Matrix4.diagonal3Values(
                                          scale.dx,
                                          scale.dy,
                                          1,
                                        ),
                                        child: child,
                                      );
                                    },
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: CupertinoColors
                                            .tertiarySystemFill
                                            .resolveFrom(context),
                                        borderRadius: BorderRadius.circular(28),
                                        border: Border.all(
                                          color: CupertinoColors.white
                                              .withValues(
                                                alpha: isDark ? 0.12 : 0.35,
                                              ),
                                          width: 0.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Row(
                              children: List.generate(
                                widget.items.length,
                                (index) => Expanded(
                                  child: _NavigationButton(
                                    item: widget.items[index],
                                    selected: widget.currentIndex == index,
                                    onPressed: () => widget.onTap(index),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
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
    final inactiveColor = CupertinoColors.label.resolveFrom(context);
    final color = selected ? activeColor : inactiveColor;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Semantics(
      selected: selected,
      child: CupertinoButton(
        padding: const EdgeInsets.all(6),
        pressedOpacity: 0.65,
        onPressed: onPressed,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: reduceMotion
                    ? Duration.zero
                    : const Duration(milliseconds: 180),
                child: Icon(
                  selected ? item.activeIcon : item.icon,
                  key: ValueKey(selected),
                  size: 25,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.label,
                maxLines: 1,
                style: TextStyle(
                  color: color,
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
