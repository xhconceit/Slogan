import 'package:flutter/material.dart';

import '../controllers/knowledge_deck_controller.dart';

/// 知识库列表页面
///
/// 控制器由外部传入，页面负责展示状态和触发加载
class KnowledgeDeckPage extends StatefulWidget {
  const KnowledgeDeckPage({required this.controller, super.key});

  final KnowledgeDeckController controller;
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
        );
      },
    );
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

                    /// 没有描述时不显示副标题
                    subtitle: description == null || description.trim().isEmpty
                        ? null
                        : Text(description),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
  // 不在这里 dispose 控制器：
  // 它由外部传入，生命周期应由拥有它的对象管理。
  // ListenableBuilder 会自动移除自己的监听。
}
