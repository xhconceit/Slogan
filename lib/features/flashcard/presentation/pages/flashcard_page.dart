import 'package:flutter/material.dart';

import '../../../../core/presentation/theme/app_spacing.dart';
import '../../../../core/presentation/theme/theme_context_extensions.dart';
import '../controllers/flashcard_controller.dart';
import '../widgets/flashcard_view.dart';

class FlashcardPage extends StatefulWidget {
  const FlashcardPage({required this.controller, super.key});

  final FlashcardController controller;

  @override
  State<FlashcardPage> createState() => _FlashcardPageState();
}

class _FlashcardPageState extends State<FlashcardPage> {
  // 当前显示的卡片下标
  int _currentIndex = 0;

  /// 切换到上一张卡片
  void _showPreviousCard() {
    if (_currentIndex == 0) {
      return;
    }

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

    setState(() {
      _currentIndex++;
    });
  }

  /// 监听控制器并加载闪卡数据
  @override
  void initState() {
    super.initState();

    // 控制器数据变化时刷新页面
    widget.controller.addListener(_refresh);
    widget.controller.loadFlashcards();
  }

  /// 释放动画控制器和页面监听
  @override
  void dispose() {
    widget.controller.removeListener(_refresh);
    super.dispose();
  }

  /// 数据发生变化时刷新页面
  void _refresh() {
    setState(() {});
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
          padding: const EdgeInsets.all(AppSpacing.large),
          child: Column(
            children: [
              // 显示当前学习进度
              Text(
                '${_currentIndex + 1} / ${flashcards.length}',
                style: context.textStyles.titleMedium,
              ),
              const SizedBox(height: AppSpacing.large),
              Expanded(
                child: Center(
                  child: FlashcardView(
                    // 卡片变化时创建新的翻转状态，自动恢复到问题面
                    key: ValueKey(flashcard.id),
                    question: flashcard.question,
                    answer: flashcard.answer,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.large),
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
