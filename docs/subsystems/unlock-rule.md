# Unlock Rule System

## 1. 职责

Unlock Rule System 负责根据当天任务完成状态，计算当前的 App 解锁状态。

它接收 Task System 提供的今日任务状态，并输出：

- `Locked`
- `Unlocked`

Unlock Rule System 只负责判断解锁状态，不负责执行具体的 App 锁定或解锁。

## 2. 输入与输出

### 输入

今日任务列表及任务状态。

例如：

- 数学学习：Completed
- 背单词：Completed
- 阅读：Pending

### 输出

当前解锁状态：

- `Locked`
- `Unlocked`


## 3. 核心判断规则

V1.0 采用“当天所有任务完成后解锁”的规则。

### Locked

当天存在至少一个未完成任务：

未完成任务数量 > 0

↓

Locked


### Unlocked

当天不存在未完成任务：

未完成任务数量 = 0

↓

Unlocked

## 4. 重新计算时机

以下事件发生后，需要重新计算当前解锁状态：

- 创建今日任务
- 删除今日任务
- 今日任务完成
- 今日任务状态发生变化
- 进入新的一天

## 5. 与其他系统的关系

Unlock Rule System 位于 Task System 和 Screen Control System 之间。

Task System
↓
提供今日任务状态
↓
Unlock Rule System
↓
计算 Locked / Unlocked
↓
Screen Control System
↓
执行实际的 App 锁定或解锁
