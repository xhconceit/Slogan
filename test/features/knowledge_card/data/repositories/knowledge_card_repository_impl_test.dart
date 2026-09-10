import 'package:flutter_test/flutter_test.dart';
import 'package:zaiwan/features/knowledge_card/data/datasources/'
    'memory_knowledge_card_data_source.dart';
import 'package:zaiwan/features/knowledge_card/data/repositories/'
    'knowledge_card_repository_impl.dart';
import 'package:zaiwan/features/knowledge_card/domain/entities/'
    'card_type.dart';
import 'package:zaiwan/features/knowledge_card/domain/entities/'
    'choice_card_config.dart';
import 'package:zaiwan/features/knowledge_card/domain/entities/'
    'choice_option.dart';
import 'package:zaiwan/features/knowledge_card/domain/entities/'
    'knowledge_card.dart';
import 'package:zaiwan/features/knowledge_card/domain/entities/'
    'question_answer_card_config.dart';

void main() {
  group('KnowledgeCardRepositoryImpl', () {
    late MemoryKnowledgeCardDataSource dataSource;
    late KnowledgeCardRepositoryImpl repository;

    setUp(() {
      // 每条测试使用独立的内存数据源，避免测试互相影响。
      dataSource = MemoryKnowledgeCardDataSource();
      repository = KnowledgeCardRepositoryImpl(dataSource);
    });

    /// 创建测试使用的问答卡领域实体。
    KnowledgeCard createQuestionAnswerCard({
      String id = 'card-1',
      String deckId = 'deck-1',
      String prompt = 'Flutter 使用什么语言？',
      String answer = 'Dart',
    }) {
      final now = DateTime(2026, 9, 11);

      return KnowledgeCard(
        id: id,
        deckId: deckId,
        prompt: prompt,
        config: QuestionAnswerCardConfig(
          answer: answer,
        ),
        explanation: 'Flutter 应用主要使用 Dart。',
        tags: const ['Flutter', '基础'],
        source: 'Flutter 文档',
        createdAt: now,
        updatedAt: now,
      );
    }

    test('初始状态没有卡片', () async {
      final cards = await repository.getCardsByDeckId('deck-1');

      expect(cards, isEmpty);
    });

    test('可以保存并读取问答卡', () async {
      final card = createQuestionAnswerCard();

      await repository.saveCard(card);
      final savedCard = await repository.getCardById(card.id);

      expect(savedCard, isA<KnowledgeCard>());
      expect(savedCard?.id, card.id);
      expect(savedCard?.deckId, card.deckId);
      expect(savedCard?.prompt, card.prompt);
      expect(savedCard?.type, CardType.questionAnswer);
      expect(savedCard?.explanation, card.explanation);
      expect(savedCard?.tags, card.tags);
      expect(savedCard?.source, card.source);

      // 确认问答卡的专属配置经过转换后没有丢失。
      final config =
          savedCard?.config as QuestionAnswerCardConfig;

      expect(config.answer, 'Dart');
    });

    test('可以保存并读取多选题', () async {
      final now = DateTime(2026, 9, 11);
      final card = KnowledgeCard(
        id: 'card-2',
        deckId: 'deck-1',
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
          correctOptionIds: const {'a', 'b'},
        ),
        createdAt: now,
        updatedAt: now,
      );

      await repository.saveCard(card);
      final savedCard = await repository.getCardById(card.id);

      expect(savedCard?.type, CardType.multipleChoice);

      final config = savedCard?.config as ChoiceCardConfig;

      // 选项及正确答案经过 Model 转换后应保持完整。
      expect(config.options, hasLength(3));
      expect(config.options.first.id, 'a');
      expect(config.options.first.content, 'StatefulWidget');
      expect(config.correctOptionIds, {'a', 'b'});
      expect(config.isCorrect({'a', 'b'}), isTrue);
      expect(config.isCorrect({'a'}), isFalse);
    });

    test('查询不存在的卡片时返回 null', () async {
      final card = await repository.getCardById('missing-card');

      expect(card, isNull);
    });

    test('只返回指定知识库中的卡片', () async {
      final flutterCard = createQuestionAnswerCard(
        id: 'card-1',
        deckId: 'flutter-deck',
      );
      final englishCard = createQuestionAnswerCard(
        id: 'card-2',
        deckId: 'english-deck',
        prompt: 'apple 是什么意思？',
        answer: '苹果',
      );

      await repository.saveCard(flutterCard);
      await repository.saveCard(englishCard);

      final flutterCards = await repository.getCardsByDeckId(
        'flutter-deck',
      );
      final englishCards = await repository.getCardsByDeckId(
        'english-deck',
      );

      // Repository 必须保留 DataSource 的知识库隔离行为。
      expect(flutterCards, hasLength(1));
      expect(flutterCards.single.id, 'card-1');

      expect(englishCards, hasLength(1));
      expect(englishCards.single.id, 'card-2');
    });

    test('保存相同 ID 时更新已有卡片', () async {
      final originalCard = createQuestionAnswerCard(
        id: 'card-1',
        prompt: 'Flutter 使用什么语言？',
      );
      final updatedCard = createQuestionAnswerCard(
        id: 'card-1',
        prompt: 'Flutter 的主要编程语言是什么？',
        answer: 'Dart 语言',
      );

      await repository.saveCard(originalCard);
      await repository.saveCard(updatedCard);

      final cards = await repository.getCardsByDeckId('deck-1');
      final savedCard = await repository.getCardById('card-1');

      expect(cards, hasLength(1));
      expect(
        savedCard?.prompt,
        'Flutter 的主要编程语言是什么？',
      );

      final config =
          savedCard?.config as QuestionAnswerCardConfig;

      expect(config.answer, 'Dart 语言');
    });

    test('可以删除卡片', () async {
      final card = createQuestionAnswerCard();

      await repository.saveCard(card);
      await repository.deleteCard(card.id);

      expect(await repository.getCardById(card.id), isNull);
      expect(
        await repository.getCardsByDeckId(card.deckId),
        isEmpty,
      );
    });

    test('重复删除不存在的卡片不会报错', () async {
      // 删除操作保持幂等，多次执行具有相同结果。
      await repository.deleteCard('missing-card');
      await repository.deleteCard('missing-card');

      expect(
        await repository.getCardsByDeckId('deck-1'),
        isEmpty,
      );
    });
  });
}
