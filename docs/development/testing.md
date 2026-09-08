# Testing

## 测试范围

- Task System
- Unlock Rule System
- Screen Control System
- Knowledge Card System
- Review System

## 必测场景

- 有未完成任务时保持 Locked
- 所有任务完成后变为 Unlocked
- 当天无任务时为 Unlocked
- 新增未完成任务后重新 Locked
- 跨天后重新计算状态
- 单选与多选答案判定不依赖选项顺序
- 复习记录不会重复累计学习任务进度
- 卡片持久化后可以正确恢复各类型配置
- 麦克风权限拒绝、录音中断和识别失败不会判定通过
