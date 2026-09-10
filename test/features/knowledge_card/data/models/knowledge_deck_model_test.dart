import 'package:flutter_test/flutter_test.dart';
import 'package:zaiwan/features/knowledge_card/data/models/knowledge_deck_model.dart';

// 验证知识库数据模型能够正确转换和恢复 JSON
void main() {
  test('将知识库模型转换为 JSON ', () {
    final model = KnowledgeDeckModel(
      id: 'deck-001',
      name: 'Flutter',
      description: 'Flutter 开发知识',
      createdAt: DateTime.utc(2026, 9, 10, 8),
      updatedAt: DateTime.utc(2026, 9, 10, 9),
    );

    expect(model.toJson(), {
      'id': 'deck-001',
      'name': 'Flutter',
      'description': 'Flutter 开发知识',
      'createdAt': '2026-09-10T08:00:00.000Z',
      'updatedAt': '2026-09-10T09:00:00.000Z',
    });
  });

  test('从 JSON 恢复知识库模型', () {
    final model = KnowledgeDeckModel.fromJson({
      'id': 'deck-001',
      'name': 'Flutter',
      'description': null,
      'createdAt': '2026-09-10T08:00:00.000Z',
      'updatedAt': '2026-09-10T09:00:00.000Z',
    });

    expect(model.id, 'deck-001');
    expect(model.name, 'Flutter');
    expect(model.description, isNull);
    expect(model.createdAt, DateTime.utc(2026, 9, 10, 8));
    expect(model.updatedAt, DateTime.utc(2026, 9, 10, 9));
  });
}
