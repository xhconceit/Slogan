import 'package:flutter/material.dart';

import '../controllers/create_knowledge_deck_controller.dart';
import '../controllers/knowledge_deck_controller.dart';
import '../controllers/manage_knowledge_deck_controller.dart';
import '../../domain/entities/knowledge_deck.dart';
import '../../domain/usecases/get_knowledge_cards_by_deck_id.dart';
import '../controllers/knowledge_card_controller.dart';
import 'knowledge_card_page.dart';

/// 知识库列表页面
///
/// 控制器由外部传入，页面负责展示状态和触发加载
class KnowledgeDeckPage extends StatefulWidget {
  const KnowledgeDeckPage({
    required this.controller,
    required this.createController,
    required this.manageController,
    required this.getKnowledgeCardsByDeckId,
    super.key,
  });

  final KnowledgeDeckController controller;
  final CreateKnowledgeDeckController createController;
  final ManageKnowledgeDeckController manageController;

  /// 打开知识库时，用它创建改知识库的卡片控制器
  final GetKnowledgeCardsByDeckId getKnowledgeCardsByDeckId;
  @override
  State<KnowledgeDeckPage> createState() => _KnowledgeDeckPageState();
}

class _KnowledgeDeckPageState extends State<KnowledgeDeckPage> {
  @override
  void initState() {
    super.initState();

    // 页面首次创建时加载数据
    // 不放在 build 中，避免每次重建都重新加载
    widget.controller.loadDecks();
  }

  @override
  void didUpdateWidget(covariant KnowledgeDeckPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 如果父组件换一个控制器，就加载新控制器
    if (oldWidget.controller != widget.controller) {
      widget.controller.loadDecks();
    }
  }

