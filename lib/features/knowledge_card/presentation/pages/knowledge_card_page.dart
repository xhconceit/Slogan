import 'package:flutter/material.dart';

import '../controllers/knowledge_card_controller.dart';

/// 展示一个知识库的卡片
///
/// 页面负责展示状态；查询数据交给控制器
class KnowledgeCardPage extends StatefulWidget {
  const KnowledgeCardPage({
    required this.deckName,
    required this.controller,
    super.key,
  });

  /// 知识库名称 用于标题
  final String deckName;

  /// 由打开页面的一方创建并传入
  ///
  /// 这里约定：页面只借用控制器
  /// 创建它的一方负责在页面关闭后释放
  final KnowledgeCardController controller;

  @override
  State<KnowledgeCardPage> createState() => _KnowledgeCardPageState();
}

class _KnowledgeCardPageState extends State<KnowledgeCardPage> {
  @override
  void initState() {
    super.initState();

    // 页面首次创建时加载卡片
    // 不放在 build 中，避免每次刷新界面重新查询
    widget.controller.loadCards();
  }

  @override
  void didUpdateWidget(covariant KnowledgeCardPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 如果父组件换了控制器，就通过新控制器加载数据
    if (oldWidget.controller != widget.controller) {
      widget.controller.loadCards();
    }
  }

  @override
  Widget build(BuildContext context) {
    // 控制器调用 notifyListeners() 后
    // builder 重新执行，读取最新状态
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, child) {
        final controller = widget.controller;
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.deckName),
            actions: [
              IconButton(
                tooltip: '刷新卡片',

                /// 加载期间禁用刷新按钮，避免重复操作
                onPressed: controller.isLoading
                    ? null
                    : () {
                        controller.loadCards();
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

  /// 根据控制器状态构建页面内容
  Widget _buildBody(BuildContext context) {
    final controller = widget.controller;

    // 1. 首次加载还没有数据, 显示居中的加载动画
    if (controller.isLoading && controller.cards.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    // 2. 没有可展示的数据且加载失败，显示错误和重试按钮
    if (controller.error != null && controller.cards.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('卡片加载失败，请重试'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                controller.loadCards();
              },
              child: const Text("重新加载"),
            ),
          ],
        ),
      );
    }

    /// 3. 查询成功但没有卡片，显示空状态
    if (controller.cards.isEmpty) {
      return const Center(child: Text('这个知识库还没有卡片'));
    }

    /// 4. 已有卡片时展示列表
    // 刷新期间保留旧内容，避免页面突然变成空白
    return Column(
      children: [
        // 有旧数据时刷新，用顶部进度条提示加载中
        if (controller.isLoading) const LinearProgressIndicator(),
        // 刷新失败时保留旧列表，同时说明数据未更新
        if (controller.error != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '刷新失败，当前显示上次加载的内容，请重试',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        // 为列表分配剩余高度，避免 Column 中的列表高度无限
        Expanded(
          child: RefreshIndicator(
            /// 下拉刷新时，等待加载方法结束在收起刷新提示
            onRefresh: controller.loadCards,
            child: ListView.separated(
              /// 即使卡片很少，也能下拉刷新
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: controller.cards.length,
              separatorBuilder: (context, index) {
                return const SizedBox(height: 12);
              },
              itemBuilder: (context, index) {
                final card = controller.cards[index];
                return Card(
                  /// 使用卡片 ID 标识列表项，避免依赖排列位置
                  key: ValueKey(card.id),
                  margin: EdgeInsets.zero,
                  child: ListTile(
                    leading: const Icon(Icons.style_outlined),
                    // 列表先展示题面，答案留到后面的翻卡页面
                    title: Text(card.prompt),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
