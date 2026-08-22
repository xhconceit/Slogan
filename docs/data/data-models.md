# 数据模型

## 1. 核心数据对象

V1.0 包含以下核心数据对象：

User
├── Task
├── RestrictedApp
└── UnlockState

## 2. Task

Task 表示用户需要完成的任务。

核心字段：

| 字段 | 说明 |
|---|---|
| id | 任务唯一标识 |
| name | 任务名称 |
| type | 任务类型 |
| target | 任务目标 |
| status | 当前状态 |
| repeatType | 重复规则 |
| createdAt | 创建时间 |


## 3. RestrictedApp

RestrictedApp 表示用户选择由「再玩」控制的 App。

核心信息包括：

| 字段 | 说明 |
|---|---|
| id | 记录唯一标识 |
| appIdentifier | App 的平台标识 |
| platform | 所属平台 |
| createdAt | 添加时间 |


## 4. UnlockState

UnlockState 表示当前受限 App 的解锁状态。

核心状态：

- `Locked`
- `Unlocked`

该状态由 Unlock Rule System 根据当天任务状态计算。
