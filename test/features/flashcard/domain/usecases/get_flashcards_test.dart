import 'package:flutter_test/flutter_test.dart';

import 'package:zaiwan/features/flashcard/domain/entities/flashcard.dart';
import 'package:zaiwan/features/flashcard/domain/repositories/flashcard_repository.dart';
import 'package:zaiwan/features/flashcard/domain/usecases/get_flashcards.dart';

/// 成功返回预设闪卡的测试仓库
final class FakeFlashcardRepository implements FlashcardRepository {
  FakeFlashcardRepository(this.flashcards);

  /// 仓库预设的闪卡数据
  final List<Flashcard> flashcards;

  /// 记录仓库被调用的次数
  int callCount = 0;

  /// 返回预设的闪卡数据
  @override
  Future<List<Flashcard>> getFlashcards() async {
    callCount++;

    return flashcards;
  }
}

/// 始终加载失败的测试仓库
final class FailingFlashcardRepository implements FlashcardRepository {
  /// 模拟仓库加载失败
  @override
  Future<List<Flashcard>> getFlashcards() {
    return Future.error(StateError('加载闪卡失败'));
  }
}

/// 验证获取闪卡用例的行为
void main() {
  group('GetFlashcards', () {
    test('调用仓库并返回闪卡列表', () async {
      const expectedFlashcards = [
        Flashcard(id: 'card-001', question: 'What is 2 + 2?', answer: '4'),
      ];

      final repository = FakeFlashcardRepository(expectedFlashcards);
      final getFlashcards = GetFlashcards(repository);

      final result = await getFlashcards();

      expect(result, same(expectedFlashcards));
      expect(repository.callCount, 1);
    });

    test('仓库加载失败时向上抛出错误', () async {
      final repository = FailingFlashcardRepository();
      final getFlashcards = GetFlashcards(repository);

      await expectLater(() => getFlashcards(), throwsA(isA<StateError>()));
    });
  });
}
