import 'package:flutter/material.dart';

import '../../../../core/presentation/theme/app_radius.dart';
import '../../../../core/presentation/theme/app_spacing.dart';
import '../../../../core/presentation/theme/theme_context_extensions.dart';

/// 表示闪卡当前展示的面
enum FlashcardFaceType { question, answer }

/// 展示闪卡的问题面或答案面
class FlashcardFace extends StatelessWidget {
  const FlashcardFace({required this.type, required this.content, super.key});

  /// 当前展示的问题或者答案面
  final FlashcardFaceType type;

  /// 当前卡片的文字内容
  final String content;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    final zaiwanColors = context.zaiwanColors;

    // 根据卡片类型确定标题
    final label = type == FlashcardFaceType.question ? '问题' : '答案';

    // 根据卡片类型确定语义背景颜色
    final backgroundColor = type == FlashcardFaceType.question
        ? zaiwanColors.flashcardQuestion
        : zaiwanColors.flashcardAnswer;

    return Container(
      width: 320,
      height: 200,
      padding: const EdgeInsets.all(AppSpacing.large),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.large),
        boxShadow: [
          BoxShadow(
            color: colors.onSurface.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(label, style: textStyles.labelLarge),
          const SizedBox(height: AppSpacing.small),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                // 内容较长时允许在卡片内部滚动
                child: Text(
                  content,
                  textAlign: TextAlign.center,
                  style: textStyles.headlineMedium,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.small),
          Text(
            '左右拖动卡片翻转',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textStyles.bodyMedium,
          ),
        ],
      ),
    );
  }
}
