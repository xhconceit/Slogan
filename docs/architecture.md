# 系统架构

## 1. 架构目标

「再玩」的系统架构围绕“完成任务 → 判断解锁条件 → 控制受限 App”这一核心闭环设计。

系统需要解决三个核心问题：

1. 管理并判断用户的任务是否完成。
2. 根据当天任务完成状态判断受限 App 是否可以解锁。
3. 通过 iOS 和 Android 的系统能力执行 App 的锁定与解锁。

## 2. 整体架构

系统主要由 Flutter 应用层、核心业务模块、平台控制层和数据层组成。

整体结构：

Flutter App
│
├── UI
│
├── Task System
│
├── Unlock Rule System
│
├── Screen Control Interface
│
├── Local Storage
│
└── API Client
        │
        │
        ├──────────────→ Backend API
        │
        ↓
Platform Channel
        │
   ┌────┴────┐
   ↓         ↓
  iOS      Android
 Swift      Kotlin
   │         │
   ↓         ↓
系统级 App 控制能力

## 3. 核心模块

### 3.1 Task System

负责管理用户任务及任务完成状态。

主要职责：

- 创建任务
- 编辑任务
- 删除任务
- 管理今日任务
- 判断任务是否完成

详细设计见：

`subsystems/task.md`


### 3.2 Unlock Rule System

负责根据当天任务状态判断受限 App 是否应该锁定。

核心规则：

今日存在未完成任务
→ Locked

今日不存在未完成任务
→ Unlocked

详细设计见：

`subsystems/unlock-rule.md`


### 3.3 Screen Control System

负责执行受限 App 的实际锁定和解锁。

它接收 Unlock Rule System 的状态：

Locked
或
Unlocked

然后调用不同平台的系统能力执行控制。

详细设计见：

`subsystems/screen-control.md`


## 4. 核心数据流

### 4.1 完成任务并解锁 App

用户完成任务
↓
Task System 更新任务状态
↓
Unlock Rule System 重新检查今日任务
↓
判断是否仍存在未完成任务
↓
不存在未完成任务
↓
状态变为 Unlocked
↓
Screen Control System 接收状态变化
↓
调用平台控制能力
↓
解除受限 App 限制

### 4.2 新增任务并重新锁定

用户创建新的今日任务
↓
Task System 保存任务
↓
Unlock Rule System 重新检查今日任务
↓
发现存在未完成任务
↓
状态变为 Locked
↓
Screen Control System
↓
重新限制受限 App

## 5. 技术边界

### Flutter

负责跨平台业务和 UI，包括：

- 任务管理
- 解锁规则
- 页面与交互
- 本地数据
- API 通信
- 设置

### Native Platform

负责与操作系统强相关的能力：

iOS：

- App 选择
- App 限制
- 系统权限
- 使用状态相关能力

Android：

- App 使用状态
- 前台 App 识别
- App 限制相关能力
- 系统权限

Flutter 不直接实现系统级 App 控制。

统一通过：

Flutter
↓
Screen Control Interface
↓
Platform Channel
↓
Swift / Kotlin
↓
System API
