import 'package:flutter/material.dart';
import 'app_colors.dart';

/// 定义“在玩”产品特有的语义颜色
/// 
/// Material ColorScheme 没有闪卡正面，闪卡背面、
/// 锁定状态等产品特有的颜色，因此使用 ThemeExtension 扩展。
@immutable
class ZaiwanColors extends ThemeExtension<ZaiwanColors> {
  const ZaiwanColors({
    required this.reward,
    required this.flashcardQuestion,
    required this.flashcardAnswer,
    required this.locked,
    required this.unlocked,
  });

  /// 完成任务和奖励相关的颜色
  final Color reward;
  /// 闪卡问题的背景颜色
  final Color flashcardQuestion;
  /// 闪卡答案面的背景颜色
  final Color flashcardAnswer;
  /// App 锁定状态颜色
  final Color locked;
  /// App 解锁状态颜色
  final Color unlocked;
  // 亮色主题使用的产品语义颜色
  static const light = ZaiwanColors(
    reward: AppColors.warmOrange,
    flashcardQuestion: AppColors.paleBlue,
    flashcardAnswer: AppColors.cream,
    locked: AppColors.warmOrange,
    unlocked: AppColors.successGreen,
  );

  /// 创建只修改部分字段的新主题颜色
  @override
  ZaiwanColors copyWith({
    Color? reward,
    Color? flashcardQuestion,
    Color? flashcardAnswer,
    Color? locked,
    Color? unlocked,
  }) {
    return ZaiwanColors(
      reward: reward ?? this.reward,
      flashcardQuestion: flashcardQuestion ?? this.flashcardQuestion,
      flashcardAnswer: flashcardAnswer ?? this.flashcardAnswer,
      locked: locked ?? this.locked,
      unlocked: unlocked ?? this.unlocked,
    );
  }

  /// 在两个主题之间切换时计算过渡颜色
  @override
  ZaiwanColors lerp(
    covariant ZaiwanColors? outer
  ) {

  }
}