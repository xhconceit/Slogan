import 'package:flutter_test/flutter_test.dart';
import 'package:zaiwan/features/knowledge_card/data/models/knowledge_card_model.dart';

/// 验证知识卡片数据模型能够保存和恢复不同类型的 JSON。
void main() {
  group('KnowledgeCardModel', () {
    test('问答卡 JSON 可以完整往返转换', () {
      final original = KnowledgeCardModel(
        id: 'card-001',
        deckId: 'deck-001',
        type: 'questionAnswer',
        prompt: 'Flutter 使用什么语言？',
        typeConfig: const {'answer': 'Dart'},
        explanation: 'Flutter 应用主要使用 Dart。',
        tags: const ['Flutter', '基础'],
        source: 'Flutter 文档',
        createdAt: DateTime.utc(2026, 9, 10, 8),
        updatedAt: DateTime.utc(2026, 9, 10, 9),
        nextReviewAt: DateTime.utc(2026, 9, 11, 8),
      );

      final restored = KnowledgeCardModel.fromJson(original.toJson());

      expect(restored.schemaVersion, 1);
      expect(restored.id, original.id);
      expect(restored.deckId, original.deckId);
      expect(restored.type, 'questionAnswer');
      expect(restored.prompt, original.prompt);
      expect(restored.typeConfig, {'answer': 'Dart'});
      expect(restored.tags, ['Flutter', '基础']);
      expect(restored.nextReviewAt, original.nextReviewAt);
    });

    test('选择题 JSON 可以完整往返转换', () {
      final original = KnowledgeCardModel(
        id: 'card-002',
        deckId: 'deck-001',
        type: 'multipleChoice',
        prompt: '哪些属于 Flutter Widget？',
        typeConfig: const {
          'options': [
            {'id': 'a', 'content': 'StatefulWidget'},
            {'id': 'b', 'content': 'StatelessWidget'},
            {'id': 'c', 'content': 'Activity'},
          ],
          'correctOptionIds': ['a', 'b'],
        },
        createdAt: DateTime.utc(2026, 9, 10, 8),
        updatedAt: DateTime.utc(2026, 9, 10, 8),
      );

      final restored = KnowledgeCardModel.fromJson(original.toJson());

      expect(restored.type, 'multipleChoice');
      expect(restored.typeConfig['options'], [
        {'id': 'a', 'content': 'StatefulWidget'},
        {'id': 'b', 'content': 'StatelessWidget'},
        {'id': 'c', 'content': 'Activity'},
      ]);
      expect(restored.typeConfig['correctOptionIds'], ['a', 'b']);
      expect(restored.nextReviewAt, isNull);
    });

    test('旧数据没有版本字段时默认使用版本 1', () {
      final model = KnowledgeCardModel.fromJson({
        'id': 'card-003',
        'deckId': 'deck-001',
        'type': 'questionAnswer',
        'prompt': '什么是 Widget？',
        'typeConfig': {'answer': 'Widget 是 UI 的不可变描述。'},
        'createdAt': '2026-09-10T08:00:00.000Z',
        'updatedAt': '2026-09-10T08:00:00.000Z',
      });

      expect(model.schemaVersion, 1);
      expect(model.tags, isEmpty);
      expect(model.nextReviewAt, isNull);
    });

    test('标签列表不能从模型外部修改', () {
      final sourceTags = <String>['Flutter'];
      final model = KnowledgeCardModel(
        id: 'card-004',
        deckId: 'deck-001',
        type: 'questionAnswer',
        prompt: '什么是 BuildContext？',
        typeConfig: const {'answer': 'Widget 在元素树中的位置引用。'},
        tags: sourceTags,
        createdAt: DateTime.utc(2026, 9, 10),
        updatedAt: DateTime.utc(2026, 9, 10),
      );

      sourceTags.add('外部修改');

      expect(model.tags, ['Flutter']);
      expect(() => model.tags.add('新标签'), throwsUnsupportedError);
    });
  });
}
