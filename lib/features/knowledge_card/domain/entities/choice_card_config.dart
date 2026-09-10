import 'card_config.dart';
import 'card_type.dart';
import 'choice_option.dart';

/// 保存单选题或多选题的专属配置。
///
/// 配置包含全部选项和正确答案，并负责判断用户答案是否完全正确。
final class ChoiceCardConfig extends CardConfig {
  ChoiceCardConfig({
    required this.type,
    required List<ChoiceOption> options,
    required Set<String> correctOptionIds,
  }) : options = List.unmodifiable(options),
       correctOptionIds = Set.unmodifiable(correctOptionIds) {
    _validate();
  }

  /// 当前选择题类型，只允许单选或多选。
  @override
  final CardType type;

  /// 展示给用户的所有选项。
  final List<ChoiceOption> options;

  /// 正确选项的稳定标识集合。
  final Set<String> correctOptionIds;

  /// 判断用户选择的答案是否完全正确。
  ///
  /// 答案数量和选项标识都一致时才返回 `true`。
  bool isCorrect(Set<String> selectedOptionIds) {
    return selectedOptionIds.length == correctOptionIds.length &&
        correctOptionIds.containsAll(selectedOptionIds);
  }

  /// 检查配置能否构成有效的单选题或多选题。
  void _validate() {
    if (type != CardType.singleChoice && type != CardType.multipleChoice) {
      throw ArgumentError('ChoiceCardConfig 只支持单选题或多选题');
    }

    if (options.length < 2) {
      throw ArgumentError('选择题至少需要两个选项');
    }

    final optionIds = options.map((option) => option.id).toList();
    final uniqueOptionIds = optionIds.toSet();

    if (uniqueOptionIds.length != optionIds.length) {
      throw ArgumentError('选择题的选项 ID 不能重复');
    }

    if (correctOptionIds.isEmpty) {
      throw ArgumentError('选择题至少需要一个正确答案');
    }

    if (!uniqueOptionIds.containsAll(correctOptionIds)) {
      throw ArgumentError('正确答案必须对应已有选项');
    }

    if (type == CardType.singleChoice && correctOptionIds.length != 1) {
      throw ArgumentError('单选题只能设置一个正确答案');
    }
  }
}
