import 'package:flutter_test/flutter_test.dart';
import 'package:zaiwan/features/knowledge_card/data/mappers/knowledge_deck_mapper.dart';
import 'package:zaiwan/features/knowledge_card/data/models/knowledge_deck_model.dart';
import 'package:zaiwan/features/knowledge_card/domain/entities/knowledge_deck.dart';

/// 验证知识库数据模型和领域实体之间的映射。
void main() {
  test('将数据模型转换为领域实体', () {
    final now = DateTime.utc(2026, 9, 10);

    final entity = KnowledgeDeckMapper.toEntity(
      KnowledgeDeckModel(
        id: 'deck-001',
        name: 'Flutter',
        description: 'Flutter 开发知识',
        createdAt: now,
        updatedAt: now,
      ),
    );

    expect(entity.id, 'deck-001');
    expect(entity.name, 'Flutter');
    expect(entity.description, 'Flutter 开发知识');
    expect(entity.createdAt, now);
  });

  test('将领域实体转换为数据模型', () {
    final now = DateTime.utc(2026, 9, 10);

    final model = KnowledgeDeckMapper.toModel(
      KnowledgeDeck(
        id: 'deck-001',
        name: 'Flutter',
        description: 'Flutter 开发知识',
        createdAt: now,
        updatedAt: now,
      ),
    );

    expect(model.id, 'deck-001');
    expect(model.name, 'Flutter');
    expect(model.description, 'Flutter 开发知识');
    expect(model.updatedAt, now);
  });
}
