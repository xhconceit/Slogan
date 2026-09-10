import 'package:flutter_test/flutter_test.dart';
import 'package:zaiwan/features/knowledge_card/data/mappers/knowledge_card_mapper.dart';
import 'package:zaiwan/features/knowledge_card/data/models/knowledge_card_model.dart';
import 'package:zaiwan/features/knowledge_card/domain/entities/card_type.dart';
import 'package:zaiwan/features/knowledge_card/domain/entities/choice_card_config.dart';
import 'package:zaiwan/features/knowledge_card/domain/entities/choice_option.dart';
import 'package:zaiwan/features/knowledge_card/domain/entities/knowledge_card.dart';
import 'package:zaiwan/features/knowledge_card/domain/entities/question_answer_card_config.dart';

/// 验证知识卡片领域实体与数据模型之间的转换。
void main() {
  group('KnowledgeCardMapper', () {
    test('问答卡实体可以转换为数据模型', () {
      final now = DateTime.utc(2026, 9, 10);

      final model = KnowledgeCardMapper.toModel(
        KnowledgeCard(
          id: 'card-001',
          deckId: 'deck-001',
          prompt: 'Flutter 使用什么语言？',
          config: const QuestionAnswerCardConfig(
            answer: 'Dart',
          ),
          explanation: 'Flutter 应用主要使用 Dart。',
          tags: const ['Flutter'],
          createdAt: now,
          updatedAt: now,
        ),
      );

      expect(model.type, 'questionAnswer');
      expect(model.typeConfig, {'answer': 'Dart'});
      expect(model.tags, ['Flutter']);
    });

    test('问答卡数据模型可以恢复为领域实体', () {
      final now = DateTime.utc(2026, 9, 10);

      final entity = KnowledgeCardMapper.toEntity(
        KnowledgeCardModel(
          id: 'card-001',
          deckId: 'deck-001',
          type: 'questionAnswer',
          prompt: 'Flutter 使用什么语言？',
          typeConfig: const {'answer': 'Dart'},
          createdAt: now,
          updatedAt: now,
        ),
      );

      expect(entity.type, CardType.questionAnswer);

      final config =
          entity.config as QuestionAnswerCardConfig;

      expect(config.answer, 'Dart');
    });

    test('多选题可以完成实体和数据模型的往返转换', () {
      final now = DateTime.utc(2026, 9, 10);

      final original = KnowledgeCard(
        id: 'card-002',
        deckId: 'deck-001',
        prompt: '哪些属于 Flutter Widget？',
        config: ChoiceCardConfig(
          type: CardType.multipleChoice,
          options: const [
            ChoiceOption(
              id: 'a',
              content: 'StatefulWidget',
            ),
            ChoiceOption(
              id: 'b',
              content: 'StatelessWidget',
            ),
            ChoiceOption(
              id: 'c',
              content: 'Activity',
            ),
          ],
          correctOptionIds: const {'b', 'a'},
        ),
        createdAt: now,
        updatedAt: now,
      );

      final model = KnowledgeCardMapper.toModel(original);
      final restored = KnowledgeCardMapper.toEntity(model);

      expect(model.type, 'multipleChoice');

      // 保存时按 ID 排序，保证相同数据产生稳定 JSON。
      expect(
        model.typeConfig['correctOptionIds'],
        ['a', 'b'],
      );

      expect(restored.type, CardType.multipleChoice);

      final config = restored.config as ChoiceCardConfig;

      expect(config.options.length, 3);
      expect(config.correctOptionIds, {'a', 'b'});
      expect(config.isCorrect({'a', 'b'}), isTrue);
    });

    test('未知的卡片类型不能恢复为领域实体', () {
      final now = DateTime.utc(2026, 9, 10);

      final model = KnowledgeCardModel(
        id: 'card-invalid',
        deckId: 'deck-001',
        type: 'unknownType',
        prompt: '未知卡片',
        typeConfig: const {},
        createdAt: now,
        updatedAt: now,
      );

      expect(
        () => KnowledgeCardMapper.toEntity(model),
        throwsA(isA<FormatException>()),
      );
    });

    test('尚未实现的语音卡不能被错误恢复', () {
      final now = DateTime.utc(2026, 9, 10);

      final model = KnowledgeCardModel(
        id: 'card-voice',
        deckId: 'deck-001',
        type: 'voiceAnswer',
        prompt: '请口头回答',
        typeConfig: const {
          'expectedText': '参考回答',
        },
        createdAt: now,
        updatedAt: now,
      );

      expect(
        () => KnowledgeCardMapper.toEntity(model),
        throwsUnsupportedError,
      );
    });
  });
}
