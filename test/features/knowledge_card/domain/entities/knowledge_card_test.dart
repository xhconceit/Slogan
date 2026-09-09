import 'package:flutter_test/flutter_test.dart';
import 'package:zaiwan/features/knowledge_card/domain/entities/card_type.dart';
import 'package:zaiwan/features/knowledge_card/domain/entities/knowledge_card.dart';
import 'package:zaiwan/features/knowledge_card/domain/entities/knowledge_deck.dart';

/// 验证知识库和通用知识卡片可以保存学习内容。
void main() {
  test('可以创建不绑定学科的知识库', () {
    final now = DateTime(2026, 9, 9);

    final deck = KnowledgeDeck(
      id: 'deck-001',
      name: 'Flutter',
      description: 'Flutter 开发知识',
      createdAt: now,
      updatedAt: now,
    );

    expect(deck.id, 'deck-001');
    expect(deck.name, 'Flutter');
    expect(deck.description, 'Flutter 开发知识');
  });

  test('可以创建基础问答卡', () {
    final now = DateTime(2026, 9, 9);

    final card = KnowledgeCard(
      id: 'card-001',
      deckId: 'deck-001',
      type: CardType.questionAnswer,
      prompt: 'Flutter 使用什么语言？',
      answer: 'Dart',
      explanation: 'Flutter 框架和应用代码主要使用 Dart。',
      tags: const ['Flutter', '基础'],
      createdAt: now,
      updatedAt: now,
    );

    expect(card.deckId, 'deck-001');
    expect(card.type, CardType.questionAnswer);
    expect(card.prompt, 'Flutter 使用什么语言？');
    expect(card.answer, 'Dart');
    expect(card.tags, ['Flutter', '基础']);
  });
}
