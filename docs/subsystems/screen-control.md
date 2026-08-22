# Screen Control System

## 1. 职责

Screen Control System 负责执行受限 App 的锁定与解锁。

它接收 Unlock Rule System 输出的解锁状态：

- `Locked`
- `Unlocked`

并根据当前状态调用对应平台的系统能力。

Screen Control System 不负责判断任务是否完成，也不负责决定当前是否应该解锁。

## 2. 输入与输出

### 输入

当前解锁状态：

- `Locked`
- `Unlocked`

### 输出

将当前解锁状态同步到操作系统。

`Locked`
→ 限制用户选择的受限 App

`Unlocked`
→ 解除受限 App 的限制


## 3. 控制状态

### Locked

受限 App 处于限制状态。

用户无法正常使用已选择的受限 App。

### Unlocked

解除受限 App 的限制。

用户可以正常使用这些 App。

## 4. 受限 App

用户可以选择需要由「再玩」管理的 App。

例如：

- 短视频 App
- 社交媒体 App
- 视频 App
- 游戏

Screen Control System 只控制用户主动选择的受限 App。


## 5. 核心流程

### 锁定

Unlock Rule System
↓
Locked
↓
Screen Control System
↓
调用平台控制能力
↓
限制受限 App


### 解锁

Unlock Rule System
↓
Unlocked
↓
Screen Control System
↓
调用平台控制能力
↓
解除受限 App 限制
