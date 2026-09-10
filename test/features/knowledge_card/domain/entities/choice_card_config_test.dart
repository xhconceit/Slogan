import 'package:flutter_test/flutter_test.dart';
import 'package:zaiwan/features/knowledge_card/domain/entities/card_type.dart';
import 'package:zaiwan/features/knowledge_card/domain/entities/choice_option.dart';
import 'package:zaiwan/features/knowledge_card/domain/entities/choice_card_config.dart';

/// 验证选择题配置和答案判定规则。
void main() {
  group('ChoiceCardConfig', () {
    test('单选题选择正确答案时通过', () {
      final config = ChoiceCardConfig(
        type: CardType.singleChoice,
        options: const [
          ChoiceOption(id: 'a', content: 'Kotlin'),
          ChoiceOption(id: 'b', content: 'Dart'),
          ChoiceOption(id: 'c', content: 'Swift'),
        ],
        correctOptionIds: const {'b'},
      );
      expect(config.isCorrect({'b'}), isTrue);
      expect(config.isCorrect({'a'}), isFalse);
    });

    test('多选题必须完全选中所有正确答案', () {
      final config = ChoiceCardConfig(
        type: CardType.multipleChoice,
        options: const [
          ChoiceOption(id: 'a', content: 'StatefulWidget'),
          ChoiceOption(id: 'b', content: 'StatelessWidget'),
          ChoiceOption(id: 'c', content: 'Activity'),
        ],
        correctOptionIds: const {'a', 'b'},
      );
      expect(config.isCorrect({'a', 'b'}), isTrue);
      expect(config.isCorrect({'a'}), isFalse);
      expect(config.isCorrect({'a', 'b', 'c'}), isFalse);
    });

    test('选项顺序变化不会影响答案判断', () {
      final config = ChoiceCardConfig(
        type: CardType.singleChoice,
        options: const [
          ChoiceOption(id: 'c', content: 'Swift'),
          ChoiceOption(id: 'b', content: 'Dart'),
          ChoiceOption(id: 'a', content: 'Kotlin'),
        ],
        correctOptionIds: const {'b'},
      );

      expect(config.isCorrect({'b'}), isTrue);
    });

    test('正确答案不存在于选项中时拒绝创建', () {
      expect(
        () => ChoiceCardConfig(
          type: CardType.singleChoice,
          options: const [
            ChoiceOption(id: 'a', content: 'Kotlin'),
            ChoiceOption(id: 'b', content: 'Dart'),
          ],
          correctOptionIds: const {'c'},
        ),
        throwsArgumentError,
      );
    });

    test('单选题不能设置多个正确答案', () {
      expect(
        () => ChoiceCardConfig(
          type: CardType.singleChoice,
          options: const [
            ChoiceOption(id: 'a', content: '选项 A'),
            ChoiceOption(id: 'b', content: '选项 B'),
          ],
          correctOptionIds: const {'a', 'b'},
        ),
        throwsArgumentError,
      );
    });

    test('选择题配置会复制并保护选项与答案集合', () {
      final options = <ChoiceOption>[
        const ChoiceOption(id: 'a', content: '选项 A'),
        const ChoiceOption(id: 'b', content: '选项 B'),
      ];
      final correctIds = <String>{'a'};
      final config = ChoiceCardConfig(
        type: CardType.singleChoice,
        options: options,
        correctOptionIds: correctIds,
      );

      options.add(const ChoiceOption(id: 'c', content: '选项 C'));
      correctIds.add('b');

      expect(config.options.map((option) => option.id), ['a', 'b']);
      expect(config.correctOptionIds, {'a'});
      expect(
        () => config.options.add(const ChoiceOption(id: 'd', content: '选项 D')),
        throwsUnsupportedError,
      );
      expect(() => config.correctOptionIds.add('b'), throwsUnsupportedError);
    });
  });
}