  @override
  Widget build(BuildContext context) {
    // 控制器调用 notifyListeners() 时
    // ListenableBuilder 会重新构建里面的界面
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, child) {
        final controller = widget.controller;
        return Scaffold(
          appBar: AppBar(
            title: const Text('知识库'),
            actions: [
              IconButton(
                tooltip: '刷新知识库',

                /// 加载中禁用按钮，避免重复操作
                onPressed: controller.isLoading
                    ? null
                    : () {
                        controller.loadDecks();
                      },
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          body: _buildBody(context),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              _showCreateDeckDialog(context);
            },
            icon: const Icon(Icons.add),
            label: const Text('新建知识库'),
          ),
        );
      },
    );
  }

  /// 打开指定知识库的卡片列表
  Future<void> _openDeck(KnowledgeDeck deck) async {
    // 每次打开页面都创建独立的控制器
    // deckID 决定查询那个知识库，查询用例依然共用
    final controller = KnowledgeCardController(
      deckId: deck.id,
      getKnowledgeCardsByDeckId: widget.getKnowledgeCardsByDeckId,
    );

    // 创建页面路由，传入标题和控制器
    final route = MaterialPageRoute<void>(
      builder: (context) =>
          KnowledgeCardPage(deckName: deck.name, controller: controller),
    );

    try {
      // 将卡片页面压入导航栈
      // 用户返回时， 这个 Future 完成
      await Navigator.of(context).push<void>(route);

      /// 返回动画结束，路由移除后，页面才不再使用控制器
      await route.completed;
    } finally {
      /// 谁创建，谁释放
      /// 即使导航过程中出现异常，也清理控制器
      controller.dispose();
    }
  }

  Future<void> _showCreateDeckDialog(BuildContext context) async {
    final deckId = 'deck-${DateTime.now().microsecondsSinceEpoch}';
    final created =
        await showDialog<bool>(
          context: context,
          builder: (dialogContext) => _CreateKnowledgeDeckDialog(
            controller: widget.createController,
            deckId: deckId,
          ),
        ) ??
        false;

    if (created && mounted) {
      await widget.controller.loadDecks();
    }
  }

  /// 根据控制器状态选择要显示的内容
  Widget _buildBody(BuildContext context) {
    final controller = widget.controller;

    //  1. 没有旧数据且正在加载，显示居中加载提示
    if (controller.isLoading && controller.decks.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // 2. 没有旧数据且加载失败时，显示整页错误提示。
    if (controller.error != null && controller.decks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 16),
              const Text('知识库加载失败，请重试'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  controller.loadDecks();
                },
                child: const Text('重新加载'),
              ),
            ],
          ),
        ),
      );
    }

    // 3. 加载成功，但还没有知识库
    if (controller.decks.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.library_books_outlined, size: 56),
              SizedBox(height: 16),
              Text("还没有知识库"),
              SizedBox(height: 8),
              Text('知识库用来整理同一主题的学习卡片'),
            ],
          ),
        ),
      );
    }

    /// 4. 有数据时显示列表
    // 刷新期间保留旧内容，不把整个页面替换为加载动画
    return Column(
      children: [
        if (controller.isLoading) const LinearProgressIndicator(),
        // 刷新失败依然保留旧列表，并说明当前状态
        if (controller.error != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Text(
              '刷新失败，当前显示上次加载的内容，请点击右上角重试',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),

        /// Expanded 给列表分配剩余高度，避免列表高度无限
        Expanded(
          child: RefreshIndicator(
            onRefresh: controller.loadDecks,
            child: ListView.separated(
              // 即使列表很短，也允许下拉刷新
              physics: const AlwaysScrollableScrollPhysics(),

              /// 为现有底部导航留出空间
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 140),
              itemCount: controller.decks.length,
              separatorBuilder: (context, index) {
                return const SizedBox(height: 12);
              },
              itemBuilder: (context, index) {
                final deck = controller.decks[index];
                final description = deck.description;
                return Card(
                  key: ValueKey(deck.id),
                  margin: EdgeInsets.zero,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: const Icon(Icons.library_books_outlined),

                    title: Text(deck.name),

                    // 点击知识库主体，打开对应的卡片列表。
                    // 右侧菜单仍负责编辑和删除。
                    onTap: () {
                      _openDeck(deck);
                    },

                    /// 没有描述时不显示副标题
                    subtitle: description == null || description.trim().isEmpty
                        ? null
                        : Text(description),
                    trailing: PopupMenuButton<_DeckAction>(
                      tooltip: '管理知识库',
                      onSelected: (action) {
                        switch (action) {
                          case _DeckAction.edit:
                            _showEditDeckDialog(context, deck);
                          case _DeckAction.delete:
                            _confirmDeleteDeck(context, deck);
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: _DeckAction.edit,
                          child: Text('编辑'),
                        ),
                        PopupMenuItem(
                          value: _DeckAction.delete,
                          child: Text('删除'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showEditDeckDialog(
    BuildContext context,
    KnowledgeDeck deck,
  ) async {
    final updated = await showDialog<bool>(
      context: context,
      builder: (context) => _EditKnowledgeDeckDialog(
        controller: widget.manageController,
        deck: deck,
      ),
    );
    if (updated == true && mounted) await widget.controller.loadDecks();
  }

  Future<void> _confirmDeleteDeck(
    BuildContext context,
    KnowledgeDeck deck,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('删除知识库'),
        content: Text('确定删除“${deck.name}”及其中的全部卡片吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final success = await widget.manageController.deleteDeck(deck.id);
    if (success && mounted) {
      await widget.controller.loadDecks();
    } else if (mounted) {
      ScaffoldMessenger.of(this.context)
          .showSnackBar(const SnackBar(content: Text('删除知识库失败，请重试')));
    }
  }
  // 不在这里 dispose 控制器：
  // 它由外部传入，生命周期应由拥有它的对象管理。
  // ListenableBuilder 会自动移除自己的监听。
}

enum _DeckAction { edit, delete }

class _EditKnowledgeDeckDialog extends StatefulWidget {
  const _EditKnowledgeDeckDialog({
    required this.controller,
    required this.deck,
  });

  final ManageKnowledgeDeckController controller;
  final KnowledgeDeck deck;

  @override
  State<_EditKnowledgeDeckDialog> createState() =>
      _EditKnowledgeDeckDialogState();
}

class _EditKnowledgeDeckDialogState extends State<_EditKnowledgeDeckDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.deck.name);
    _descriptionController = TextEditingController(
      text: widget.deck.description,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final success = await widget.controller.updateDeck(
      deck: widget.deck,
      name: _nameController.text,
      description: _descriptionController.text,
    );
    if (!mounted) return;
    if (success) {
      Navigator.of(context).pop(true);
      return;
    }
    final message = widget.controller.error is ArgumentError
        ? '请输入知识库名称'
        : '保存知识库失败，请重试';
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, child) {
        final isBusy = widget.controller.isBusy;
        return AlertDialog(
          title: const Text('编辑知识库'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                enabled: !isBusy,
                decoration: const InputDecoration(labelText: '名称'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                enabled: !isBusy,
                maxLines: 3,
                decoration: const InputDecoration(labelText: '描述（可选）'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isBusy ? null : () => Navigator.of(context).pop(false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: isBusy ? null : _save,
              child: isBusy
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('保存'),
            ),
          ],
        );
      },
    );
  }
}

class _CreateKnowledgeDeckDialog extends StatefulWidget {
  const _CreateKnowledgeDeckDialog({
    required this.controller,
    required this.deckId,
  });

  final CreateKnowledgeDeckController controller;
  final String deckId;

  @override
  State<_CreateKnowledgeDeckDialog> createState() =>
      _CreateKnowledgeDeckDialogState();
}

class _CreateKnowledgeDeckDialogState
    extends State<_CreateKnowledgeDeckDialog> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createDeck() async {
    final success = await widget.controller.createDeck(
      id: widget.deckId,
      name: _nameController.text,
      description: _descriptionController.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop(true);
      return;
    }

    final message = widget.controller.error is ArgumentError
        ? '请输入知识库名称'
        : '创建知识库失败，请重试';
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, child) {
        final isSaving = widget.controller.isSaving;
        return AlertDialog(
          title: const Text('新建知识库'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  enabled: !isSaving,
                  controller: _nameController,
                  autofocus: true,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: '名称',
                    hintText: '例如：Flutter',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  enabled: !isSaving,
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: '描述（可选）',
                    hintText: '这个知识库主要学习什么？',
                    alignLabelWithHint: true,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSaving
                  ? null
                  : () => Navigator.of(context).pop(false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: isSaving ? null : _createDeck,
              child: isSaving
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('创建'),
            ),
          ],
        );
      },
    );
  }
}
