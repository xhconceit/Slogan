import 'card_config.dart';
import 'card_type.dart';

/// 保存问答卡的标准答案
///
/// 用户查看题面并主动回忆后，通过翻面查看该答案
final class QuestionAnswerCardConfig extends CardConfig {
  const QuestionAnswerCardConfig({required this.answer});

  /// 问答卡展示在背面的参考答案
  final String answer;

  /// 问答配置固定对应问答类型
  @override
  CardType get type => CardType.questionAnswer;
}
