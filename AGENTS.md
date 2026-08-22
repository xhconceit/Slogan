# Project Instructions

## Project Overview

「再玩」是一款任务驱动的手机自律工具。

核心闭环：

完成当天所有任务
→ 解锁条件成立
→ 解除受限 App 的系统限制

技术栈：

- Flutter / Dart：跨平台 UI 与核心业务
- Swift：iOS 平台能力
- Kotlin：Android 平台能力
- Platform Channel：Flutter 与原生能力通信

当前阶段优先验证平台控制能力，再进行完整功能开发。

## Source of Truth

文档描述项目的预期设计，代码描述当前实际实现，测试描述已经得到验证的行为。

如果三者不一致：

1. 不要默认任何一方一定正确。
2. 判断当前任务是否明确要求改变该行为。
3. 检查相关测试、产品文档和平台限制。
4. 能确定正确行为时，同步修改代码、测试和文档。
5. 无法确定时，不得擅自修改核心产品规则，应报告冲突并说明影响。

## Documentation Routing

修改产品规则：
→ `docs/product.md`

修改系统整体结构：
→ `docs/architecture.md`

修改任务逻辑：
→ `docs/subsystems/task.md`

修改解锁规则：
→ `docs/subsystems/unlock-rule.md`

修改 App 控制：
→ `docs/subsystems/screen-control.md`

修改 iOS 平台能力：
→ `docs/platforms/ios.md`

修改 Android 平台能力：
→ `docs/platforms/android.md`

修改数据结构：
→ `docs/data/data-models.md`

修改页面和用户流程：
→ `docs/user/`

修改当前版本范围：
→ `docs/roadmap/v1.md`

修改开发或测试约定：
→ `docs/development/`

## Architecture Boundaries

### Flutter

负责：

- 页面与交互
- 任务管理
- 解锁规则计算
- 本地数据
- API 通信
- 平台无关业务逻辑

### Native Platforms

Swift 和 Kotlin 负责：

- 系统权限
- 受限 App 选择
- App 限制与解除限制
- 系统状态检测
- Flutter 无法可靠实现的平台能力

核心产品规则应尽量保留在 Dart 层。

原生层不得自行实现另一套解锁规则，只接收并执行明确的控制状态。

## Core Product Invariants

除非任务明确要求修改产品规则，否则必须保持：

- 当天存在未完成任务时，状态为 `Locked`
- 当天不存在未完成任务时，状态为 `Unlocked`
- 当天没有任务时，状态为 `Unlocked`
- 今日任务变化后立即重新计算状态
- 跨天后根据新一天的任务重新计算状态
- 只有用户选择的 App 可以被限制

## Platform Capability Rules

涉及 iOS 或 Android 系统能力时：

1. 先确认目标系统版本和官方 API 限制。
2. 不得假设两个平台能力完全对等。
3. 不得将实验性能力描述为稳定能力。
4. 权限拒绝、权限撤销、设备重启和应用未运行必须纳入设计。
5. 平台能力发生变化时，同步更新对应平台文档。
6. 如果平台限制会改变产品行为，先报告冲突，再修改产品规则。

## Testing Requirements

修改业务逻辑时，应补充或更新测试。

解锁规则至少覆盖：

- 有未完成任务时为 `Locked`
- 所有任务完成后为 `Unlocked`
- 当天无任务时为 `Unlocked`
- 新增未完成任务后重新变为 `Locked`
- 删除未完成任务后重新计算
- 跨天后重新计算

修改 Platform Channel 时，应验证：

- 参数和返回值格式
- Flutter 与原生错误映射
- 权限不足
- 原生调用失败
- 重复调用的幂等性

如果测试因环境或平台限制无法运行，应明确说明未验证的部分。

## Repository Hygiene

- 不提交密钥、证书、签名文件或本地配置。
- 不手动修改自动生成文件，除非项目明确要求。
- 不进行与当前任务无关的大规模格式化或重构。
- 保留用户已有的未提交修改。
- 新增依赖前说明用途，并优先选择维护活跃、范围最小的方案。

## Documentation Maintenance

- `README.md` 只保留项目介绍和文档入口。
- 系统架构以 `docs/architecture.md` 为准。
- 不新增与现有文档职责重复的根目录文档。
- 文档链接应使用相对于当前文件的有效路径。
