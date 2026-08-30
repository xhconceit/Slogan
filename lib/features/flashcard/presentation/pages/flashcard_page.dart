import 'dart:math';

import 'package:flutter/material.dart';

import '../controllers/flashcard_controller.dart';

class FlashcardPage extends StatefulWidget {
  const FlashcardPage({required this.controller, super.key});

  final FlashcardController controller;

  @override
  State<FlashcardPage> createState() => _FlashcardPageState();
}

class _FlashcardPageState extends State<FlashcardPage>
    with SingleTickerProviderStateMixin {
  // 控制卡片翻转进度 0 正面 1 反面
  late final AnimationController _flipController;

  // 当前显示的卡片下标
  int _currentIndex = 0;

  /// 切换到上一张卡片
  void _showPreviousCard() {
    if (_currentIndex == 0) {
      return;
    }
    // 切换卡片前恢复到问题面
    _flipController.reset();

    setState(() {
      _currentIndex--;
    });
  }

  /// 切换到下一张卡片
  void _showNextCard() {
    final lastIndex = widget.controller.flashcards.length - 1;
    if (_currentIndex == lastIndex) {
      return;
    }
    // 切换前恢复到问题面
    _flipController.reset();

    setState(() {
      _currentIndex++;
    });
  }

  // 初始化翻转动画并加载闪卡数据
  @override
  void initState() {
    super.initState();

    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    // 控制器数据变化时刷新页面
    widget.controller.addListener(_refresh);
    widget.controller.loadFlashcards();
  }

  /// 释放动画控制器和页面监听
  @override
  void dispose() {
    _flipController.dispose();
    widget.controller.removeListener(_refresh);
    super.dispose();
  }

  /// 数据发生变化时刷新页面
  void _refresh() {
    setState(() {});
  }

  /// 根据手指拖动距离更新卡片翻转进度
  void _handleDragUpdate(DragUpdateDetails details) {
    const dragDistance = 300.0;
    final delta = details.primaryDelta ?? 0;

    // 把手指拖动距离转成 0 - 1 的翻转进度
    _flipController.value = (_flipController.value - delta / dragDistance)
        .clamp(0.0, 1.0);
  }

  /// 手指松开后，将卡片吸附到问题面或答案面
  void _handleDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;

    if (velocity < -500) {
      // 快速向左滑，翻到答案面
      _flipController.animateTo(1, curve: Curves.easeOut);
    } else if (velocity > 500) {
      // 快速向右滑动 翻回问题面
      _flipController.animateBack(0, curve: Curves.easeOut);
    } else if (_flipController.value >= 0.5) {
      // 超过一半后松手，完成翻转
      _flipController.animateTo(1, curve: Curves.easeOut);
    } else {
      // 没超过一半，返回问题面
      _flipController.animateBack(0, curve: Curves.easeOut);
    }
  }

  /// 根据加载状态和当前下标构建闪卡页面
  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    if (controller.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (controller.error != null) {
      return const Scaffold(body: Center(child: Text('加载失败')));
    }

    if (controller.flashcards.isEmpty) {
      return const Scaffold(body: Center(child: Text('还没有卡片')));
    }

    final flashcards = controller.flashcards;
    final flashcard = flashcards[_currentIndex];

    return Scaffold(
      appBar: AppBar(title: const Text('闪卡')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // 显示当前学习进度
              Text(
                '${_currentIndex + 1} / ${flashcards.length}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Center(
                  child: GestureDetector(
                      key: const Key('flashcard'),
                    // 手指横向拖动时更新翻转进度
                    onHorizontalDragUpdate: _handleDragUpdate,
                    // 手指松开后完成或取消翻转
                    onHorizontalDragEnd: _handleDragEnd,
                    child: AnimatedBuilder(
                      animation: _flipController,
                      builder: (context, child) {
                        // 把 0～1 转换成 0～180° 的角度
                        final angle = _flipController.value * pi;
                        final showingBack = angle > pi / 2;

                        return Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            // 添加立体透视效果
                            ..setEntry(3, 2, 0.001)
                            ..rotateY(angle),
                          child: showingBack
                              ? Transform(
                                  alignment: Alignment.center,
                                  // 避免答案文字左右镜像
                                  transform: Matrix4.rotationY(pi),
                                  child: _CardFace(
                                    label: '答案',
                                    content: flashcard.answer,
                                  ),
                                )
                              : _CardFace(
                                  label: '问题',
                                  content: flashcard.question,
                                ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton.filledTonal(
                    // 第一张卡片不能继续向前
                    onPressed: _currentIndex == 0 ? null : _showPreviousCard,
                    icon: const Icon(Icons.arrow_back),
                  ),
                  IconButton.filled(
                    // 最后一张卡片不能继续向后
                    onPressed: _currentIndex == flashcards.length - 1
                        ? null
                        : _showNextCard,
                    icon: const Icon(Icons.arrow_forward),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardFace extends StatelessWidget {
  const _CardFace({required this.label, required this.content});

  final String label;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      height: 420,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const Spacer(),
          Text(
            content,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const Spacer(),
          const Text('左右拖动卡片翻转'),
        ],
      ),
    );
  }
}
