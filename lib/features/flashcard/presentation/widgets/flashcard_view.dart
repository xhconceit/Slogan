import 'dart:math';

import 'package:flutter/material.dart';

import 'flashcard_face.dart';

/// 展示一张可拖动翻转的闪卡
class FlashcardView extends StatefulWidget {
  const FlashcardView({
    required this.question,
    required this.answer,
    super.key,
  });

  /// 卡片正面的问题
  final String question;

  /// 卡片背面的答案
  final String answer;

  @override
  State<FlashcardView> createState() => _FlashcardViewState();
}

class _FlashcardViewState extends State<FlashcardView>
    with SingleTickerProviderStateMixin {
  /// 控制卡片翻转进度
  late final AnimationController _flipController;

  /// 初始化翻转动画
  @override
  void initState() {
    super.initState();

    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  /// 释放卡片翻转动画
  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  /// 根据手指拖动距离更新翻转进度
  void _handleDragUpdate(DragUpdateDetails details) {
    const dragDistance = 300.0;
    final delta = details.primaryDelta ?? 0.0;

    // 向左
    _flipController.value = (_flipController.value - delta / dragDistance)
        .clamp(0, 1.0)
        .toDouble();
  }

  /// 手指松开后吸附到问题面或者答案面
  void _handleDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;

    if (velocity < -500) {
      // 快速左滑，翻到答案面
      _flipController.animateTo(1, curve: Curves.easeOut);
    } else if (velocity > 500) {
      // 快速右滑，返回问题面
      _flipController.animateBack(0, curve: Curves.easeOut);
    } else if (_flipController.value >= 0.5) {
      // 超过一半，完成翻转
      _flipController.animateTo(1, curve: Curves.easeOut);
    } else {
      //  没有超过一半，取消翻转
      _flipController.animateBack(0, curve: Curves.easeOut);
    }
  }

  /// 构建可拖动翻转的卡片
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: const Key('flashcard'),
      onHorizontalDragUpdate: _handleDragUpdate,
      onHorizontalDragEnd: _handleDragEnd,
      child: AnimatedBuilder(
        animation: _flipController,
        builder: (context, child) {
          // 将 0-1 的进度转换成 0-180 度的旋转角度
          final angle = _flipController.value * pi;
          final showingBack = angle > pi / 2;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // 添加透视效果
              ..rotateY(angle),
            child: showingBack
                ? Transform(
                    alignment: Alignment.center,
                    // 避免答案文字左右镜像
                    transform: Matrix4.rotationY(pi),
                    child: FlashcardFace(
                      type: FlashcardFaceType.answer,
                      content: widget.answer,
                    ),
                  )
                : FlashcardFace(
                    type: FlashcardFaceType.question,
                    content: widget.question,
                  ),
          );
        },
      ),
    );
  }
}
